# linper countermeasures

in an effort to teach myself linux hardening, this will document ways to detect/prevent/stop linper (and by extension - some reverse shells)

of course, this is not all-inclusive and there is always a way around defenses. always.

## tripwire policies

```
#
# Commonly used for persistence
#
(
  rulename = "Persistence Mechanisms",
  severity = $(SIG_HI)
)
{
        #
        # Author: montysecurity
        # montysecurity@protonmail.com
        # twitter.com/_montysecurity
        #
        # Pulled from the research I am doing to build linper
        # Will be updated as linper grows; not all-inclusive
        #
        # https://github.com/montysecurity/linper/
        #

        /etc/systemd/system             -> $(SEC_CRIT);
        /etc/skel                       -> $(SEC_CRIT);
        /etc/rc.local                   -> $(SEC_CONFIG);
        /etc/crontab                    -> $(SEC_CONFIG);
        /etc/cron.d                     -> $(SEC_CRIT);
        /etc/cron.daily                 -> $(SEC_CRIT);
        /etc/cron.hourly                -> $(SEC_CRIT);
        /etc/cron.monthly               -> $(SEC_CRIT);
        /etc/cron.weekly                -> $(SEC_CRIT);
        /var/spool/cron/crontabs        -> $(SEC_CONFIG);
        /home/monty/.bashrc             -> $(SEC_CONFIG); # Change me

        #
        # Commented out becuase they are defined in other policies
        # Keeping for standalone template
        #
        # /root/.bashrc                 -> $(SEC_CONFIG);
        # /etc/passwd                   -> $(SEC_CONFIG);
        # /etc/shadow                   -> $(SEC_CONFIG);

        #
        # Commented out because it is limited to running web servers
        #
        # /var/www                      -> $(SEC_CRIT);
}
```
