{:ok, _} = Application.ensure_all_started(:mox)

ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(Ohno.Repo, :manual)

