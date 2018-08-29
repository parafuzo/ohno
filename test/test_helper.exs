{:ok, _} = Application.ensure_all_started(:mox)

ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(Fabion.Repo, :manual)

