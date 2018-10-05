defmodule Fabion.CloudBuild.Client do
  @enforce_keys [:adapter, :client, :repository]
  defstruct @enforce_keys

  @type t :: %__MODULE__{
    adapter: Module.t(),
    client: Tesla.Env.client,
    repository: Fabion.Sources.Repository.t()
  }
end
