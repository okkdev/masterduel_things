Mix.install([
  {:req, "~> 0.2"},
  {:jason, "~> 1.3"},
  {:owl, "~> 0.2"}
])

defmodule IdMapper do
  def run do
    :cards = :ets.new(:cards, [:set, :protected, :named_table, read_concurrency: true])

    cardnum =
      Req.get!("https://www.masterduelmeta.com/api/v1/cards?collectionCount=true").body
      |> String.to_integer()

    pages =
      (cardnum / 3000)
      |> ceil()

    1..pages
    |> Enum.flat_map(fn page ->
      url =
        "https://www.masterduelmeta.com/api/v1/cards?limit=3000&page=#{page}"
        |> URI.encode()

      Req.get!(url).body
    end)
    |> Enum.filter(&(&1["alternateArt"] != true))
    |> Enum.map(
      &{
        normalize_string(&1["name"]),
        &1["konamiID"]
      }
    )
    |> tap(&Owl.ProgressBar.start(id: :bar, label: "Progress:", total: length(&1)))
    |> then(&:ets.insert(:cards, &1))

    "md_cards.txt"
    |> File.read!()
    |> String.split("\n")
    |> Enum.map(&String.split(&1, ": ", parts: 2))
    |> Enum.map(fn [id, name] ->
      Owl.ProgressBar.inc(id: :bar)

      kid =
        case :ets.lookup(:cards, normalize_string(name)) do
          [e | _] -> e |> elem(1) |> String.to_integer()
          _ -> nil
        end

      %{
        id: String.to_integer(id),
        konami_id: kid,
        name: name
      }
    end)
    |> Jason.encode!()
    |> then(&File.write!("mapped_cards.json", &1))

    Owl.LiveScreen.await_render()
  end

  defp normalize_string(string) when is_binary(string) do
    string
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9.]/, "")
  end
end

IdMapper.run()
