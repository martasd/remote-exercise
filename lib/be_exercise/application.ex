defmodule BeExercise.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      BeExerciseWeb.Telemetry,
      # Start the Ecto repository
      BeExercise.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: BeExercise.PubSub},
      # Start the Endpoint (http/https)
      BeExerciseWeb.Endpoint
      # Start a worker by calling: BeExercise.Worker.start_link(arg)
      # {BeExercise.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BeExercise.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BeExerciseWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
