defmodule Consumer.Json do
  require Logger
  use GenServer
  use AMQP

  @unknown_origin_code 0
  @multiple_failures_code 1
  @invalid_json_code 2

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, [])
  end

  def init(args) do
    Logger.info("Setting up #{__MODULE__} with settings: #{inspect args}")

    {:ok, conn} = Connection.open(args |> Map.get(:broker, "amqp://guest:guest@localhost"))
    {:ok, chan} = Channel.open(conn)

    # Limit unacknowledged messages to 10
    Basic.qos(chan, prefetch_count: 100)
    # Queue.declare(chan, @queue_error, durable: true)
    # Messages that cannot be delivered to any consumer in the main queue will be routed to the error queue
    #Queue.declare(chan, @queue, durable: true,
    #                            arguments: [{"x-dead-letter-exchange", :longstr, ""},
    #                                        {"x-dead-letter-routing-key", :longstr, @queue_error}])
    #Exchange.fanout(chan, @exchange, durable: true)
    #Queue.bind(chan, @queue, @exchange)
    # Register the GenServer process as a consumer
    {:ok, _consumer_tag} = Basic.consume(chan, args |> Map.get(:in_queue))
    {:ok, {chan, Map.put(args, :msg_count, 0)}}
  end

  # Confirmation sent by the broker after registering this process as a consumer
  def handle_info({:basic_consume_ok, %{consumer_tag: consumer_tag}}, state) do
    Logger.debug("Received confirmation from broker, now consuming. Tag: #{consumer_tag}")
    {:noreply, state}
  end

  # Sent by the broker when the consumer is unexpectedly cancelled (such as after a queue deletion)
  def handle_info({:basic_cancel, %{consumer_tag: consumer_tag}} = msg, state) do
    Logger.warn("Received unexpected cancel from broker: #{inspect msg}")
    {:stop, :normal, state}
  end

  # Confirmation sent by the broker to the consumer process after a Basic.cancel
  def handle_info({:basic_cancel_ok, %{consumer_tag: consumer_tag}}, state) do
    Logger.debug("Received basic_cancel_ok from broker. Tag: #{consumer_tag}")
    {:noreply, state}
  end

  def handle_info({:basic_deliver, payload, metadata}, {channel, args} = state) do
    spawn fn -> handle_message(state, payload, metadata) end
    {:noreply, {channel, Map.put(args, :msg_count, Map.get(args, :msg_count, 0) + 1)}}
  end

  #def handle_call(:msg_count, {from, ref}, {channel, args} = state) do
  #  {:reply, Map.get(args, :msg_count, 0), state}
  #end

  def handle_message(state, payload, metadata) do
    case deadlettered?(metadata |> Map.get(:headers, [])) do
      true ->
        deadlettered_message(state, payload, metadata)
      false ->
        unknown_message(state, payload, metadata)
    end
  end

  defp deadlettered_message({channel, args} = state, payload, %{delivery_tag: tag} = metadata) do
    case Poison.Parser.parse(payload) do
      {:error, _} -> 
        invalid_message(state, payload, metadata)
      {:ok, payload_struct} ->
        id = id_of(payload_struct, metadata)
        case seen?(id) do
          true -> seen_message(id, state, payload, metadata)
          false ->
            ConCache.put(:consumer_cache, id, true)
            out = Map.get(args, :out_exchange)
            routing_key = Map.get(metadata, :routing_key)
            options = metadata_to_options(metadata, id)
            resend(channel, tag, routing_key, payload, out, options)
        end
    end
  end

  def save_message(id, reason, payload, metadata, error_code, queue) do
    message_params = %{message_id: id,
    error_code: error_code,
    queue: queue,
    reason: reason,
    payload: payload,
    metadata: inspect(metadata)}
    
    changeset = Numo.Message.changeset(%Numo.Message{}, message_params)
    {:ok, m} = Numo.Repo.insert(changeset)
    Logger.info("Saved message: messages/#{m.id}")
  end
  
  defp unknown_message({channel, args} = state, payload, %{delivery_tag: tag} = metadata) do
    Logger.debug("Saving message that came from an unexpected source.")
    save_message("unknown", "Unknown origin", payload, metadata, @unknown_origin_code, Map.get(args, :in_queue))
    Basic.ack(channel, tag)
  end

  defp seen_message(id, {channel, args} = state, payload, %{delivery_tag: tag} = metadata) do
    Logger.debug("Saving message that have been seen before. Id: #{id}")
    save_message(id, "Failed to be processed multiple times", payload, metadata, @multiple_failures_code, Map.get(args, :in_queue))
    ConCache.delete(:consumer_cache, id)
    Basic.ack(channel, tag) 
  end

  defp invalid_message({channel, args} = state, payload, %{delivery_tag: tag} = metadata) do
    Logger.debug("Saving non-json message.")
    save_message("undefined", "Invalid Json", payload, metadata, @invalid_json_code, Map.get(args, :in_queue))   
    Basic.ack(channel, tag)
  end

  defp resend(channel, tag, routing_key, payload, to, options) do
    # TODO throttle!
    Logger.debug("Resending message: #{inspect %{:out_exchange => to, :routing_key => routing_key, :options => options}}")
    Basic.publish(channel, to, routing_key, payload, options)
    Basic.ack(channel, tag)
  end

  defp seen?(id) do
    ConCache.get(:consumer_cache, id) != nil
  end

  def id_of(message, metadata) do
    meta_id = Map.get(metadata, :message_id, :undefined)
    case meta_id do
      :undefined -> Map.get(message, "id", :undefined)
      _ -> meta_id
    end 
  end

  # headers: [{"x-death", :array, [table: [{"reason", :longstr, "expired"}, {"queue", :longstr, "test"}, {"time", :timestamp, 1442505533}, {"exchange", :longstr, ""}, {"routing-keys", :array, [longstr: "test"]}]]}]
  def deadlettered?(headers) do
    Enum.filter(headers, fn(h) -> is_tuple(h) and elem(h, 0) == "x-death" end) |> length > 0
  end

  def metadata_to_options(metadata, id) do
    [content_type: Map.get(metadata, :content_type, :undefined),
     content_encoding: Map.get(metadata, :content_encoding, :undefined),
     headers: Map.get(metadata, :headers, []) |> Enum.reject(fn(h) -> is_tuple(h) and elem(h, 0) == "x-death" end),
     correlation_id: Map.get(metadata, :correlation_id, :undefined),
     priority: Map.get(metadata, :correlation_id, :undefined),
     reply_to: Map.get(metadata, :reply_to, :undefined),
     expiration: Map.get(metadata, :expiration, :undefined),
     message_id: id,
     timestamp: now(),
     type: Map.get(metadata, :type, :undefined),
     user_id: Map.get(metadata, :user_id, :undefined),
     app_id: "numo"]
  end

  def now() do
    {mega,sec,micro} = :erlang.now()
    (mega*1000000+sec)*1000000+micro
  end
end