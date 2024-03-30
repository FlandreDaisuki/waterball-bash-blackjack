#!/bin/bash

function new_shuffled_deck {
  shuf <(seq 0 155) | jq -cs
}

function init_players_from_payload {
  echo "${1}" | jq -cr '.players | map(.+={cards:[],chips:100})'
}
