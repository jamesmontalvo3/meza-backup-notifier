#!/bin/sh
#
# Send notification to slack on success or failure of backup
#
# Add this to crontab like:
# 0 18 * * 0 /opt/do-backup-overwrite.sh
#
# And create a `/opt/do-backup-overwrite.sh` file with:
#   #!/bin/sh
#   #
#   # Do backup with overwrite. Notify via slack on success or failure
#
#   meza deploy dkms --overwrite --skip-tags smw-data \
#     > /opt/data-meza/logs/deploy-overwrite-`date "+\%Y\%m\%d\%H\%M\%S"`.log 2>&1 \
#     && bash /opt/import-and-backup-slack-notifier.sh success \
#     || bash /opt/import-and-backup-slack-notifier.sh fail
#
# And put this file (that you're looking at now) at:
#   /opt/import-and-backup-slack-notifier.sh
#
# And make both scripts executable:
#   sudo chmod +x /opt/do-backup-overwrite.sh
#   sudo chmod +x /opt/import-and-backup-slack-notifier.sh
#

# Path to this file's directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Source config.sh if exists; else exit
if [ -f "$DIR/config.sh" ]; then
	source "$DIR/config.sh"
else
	echo
	echo "File 'config.sh' not found! Exiting." >&2; exit 1
fi

if [ "$1" = "success" ]; then
	MESSAGE="Backup complete"
	COLOR="good"
elif [ "$1" = "retry" ]; then
	MESSAGE="Backup attempt failed. Retrying."
	COLOR="warning"
else
	MESSAGE="Backup failed"
	COLOR="danger"
fi

ansible localhost -m slack -a \
	"token=$TOKEN \
	channel=$CHANNEL \
	msg='$MESSAGE' \
	username='$USERNAME' \
	icon_url=https://github.com/enterprisemediawiki/meza/raw/master/src/roles/configure-wiki/files/logo.png \
	link_names=1 \
	color=$COLOR"
