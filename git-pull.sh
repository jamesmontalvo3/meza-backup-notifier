#!/bin/sh

echo "Start meza backup notifier git pull"
echo $(date "+%Y-%m-%d %H:%M:%S")

if [ -z "$1" ]; then
	>&2 echo "Please set the desired branch name as first argument"
	exit 1;
else
	branch_name="$1"
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
NOTIFY="$DIR/slack-notify.sh"

set -e

cd /opt/conf-meza/public

COLOR="good"

# Set a default
DEPLOY_MEZA="no"
echo "Defaulting to not deploy"

public_git_status=$(git status --porcelain 2>&1)
if [ ! -z "$public_git_status" ]; then
	MESSAGE="Changes exist in local config-public respository. These must be fixed prior to automated updates.\n\ngit status:\n\n$(git status 2>&1)"
	COLOR="danger"
	echo "No deploy: changes exist locally"
else

	git_fetch=$(git fetch 2>&1)
	if [ ! -z "$git_fetch" ]; then
		MESSAGE="Fetching changes:\n$git_fetch\n\n"

		git_checkout_branch=$(git checkout "$branch_name" 2>&1)
		if [ ! "$(echo "$git_checkout_branch" | grep "Already on")" ]; then
			MESSAGE="$MESSAGE\n\n$git_checkout_branch"
		fi
		# MESSAGE="$MESSAGE\n\ngit checkout $branch_name:\n$git_checkout_branch"

		git_diff_origin=$(git diff "$branch_name..origin/$branch_name" 2>&1)
		if [ -z "$git_diff_origin" ]; then
			MESSAGE="$MESSAGE\n\nNo changes from $branch_name to origin/$branch_name"
			echo "No deploy: zero diff between local and origin"
		else
			MESSAGE="$MESSAGE\n\nThis server tracks the $branch_name branch. The following differences exist between $branch_name and origin/$branch_name:\n\`\`\`\n$git_diff_origin\n\`\`\`"
			git_reset_hard=$(git reset --hard "origin/$branch_name" 2>&1)
			MESSAGE="$MESSAGE\n\nMoving $branch_name to origin/$branch_name:\n$git_reset_hard"
			DEPLOY_MEZA="yes"
			echo "Deploying: changes exist"
		fi

	else
		# MESSAGE="No changes to config-public repository"
		echo "No deploy: no change to remote repository"
		exit 0;
	fi

fi


MESSAGE=$(echo "$MESSAGE" | sed "s/'/\\\'/g")
set +e
COLOR="$COLOR" MESSAGE="$MESSAGE" $NOTIFY
if [ $? -eq 0 ]; then
	echo "Slack notify success"
else
	echo "Slack notify fail"
	COLOR="$COLOR" MESSAGE="Failed to send initial slack notification" $NOTIFY
fi
set -e


if [ "$DEPLOY_MEZA" = "yes" ]; then
	DEPLOY_TYPE="Deploy" bash /opt/meza-backup-notifier/do-deploy.sh "" "deploy-after-config-change-"
fi

# public_git_diff=$(git diff)
# git_fetch_origin=$(git fetch origin)
# MESSAGE="$MESSAGE\n\ngit status:\n$public_git_status"
# MESSAGE="$MESSAGE\n\ngit diff:\n$public_git_diff"
# MESSAGE="$MESSAGE\n\nwipe out changes:\n$git_checkout\n\n"
# MESSAGE="$MESSAGE\n\nfetch origin:\n$git_fetch_origin"

# echo $public_git_status
# echo $public_git_diff

# Wipe out any changes
# git_checkout=$(git checkout -- .)

# Get the latest config
# git_fetch_origin=$(git fetch origin)
# git_checkout_branch=$(git checkout "$branch_name")
# git_reset_hard=$(git reset --hard "origin/$branch_name")
# git fetch origin
# git checkout "$branch_name"
# git reset --hard "origin/$branch_name"

# MESSAGE="$MESSAGE\n\nwipe out changes:\n$git_checkout\n\nfetch origin:\n$git_fetch_origin\n\ngit checkout $branch_name:\n$git_checkout_branch\n\ngit reset hard:\n$git_reset_hard"

# echo -e "COLOR = $COLOR\nMESSAGE = \n\n$MESSAGE"
# bash /opt/meza-backup-notifier/do-backup.sh "" "deploy-"


