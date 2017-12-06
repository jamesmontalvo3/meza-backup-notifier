Meza backup notifier
====================

Clone this repo anywhere onto a meza server, then add the following to root's crontab (with `sudo crontab -e`):

```
0 18 * * 0 /path/to/meza-backup-notifier/do-backup.sh
```

Note: the above assumes you want to do your backup at 18:00 on Sunday's. Lookup `crontab` for time settings.
