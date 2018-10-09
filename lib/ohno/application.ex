defmodule Ohno.Application do
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec
    Confex.resolve_env!(:ohno)
    Confex.resolve_env!(:goth)

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(Ohno.Repo, []),
      # Start queue
      supervisor(Ohno.Enqueuer, []),
      # Start the endpoint when the application starts
      supervisor(OhnoWeb.Endpoint, []),
      # Start your own worker by calling: Ohno.Worker.start_link(arg1, arg2, arg3)
      # worker(Ohno.Worker, [arg1, arg2, arg3]),
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Ohno.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    OhnoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
