defmodule Fabion.Factories do
  use ExMachina.Ecto, repo: Fabion.Repo

  import Fabion.Support.Helpers
  import ShorterMaps

  alias Fabion.Sources
  alias Fabion.Accounts

  def repository_factory do
    github_repo = Faker.Internet.user_name() <> "/" <> Faker.Internet.domain_word()
    gcloud = Slug.slugify("github-" <> github_repo, separator: ?-)

    %Sources.Repository{
      gcloud_repo: gcloud,
      github_repo: github_repo,
      github_secret: Ecto.UUID.generate(),
      github_token: Ecto.UUID.generate(),
    }
  end

  def github_user_factory do
    user_id = Faker.random_between(1, 5000)

    %Accounts.GithubUser{
      node_id: Base.encode64("04:User#{user_id}"),
      login: Faker.Internet.user_name(),
      html_url: Faker.Internet.url(),
      avatar_url: Faker.Internet.url(),
    }
  end

  def repository_event_factory do
    repository = build(:repository)
    sender = build(:github_user)

    %Sources.RepositoryEvent{
      type: Enum.random(Sources.RepositoryEventType.__enum_map__),
      params: %{},
      repository: repository,
      sender: sender,
    }
  end

  def repository_event_with_params(type, params) do
    params = read_file_event!("push_commit")
    {:ok, github_repo} =
      jq!(params, ".repository.url")
      |> Sources.parse_repo()

    repository = build(:repository, ~M{github_repo})
    insert(:repository_event, ~M{type, params, repository})
  end
end
