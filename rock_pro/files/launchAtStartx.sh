#!/bin/bash

# if a conky instance is already running, kill it first
killall conky
# give system time to get ready, before starting conky
sleep 10
# start conky as background task
conky &

exit
