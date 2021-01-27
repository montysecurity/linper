# To Do List

## Fixes

- Fix Perl
- Fix Node
- ~~Build crontab bash alias~~
- ~~Fix Python (how to get '"' around RHOST and SHELL?)~~
- ~~Fix PHP~~
- ~~Fix IRB~~
- ~~Fix JJS~~
- ~~Figure out why some methods work with systemctl and some don't~~
- ~~Fix/Supress `find: ‘/var/www’: No such file or directory` error in webserver poison function~~
- ~~Come up with a way to address the situation where SHELL is not set~~

## Enhancements

- expand sudo hijack attack to do the following
	- send the data as a POST parameter (to take advantage of HTTPS)
	- write sudo function to <b>all</b> writable bashrc files
- build `--cron` argument to supply custom schedules
- Expand clean option to remove any other tampers
- Automate web server poison attack (after fixing PHP)
- Finish adding GTFOBins
- Add pwsh
- Add create new user option
- Add make SSH key-pair option
- ~~Add /etc/rc.local startup persistence~~
- ~~Add /etc/skel/ backdoor~~
- ~~Add remove/cleanup function~~
- ~~Add stealth mode~~
