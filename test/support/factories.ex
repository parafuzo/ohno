defmodule Fabion.Factories do
  use ExMachina.Ecto, repo: Fabion.Repo

  alias Fabion.Sources

  def repository_factory do
    github = Faker.Internet.user_name() <> "/" <> Faker.Internet.domain_word()
    gcloud = Slug.slugify("github-" <> github, separator: ?-)

    %Sources.Repository{
      github: github,
      gcloud_repo: gcloud,
      secret: Ecto.UUID.generate(),
      token: Ecto.UUID.generate(),
    }
  end
end
