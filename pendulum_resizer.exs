Mix.install([
  {:mogrify, "~> 0.9.1"},
  {:owl, "~> 0.2"}
])

dir = "art"
width = 2048
height = 2616

files = File.ls!(dir)

Owl.ProgressBar.start(id: :bar, label: "Progress:", total: length(files))

Owl.LiveScreen.add_block(
  :status,
  state: :init,
  render: fn
    :init ->
      "..."

    :done ->
      Owl.Data.tag("Done!", :green)

    {:scanning, name} ->
      [
        "Scanning: ",
        Owl.Data.tag(name, :yellow)
      ]


    {:resizing, name} ->
      [
        "Resizing: ",
        Owl.Data.tag(name, :yellow)
      ]
  end
)

Enum.each(files, fn file ->
  Owl.LiveScreen.update(:status, {:scanning, file})

  if String.ends_with?(file, ".png") do
    filepath = Path.join(dir, file)

    filepath
    |> Mogrify.identify()
    |> then(fn %{height: h, width: w} ->

      if h != w and h != height do
        Owl.LiveScreen.update(:status, {:resizing, file})

        filepath
        |> Mogrify.open()
        |> Mogrify.resize("#{width}x#{height}!")
        |> Mogrify.save(in_place: true)
      end

    end)
  end

  Owl.ProgressBar.inc(id: :bar)
end)

Owl.LiveScreen.update(:status, :done)
Owl.LiveScreen.await_render()
