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

  GAME_STATE="$(echo "${GAME_STATE}" | jq -cr '.dealer.cards += [.deck[0]] | .deck = .deck[1:]')"
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

# usage: transform_game_state_to_player "${GAME_STATE}"
function transform_game_state_to_player {
  # TODO: settle step will not hide
  GAME_STATE="${1}"
  echo "${GAME_STATE}" | jq -rc 'del(.deck) | .dealer.cards[0] = -1'
}

# usage: is_browser_user_agent "${USER_AGENT}"
function is_browser_user_agent {
  echo "${1}" | grep -q 'Mozilla'
}

# usage: find_uri_query "${URI_QUERY}" "${NAME}"
# URI_QUERY := [[/path]?]a=b&foo=bar
function find_uri_query {
  echo "${1}" | jq -Rcr \
    --arg PREFIX "${2}=" \
    'split("?")
      | last
      | split("&")
      | map(select(startswith($PREFIX)))
      | first
      | ltrimstr($PREFIX)
      // ""
    '
}

# usage: get_game_id_from_uri "${REQUEST_URI}"
function get_game_id_from_uri {
  echo "${1}" | sed -E s'|/[a-z]+/games/([0-9]+).*|\1|'
}

# usage: is_jwt_token_pattern "${JWT_TOKEN}"
function is_jwt_token_pattern {
  echo "${1}" | grep -q '^eyJ[a-zA-Z0-9.]\+$'
}

# usage: is_game_id_pattern "${GAME_ID}"
function is_game_id_pattern {
  echo "${1}" | grep -q '^[0-9]\+$'
}

# usage: is_game_global_counter_pattern "${REQUEST_QUERY_I}"
function is_game_global_counter_pattern {
  echo "${1}" | grep -q '^-\?[0-9]\+$'
}

# usage: get_game_global_counter "${GAME_STATE}"
# @returns integer
function get_game_global_counter {
  local CURRENT_I
  CURRENT_I="$(echo "${1}" | jq -rc '.i')"
  if is_game_global_counter_pattern "${CURRENT_I}"; then
    echo "${CURRENT_I}"
  else
    echo '-1'
  fi
}

function echo_err {
  # REF: https://stackoverflow.com/a/2990533
  printf "%s\n" "$*" >&2
}
