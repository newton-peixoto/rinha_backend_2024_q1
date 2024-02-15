defmodule RinhaBackend.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  import Ecto.Query

  @impl true
  def start(_type, _args) do
    children = [
      RinhaBackendWeb.Telemetry,
      RinhaBackend.Repo,
      {DNSCluster, query: Application.get_env(:rinha_backend, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: RinhaBackend.PubSub},
      # Start a worker by calling: RinhaBackend.Worker.start_link(arg)
      # {RinhaBackend.Worker, arg},
      # Start to serve requests, typically the last entry
      RinhaBackendWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: RinhaBackend.Supervisor]
    started = Supervisor.start_link(children, opts)

    IO.inspect("warmming up!..")
    warm_up()
    IO.inspect("done!..")
    started
  end

  defp warm_up() do
    Enum.each(1..1000, fn _ ->
      id = Enum.random(1..5)

      %RinhaBackend.ClientSchema{} =
        RinhaBackend.ClientSchema |> where([u], u.id == ^id) |> RinhaBackend.Repo.one()
    end)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    RinhaBackendWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
