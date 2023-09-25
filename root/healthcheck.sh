#!/bin/bash

# check to see if mrefd is listening on port 17000
lsof -i udp:${PORT}
