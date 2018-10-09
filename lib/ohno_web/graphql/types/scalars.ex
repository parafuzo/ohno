defmodule OhnoWeb.Graphql.Types.Scalars do
  use OhnoWeb.Graphql, :graphql

  require Logger

  @desc """
  The `DateTime` scalar type represents full date and time in UTC.
  (e.g. "2017-06-19T22:06:37.205849Z").
  https://github.com/bitwalker/timex/blob/master/lib/format/datetime/formatters/default.ex
  """
  scalar :date_time, description: "ISOz time" do
    parse fn input ->
      case Timex.parse(input.value, "{ISO:Extended:Z}") do
        {:error, _reason} -> :error
                   result -> result
      end
    end
    serialize &Timex.format!(&1, "{ISO:Extended:Z}")
  end

  @desc """
  The `Date` scalar type represents a ISO date.
  (e.g. "2017-06-19").
  """
  scalar :date, description: "ISO date" do
    parse fn input ->
      case Timex.parse(input.value, "{ISOdate}") do
        {:error, _reason} -> :error
        result -> result
      end
    end
    serialize &Timex.format!(&1, "{ISOdate}")
  end

  @desc """
  The `json` scalar type represents a json document.
  (e.g. "{\"key\": \"value\"}").
  """
  scalar :json_text, description: "A json document" do
    parse fn input ->
      case Poison.decode(input.value) do
        {:error, _reason} -> :error
        result -> result
      end
    end
    serialize fn value ->
      case Poison.encode(value) do
        {:error, _reason} -> :error
        {:ok, result} -> result
      end
    end
  end
end
