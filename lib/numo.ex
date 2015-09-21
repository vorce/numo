defmodule Numo do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    consumers = Application.get_env(:numo, Consumers)[:consumers]
      |> Enum.with_index
      |> Enum.map(fn({{m, cfg}, i}) -> worker(m, [cfg], id: "#{m}:#{i}") end)
    
    children = [
      # Start the endpoint when the application starts
      supervisor(Numo.Endpoint, []),
      # Start the Ecto repository
      worker(Numo.Repo, []),

      worker(ConCache, [[ttl_check: :timer.minutes(1),
                         ttl: :timer.minutes(30),
                         touch_on_read: true],
                        [name: :consumer_cache]]),  
    ] |> Enum.concat(consumers)

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
