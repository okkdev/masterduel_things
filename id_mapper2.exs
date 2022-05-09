Mix.install([
  {:req, "~> 0.2"},
  {:jason, "~> 1.3"},
  {:owl, "~> 0.2"},
  {:floki, "~> 0.32.0"}
])

# This mapper scrapes the wiki pages from yugipedia

art_dir = "art"

Owl.ProgressBar.start(id: :bar, label: "Progress:", total: File.ls!(art_dir) |> length())

Owl.LiveScreen.add_block(
  :status,
  state: :init,
  render: fn
    :init ->
      "..."

    :done ->
      Owl.Data.tag("Done!", :green)

    {:mapping, name} ->
      [
        "Mapping: ",
        Owl.Data.tag(name, :yellow)
      ]
  end
)

for file <- File.ls!(art_dir) do
  card_id =
    file
    |> String.trim_trailing(".png")
    |> String.to_integer()

  try do
    {:ok, document} =
      card_id
      |> then(&"https://yugipedia.com/wiki/#{&1}")
      |> then(&Req.get!(&1).body)
      |> Floki.parse_document()

    card_name =
      document
      |> Floki.find("div.card-table > div.heading > div")
      |> Floki.text()

    card_password =
      document
      |> Floki.find(
        "div.card-table > div.card-table-columns > div.infocolumn > table > tbody > tr > td > a.mw-redirect"
      )
      |> Floki.text()
      |> String.to_integer()

    Owl.ProgressBar.inc(id: :bar)
    Owl.LiveScreen.update(:status, {:mapping, card_name})

    %{
      id: card_id,
      konami_id: card_password,
      name: card_name
    }
  rescue
    _ ->
      Owl.ProgressBar.inc(id: :bar)
      Owl.LiveScreen.update(:status, {:mapping, "Not Found..."})

      %{
        id: card_id,
        konami_id: nil,
        name: "Not found"
      }
  end
end
|> Jason.encode!()
|> then(&File.write!("mapped_cards.json", &1))

Owl.LiveScreen.update(:status, :done)

Owl.LiveScreen.await_render()
