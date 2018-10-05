defmodule Fabion.CloudBuild.Adapter do
  alias Fabion.Sources.Repository
  alias Fabion.CloudBuild.Client

  @callback new_repo(Repository.t()) :: Client.t()

  @callback build_get(Client.t(), String.t()) ::
    {:ok, GoogleApi.CloudBuild.V1.Model.Build.t()} | {:error, Tesla.Env.t()}

  @callback build_create(Client.t(), String.t(), %{}) ::
    {:ok, GoogleApi.CloudBuild.V1.Model.Operation.t()} | {:error, Tesla.Env.t()}
end
