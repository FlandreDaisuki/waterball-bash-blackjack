#!/bin/bash

function new_shuffled_deck {
  shuf <(seq 0 155) | jq -cs
}

# usage: init_players_from_payload "${REQUEST_PAYLOAD_FROM_CREATE_GAME}"
function init_players_from_payload {
  echo "${1}" | jq -cr '.players | map(.+={cards:[],chips:100})'
}

# usage: init_round "${GAME_STATE}"
function init_round {
  GAME_STATE="${1}"
  GAME_STATE="$(echo "${GAME_STATE}" | jq -cr '.round+=1')"
  GAME_STATE="$(echo "${GAME_STATE}" | jq -cr '.turn=0')"
  GAME_STATE="$(echo "${GAME_STATE}" | jq -cr '.dealer.cards += [.deck[0]] | .deck = .deck[1:]')"
  PLAYERS_COUNT_INDEX="$(echo "${GAME_STATE}" | jq -cr '.players | length | . - 1')"
  for PC in $(seq 0 "${PLAYERS_COUNT_INDEX}"); do
    GAME_STATE="$(echo "${GAME_STATE}" | jq -cr ".players[${PC}].cards += [.deck[0]] | .deck = .deck[1:]")"
  done
  echo "${GAME_STATE}"
}

## player := {
##   "id": "0a0a0a0a0a0a0a0a0a0a0a0a",
##   "nickname": "ABCDE",
##   "chips": 100,
##   "cards": [],
## }

## game_state := {
##   "i": 0,     // global counter
##   "turn": 0,  // turn to bet, 0 = player[0], 5 = dealer
##   "round": 0, // round for games, max to 10 or else?
##   "deck": int[],
##   "players": player[],
##   "dealer": {cards: []}
## }

# usage: init_game "${REQUEST_PAYLOAD_FROM_CREATE_GAME}"
function init_game {
  GAME_STATE="$(
    jq -ncr \
      --argjson DECK "$(new_shuffled_deck)" \
      --argjson PLAYERS "$(init_players_from_payload "${1}")" \
      '{
      i: 0,
      turn: 0,
      round: 0,
      deck: $DECK,
      players: $PLAYERS,
      dealer: {cards: []}
    }'
  )"

  init_round "${GAME_STATE}"
}

# usage: is_browser_user_agent "${USER_AGENT}"
function is_browser_user_agent {
  echo "${1}" | grep -q 'Mozilla'
}
