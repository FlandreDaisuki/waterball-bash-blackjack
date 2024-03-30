# waterball-bash-blackjack

## Game flow

```mermaid
graph TB
    NG((New Game)) --> IG[Init Game]
    IG --> IR[Init Round]
    IR --> T0[Player0 turn]

    T0 --> D00[[Bet? Surrender?]]
    D00 --> D01{Hit? Stand?}
    D01 --> D01
    D01 --> T1[Player1 turn]

    T1 --> D10[[Bet? Surrender?]]
    D10 --> D11{Hit? Stand?}
    D11 --> D11
    D11 --> T2[Player2 turn]

    T2 --> D20[[Bet? Surrender?]]
    D20 --> D21{Hit? Stand?}
    D21 --> D21
    D21 --> T3[Player3 turn]

    T3 --> D30[[Bet? Surrender?]]
    D30 --> D31{Hit? Stand?}
    D31 --> D31
    D31 --> TD[Dealer turn]

    TD --> DD0{Hit? Stand?}
    DD0 --> DD0
    DD0 --> TDE[Show dealer's card]

    TDE --> S[Settling]
    S --> DEG{Should End Game}
    DEG -- Y --> EG((End Game))
    DEG -- N --> IR
```

## APIs

### `/api/games`

房主點下開始遊戲之後，會從平台送遊戲資訊過來

```shell
ROOM_OWNER_JWT='eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImlrN3l5VkpoM3pFSW1hLWduZ2lTRCJ9.eyJpc3MiOiJodHRwczovL2Rldi0xbDBpeGp3OHlvaHNsdW9pLnVzLmF1dGgwLmNvbS8iLCJzdWIiOiJvYXV0aDJ8ZGlzY29yZHw1MzYxMjYwODkyMDcyMTgxNzciLCJhdWQiOlsiaHR0cHM6Ly9hcGkuZ2Fhcy53YXRlcmJhbGxzYS50dyIsImh0dHBzOi8vZGV2LTFsMGl4anc4eW9oc2x1b2kudXMuYXV0aDAuY29tL3VzZXJpbmZvIl0sImlhdCI6MTcxMTI4ODE2MiwiZXhwIjoxNzExMjkxNzYyLCJzY29wZSI6Im9wZW5pZCBwcm9maWxlIGVtYWlsIG9mZmxpbmVfYWNjZXNzIiwiYXpwIjoiMFo3aG5EbGQ1dHJQcWkydjBsbG9CWTc0TUhkRFlHRXkifQ.jpSF0U0Dq2DScWj9G5NRTBpqDiPPgdqZbjZiaH-Gd74GzWC54EQtvF_rahNkxKdoqqRME0wihWO8q3I1z0QhEQEJu1Tg5BTjBMjflpOSXxEY4BqV7LZVo7aOR8xjC-yNls-5eBjTZ8kAhcIU-x4uRVhPf4qpc3VigW-hEiNu3tq--zMEZFyYotgOA1t5hbUUgIB3xQuKATWP5XLIf1HqZWXjLNM7MVCn7UMKwQ2qsfd1bdwotAmLMEIm6W9i5nPs--KJfEfilqkyNqjW3QGFNyqYN_BG8dfSt84lpMuvvyS6LqFVL69pyyKEPrn1WGPqapOgMhIbM_0rgWHbT-nbLw'

curl 'http://localhost/api/games' -X POST \
  -H "Authorization: Bearer ${ROOM_OWNER_JWT}" \
  -H "Content-Type: application/json" \
  --data-raw '{"roomId":"room_385abe92e39a3","players":[{"id":"6497f6f226b40d440b9a90cc","nickname":"板橋金城武"},{"id":"6498112b26b40d440b9a90ce","nickname":"三重彭于晏"},{"id":"6499df157fed0c21a4fd0425","nickname":"蘆洲劉德華"},{"id":"649836ed7fed0c21a4fd0423","nickname":"永和周杰倫"}]}'
```
