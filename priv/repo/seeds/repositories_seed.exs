import Ohno.Seeds

data = json_data!("repositories") || []
for repository <- data do
  add!(Ohno.Sources.Repository, repository)
end
