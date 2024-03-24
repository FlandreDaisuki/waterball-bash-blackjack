#!/bin/bash

# REF: https://github.com/elhardoum/fcgiwrap-server/blob/9ad5b568/entrypoint.sh

# start fastcgiwrap
rm -f /var/run/fcgiwrap.socket
nohup fcgiwrap -s unix:/var/run/fcgiwrap.socket &
while ! [ -S /var/run/fcgiwrap.socket ]; do sleep .2; done
chown nginx:nginx /var/run/fcgiwrap.socket
