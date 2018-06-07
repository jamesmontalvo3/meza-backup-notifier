#!/bin/sh
#
# Do deploy. Notify on success. Notify and retry on fail.

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

if [ ! -z "$1" ]; then
	DEPLOY_ARGS="$1"
fi

if [ ! -z "$2" ]; then
	LOG_PREFIX="$2"
fi

meza deploy "$ENVIRONMENT" $DEPLOY_ARGS \
	> /opt/data-meza/logs/${LOG_PREFIX}`date "+%Y%m%d%H%M%S"`.log 2>&1 \
	&& $NOTIFY success \
	|| ( \
		($NOTIFY retry && meza deploy "$ENVIRONMENT" $DEPLOY_ARGS) \
		> /opt/data-meza/logs/${LOG_PREFIX}`date "+%Y%m%d%H%M%S"`.log 2>&1 \
		&& $NOTIFY success \
		|| $NOTIFY fail
	)
