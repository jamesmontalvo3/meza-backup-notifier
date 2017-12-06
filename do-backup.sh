#!/bin/sh
#
# Do backup. Notify on success. Notify and retry on fail.

# Path to this file's directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Source config.sh if exists; else exit
if [ -f "$DIR/config.sh" ]; then
	source "$DIR/config.sh"
else
	echo
	echo "File 'config.sh' not found! Exiting." >&2; exit 1
fi

NOTIFY="$DIR/slack-notify.sh"

$NOTIFY start

meza deploy dkms --overwrite --skip-tags smw-data \
	> /opt/data-meza/logs/deploy-overwrite-`date "+\%Y\%m\%d\%H\%M\%S"`.log 2>&1 \
	&& $NOTIFY success \
	|| ( \
		($NOTIFY retry && meza deploy dkms --overwrite --skip-tags smw-data) \
		> /opt/data-meza/logs/deploy-overwrite-`date "+\%Y\%m\%d\%H\%M\%S"`.log 2>&1 \
		&& $NOTIFY success \
		|| $NOTIFY fail
	)
