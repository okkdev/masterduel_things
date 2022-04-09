Mix.install([
  {:mogrify, "~> 0.9.1"},
  {:owl, "~> 0.2"}
])

dir = "art"

dir
|> File.ls!()
|> tap(&Owl.ProgressBar.start(id: :bar, label: "Progress:", total: length(&1)))
|> Enum.each(fn file ->
  filepath = Path.join(dir, file)

  filepath
  |> Mogrify.identify()
  |> then(fn %{height: h, width: w} ->
    if h != w do
      filepath
      |> Mogrify.open()
      |> Mogrify.resize("512x654!")
      |> Mogrify.save(in_place: true)
    end

    Owl.ProgressBar.inc(id: :bar)
  end)
end)

Owl.LiveScreen.await_render()
