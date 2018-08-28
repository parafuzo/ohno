import Logger

# Relative root project
root_path = Path.expand(Path.join(__DIR__, ".."))

# Loading Envy manually because it might not be
# compiled and not loaded the first time
dotenv_path = "#{root_path}/deps/dotenv/lib/dotenv"
if File.exists?("#{dotenv_path}.ex") and !Code.ensure_loaded?(Dotenv) do
  Code.eval_file("#{dotenv_path}/env.ex")
  Code.eval_file("#{dotenv_path}.ex")
end

if Code.ensure_loaded?(Dotenv) do
  current_env = "#{Mix.env}" |> String.downcase
  files = [
    "#{root_path}/.env",
    "#{root_path}/envs/.env",
    "#{root_path}/envs/#{current_env}.env"
  ]

  files = (
    current_env == "test"
      && List.insert_at(files, -2, "#{root_path}/envs/dev.env")
      || files
  )

  Enum.reduce(files, %{}, fn file, acc ->
    if File.exists?(file) do
      %{values: values} = Dotenv.load(file)
      Map.merge(acc, values)
    else
      acc
    end
  end)
  |> Map.merge(System.get_env())
  |> System.put_env()
end
