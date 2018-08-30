import Fabion.Seeds

data = json_data!("repositories") || []
for repository <- data do
  add(Fabion.Sources.Repository, repository)
end
