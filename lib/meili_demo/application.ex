defmodule MeiliDemo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      MeiliDemoWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:meili_demo, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: MeiliDemo.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: MeiliDemo.Finch},
      # Start our gen server maintaining and handling the meili backend
      {MeiliDemo.Meili, []},
      # Start a worker by calling: MeiliDemo.Worker.start_link(arg)
      # {MeiliDemo.Worker, arg},
      # Start to serve requests, typically the last entry
      MeiliDemoWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MeiliDemo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MeiliDemoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
