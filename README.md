# Master Duel Things

A collection of scripts I use for managing the Art and IDs from Master Duel.

Thanks very much to @ioncodes for dumping the cards in his [repo](https://github.com/ioncodes/master-duel)!

The `mapped_cards.json` contains all the cards with their Konami ID. (Most of the `Not Found` cards are Tokens)

## Run exs script

```sh
elixir <script>.exs
```

## Steps to get optimized card art

1. Dump art from Master Duel using AssetStudio
2. put art in `art/` folder
3. Run `elixir id_mapper2.exs` to update `mapped_cards.json`
4. Run `elixir renamer.exs` to rename the cards
5. Delete not found cards from `art/` folder
6. Run `elixir pendulum_resizer.exs` to resize the pendulum images
7. Run `./upscale.sh` to upscale the images
8. Run `fish compressor.fish` to compress the images to webp
9. Run `mc cp cart/* s3/ygo/` to upload the images to S3