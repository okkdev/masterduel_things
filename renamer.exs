Mix.install([
  {:jason, "~> 1.3"},
  {:owl, "~> 0.2"}
])

dir = "art"

cards =
  "mapped_cards.json"
  |> File.read!()
  |> Jason.decode!()

dir
|> File.ls!()
|> tap(&Owl.ProgressBar.start(id: :bar, label: "Progress:", total: length(&1)))
|> Enum.each(fn file ->
  id =
    try do
      file
      |> String.trim_trailing(".png")
      |> String.to_integer()
    rescue
      _ -> file
    end

  new_name =
    cards
    |> Enum.find_value(&if(&1["id"] == id, do: &1["konami_id"]))
    |> case do
      nil -> "not_found_" <> file
      id -> to_string(id) <> ".png"
    end

  File.rename!(Path.join([dir, file]), Path.join([dir, new_name]))
  Owl.ProgressBar.inc(id: :bar)
end)

Owl.LiveScreen.await_render()
