defmodule Ohno.CloudBuild.Client do
  @enforce_keys [:adapter, :client, :repository]
  defstruct @enforce_keys

  @type t :: %__MODULE__{
    adapter: Module.t(),
    client: Tesla.Env.client,
    repository: Ohno.Sources.Repository.t()
  }
end
