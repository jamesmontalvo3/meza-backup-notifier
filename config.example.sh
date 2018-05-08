#!/bin/sh

# Slack channel to post message
CHANNEL="alerts-channel"

# Token used to access Slack team
TOKEN="token/generatedby/slack"

# Username to display
USERNAME="My Backup Server"

# Environment name
ENVIRONMENT="production"

# Anything that comes after environment on deploy
DEPLOY_ARGS="--overwrite --skip-tags smw-data,search-index"

# name of log file, minus the timestamp
LOG_PREFIX="deploy-overwrite-"

