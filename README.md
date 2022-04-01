# Master Duel Card ID to Konami ID

This repo contains a script which generates a json file with all cards from `md_cards.txt` with their konami card ID, by looking the card name up on [YGOProDeck](https://db.ygoprodeck.com/api-guide/).

Thanks very much to @ioncodes for dumping the cards in his [repo](https://github.com/ioncodes/master-duel)!

The `mapped_cards.json` is the output of the script.

## Run mapper

```sh
elixir id_mapper.exs
```

## Todo
- [ ] Fix/Workaround for cards with special characters in name (eg. Live Twins)