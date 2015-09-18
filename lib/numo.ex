defmodule Numo do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    consumers = Application.get_env(:numo, Consumer.Json)[:consumers]
      |> Enum.map(fn(c) -> worker(Consumer.Json, [c]) end)
    
    children = [
      # Start the endpoint when the application starts
      supervisor(Numo.Endpoint, []),
      # Start the Ecto repository
      worker(Numo.Repo, []),

      worker(ConCache, [[ttl_check: :timer.minutes(1),
                         ttl: :timer.minutes(30),
                         touch_on_read: true],
                        [name: :consumer_cache]]),
      
      # worker(Numo.Worker, [arg1, arg2, arg3]),
    ] |> Enum.concat(consumers)

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Numo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Numo.Endpoint.config_change(changed, removed)
    :ok
  end
end
