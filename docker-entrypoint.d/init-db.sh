#!/bin/bash

export SQLITE3_FILE='/app/db.sqlite3'

read -r -d '' CREATE_STAT <<'EOF'
CREATE TABLE IF NOT EXISTS games (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    room_id TEXT NOT NULL UNIQUE,
    game_state TEXT NOT NULL
    );
EOF

sqlite3 "${SQLITE3_FILE}" "${CREATE_STAT}"
