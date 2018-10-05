defmodule Fabion.CloudBuild.GCloudAdapter do
  @behaviour Fabion.CloudBuild.Adapter

  alias Fabion.CloudBuild.Client
  alias Fabion.Sources.Repository

  alias GoogleApi.CloudBuild.V1.Connection
  alias GoogleApi.CloudBuild.V1.Api.Projects

  @scope "https://www.googleapis.com/auth/cloud-platform"

  def new_repo(%Repository{} = repository) do
    {:ok, token} = Goth.Token.for_scope(@scope)

    %Client{
      adapter: __MODULE__,
      client: Connection.new(token.token),
      repository: repository
    }
  end

  def build_get(%Client{} = client, id) do
    projects_apply(client, :cloudbuild_projects_builds_get, [id])
  end

  def build_create(
        %Client{
          repository: %Repository{
            gcloud_repo: gcloud_repo,
            gcloud_project_id: project_id
          }
        } = client,
        refs,
        body
      ) do
    body =
      Map.merge(body, %{
        source: %{
          repoSource: %{
            commitSha: refs,
            projectId: project_id,
            repoName: gcloud_repo,
            dir: "./"
          }
        }
      })

    opts = [body: body |> Poison.encode!()]
    projects_apply(client, :cloudbuild_projects_builds_create, [opts])
  end

  defp projects_apply(
         %Client{
           client: conn,
           repository: %Repository{gcloud_project_id: project_id}
         },
         method,
         args
       ) do
    apply(Projects, method, [conn, project_id | args])
  end
end
