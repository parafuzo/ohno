defmodule Fabion.CloudBuild.GCloudAdapterTest do
  use Fabion.DataCase, async: true
  use ExVCR.Mock, adapter: ExVCR.Adapter.Httpc

  import Indifferent.Sigils

  alias Fabion.Sources.Repository
  alias Fabion.CloudBuild.Client
  alias Fabion.CloudBuild.GCloudAdapter

  setup do
    ExVCR.Config.filter_request_headers("Authorization")

    repository =
      Application.get_env(:fabion, Repository)
      |> Keyword.fetch!(:fixture)
      |> Poison.decode!(%{keys: :atoms})
      |> add!(Repository)

    # repository =
    #   priv_json_file!("fixtures", "repository", %{keys: :atoms})
    #   |> add!(Repository)

    ~M{repository}
  end

  @build_id "ea60fadb-5f2d-4563-8249-147895b34eeb"
  test "get build status", ~M{repository} do
    assert %Client{
      adapter: GCloudAdapter,
      client: %Tesla.Client{},
      repository: repository,
    } = client = GCloudAdapter.new_repo(repository)

    use_cassette "gcloud_build_get" do
      assert {:ok, %{steps: [%{status: "SUCCESS"}]}} = GCloudAdapter.build_get(client, @build_id)
    end
  end

  test "create a build", ~M{repository} do
    client = GCloudAdapter.new_repo(repository)
    refs = "330868a5295943b45b6abfba8d6d59aaad4f4f0f"
    body =
      priv_yaml_file!("fixtures", "stage_test")
      |> Map.merge(%{
        substitutions: %{
          _PROJECT_NAME: repository.github_repo
        }
      })

    envs_specs = [
      "PROJECT_NAME=#{repository.github_repo}",
      "COMMIT_SHA=#{refs}",
      "REPO_NAME=#{repository.gcloud_repo}",
    ]

    use_cassette "gcloud_build_create" do
      assert {:ok, operation} = GCloudAdapter.build_create(client, refs, body)
      assert "QUEUED" == ~i(operation.metadata.build.status)
      assert nil != ~i(operation.metadata.build.id)
      assert match?([%{
        "args" => ["-c", "echo $PROJECT_NAME; env"],
        "entrypoint" => "/bin/bash",
        "name" => "gcr.io/cloud-builders/gcloud",
        "env" => ^envs_specs,
      }], ~i(operation.metadata.build.steps))
    end
  end
end
