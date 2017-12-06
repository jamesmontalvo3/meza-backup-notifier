#!/bin/sh
#
# Do backup. Notify on success. Notify and retry on fail.

# Path to this file's directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

NOTIFY="$DIR/slack-notify.sh"

meza deploy dkms --overwrite --skip-tags smw-data \
	> /opt/data-meza/logs/deploy-overwrite-`date "+\%Y\%m\%d\%H\%M\%S"`.log 2>&1 \
	&& $NOTIFY success \
	|| ( \
		($NOTIFY retry && meza deploy dkms --overwrite --skip-tags smw-data) \
		> /opt/data-meza/logs/deploy-overwrite-`date "+\%Y\%m\%d\%H\%M\%S"`.log 2>&1 \
		&& $NOTIFY success \
		|| $NOTIFY fail
	)
