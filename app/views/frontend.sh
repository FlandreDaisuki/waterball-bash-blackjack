#!/bin/bash

set -e

GAME_STATE=''
export GAME_STATE

GAME_STATE_PATH="$(mktemp)"
export GAME_STATE_PATH

UPDATE_SIG='SIGRTMIN+1'
export UPDATE_SIG

#region variables replaced by entry

GAME_ID=
export GAME_ID

JWT_TOKEN=
export JWT_TOKEN

BACKEND_BASE_URI=
export BACKEND_BASE_URI

#endregion variables replaced by entry

#region functions

function echo_err {
  # REF: https://stackoverflow.com/a/2990533
  printf "%s\n" "$*" >&2
}
export -f echo_err

function get_own_pid {
  # REF: https://stackoverflow.com/a/73997213
  cut -d' ' -f4 </proc/self/stat |
    xargs -I% sh -c 'cut -d" " -f4 < /proc/%/stat'
}
export -f get_own_pid

function get_parent_pid {
  # REF: https://stackoverflow.com/a/73997213
  cut -d' ' -f4 </proc/self/stat |
    xargs -I% sh -c 'cut -d" " -f4 < /proc/%/stat' |
    xargs -I% sh -c 'cut -d" " -f4 < /proc/%/stat'
}
export -f get_parent_pid

# usage: is_game_global_counter_pattern "${REQUEST_QUERY_I}"
function is_game_global_counter_pattern {
  echo "${1}" | grep -q '^-\?[0-9]\+$'
}
export -f is_game_global_counter_pattern

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
export -f get_game_global_counter

# usage: should_update_game_state "${NEW_GAME_STATE}"
function should_update_game_state {
  if [ -z "${GAME_STATE}" ]; then
    return 0
  fi

  NEW_GAME_STATE="${1}"
  CURRENT_I="$(get_game_global_counter "${GAME_STATE}")"
  NEW_I="$(get_game_global_counter "${NEW_GAME_STATE}")"

  if [ "${CURRENT_I}" != "${NEW_I}" ]; then
    return 0
  fi

  return 1
}
export -f should_update_game_state

function update_game_state {
  GAME_STATE="$(jq -cr '.' "${GAME_STATE_PATH}")"
}

function bg_long_polling_game_state {
  local CURRENT_I
  while true; do
    CURRENT_I="$(get_game_global_counter "${GAME_STATE}")"

    NEW_GAME_STATE="$(
      curl -sL "${BACKEND_BASE_URI}/games/${GAME_ID}?i=${CURRENT_I}" \
        -H "Authorization: Bearer ${JWT_TOKEN}"
    )"

    if should_update_game_state "${NEW_GAME_STATE}"; then
      echo "${NEW_GAME_STATE}" | tee "${GAME_STATE_PATH}"
      update_game_state
      kill -s "${UPDATE_SIG}" "$(get_parent_pid)"
    fi
  done
}

#endregion functions

#region main game flow

if [ -z "${JWT_TOKEN}" ]; then
  echo_err 'Your JWT token is invalid'
  exit 1
fi

if [ -z "${GAME_ID}" ]; then
  echo_err 'Your game id is invalid'
  exit 2
fi

bg_long_polling_game_state &
trap update_game_state "${UPDATE_SIG}"

# REF: https://stackoverflow.com/a/360275
trap 'kill $(jobs -p)' EXIT

echo 'Welcome to Waterball Bash Blackjack!'

while true; do
  sleep 0.1
done

#endregion main game flow
