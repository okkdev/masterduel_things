Mix.install([
  {:req, "~> 0.2"},
  {:jason, "~> 1.3"},
  {:owl, "~> 0.2"}
])

defmodule IdMapper do
  def gen_card_json(md_cards) do
    md_cards
    |> File.read!()
    |> String.split("\n")
    |> Enum.map(&String.split(&1, ": ", parts: 2))
    |> tap(&Owl.ProgressBar.start(id: :bar, label: "Progress:", total: length(&1)))
    |> tap(fn cards ->
      Owl.LiveScreen.add_block(
        :status,
        state: :init,
        render: fn
          :init ->
            "..."

          :done ->
            Owl.Data.tag("Done!", :green)

          :writing ->
            Owl.Data.tag("Writing to file...", :yellow)

          {:mapping, name, num} ->
            [
              "Mapping: ",
              Owl.Data.tag(name, :yellow),
              "\n",
              "Status: ",
              Owl.Data.tag("#{num}/#{length(cards)}", :yellow)
            ]
        end
      )
    end)
    |> Enum.with_index(1)
    |> Enum.map(fn {[id, name], index} ->
      # sleep to avoid getting ratelimited
      Process.sleep(60)
      Owl.ProgressBar.inc(id: :bar)
      Owl.LiveScreen.update(:status, {:mapping, name, index})

      %{
        id: String.to_integer(id),
        konami_id: fetch_id(name),
        name: name
      }
    end)
    |> Jason.encode!()
    |> tap(&Owl.LiveScreen.update(:status, :writing))
    |> then(&File.write!("mapped_cards.json", &1))

    Owl.LiveScreen.update(:status, :done)
    Owl.LiveScreen.await_render()
  end

  defp fetch_id(name, fuzzy \\ false) do
    "https://db.ygoprodeck.com/api/v7/cardinfo.php?#{if fuzzy, do: "fname", else: "name"}=#{name}"
    |> URI.encode()
    |> Req.get!()
    |> case do
      %{body: %{"data" => [card | _]}} ->
        card["id"]

      _ ->
        if fuzzy do
          nil
        else
          fetch_id(name, true)
        end
    end
  end
end

IdMapper.gen_card_json("md_cards.txt")
