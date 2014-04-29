#!/bin/sh

#check if run as root
if [ "$UID" -ne 0 ]; then
	/bin/echo "Sudo me!"
	exit 1
fi

defaultFilePath="/Library/LaunchDaemons/com.bombich.ccc.scheduledtask."	# default path of CCC configuration file
taskName=""	# name of the task to kick start, supplied by script argument
fullFileName=""	# full path to the file being processed

# process arguments
while [ "$1" ]; do
	case "$1" in
		"-name")
			shift 1
			taskName="$1"
			shift 1
			;;
		*)
			shift 1
			;;
	esac
done

# abort if no task name is specified
if [ ! "$taskName" ]; then
	/bin/echo "Abort: No task name specified.";
	exit 1;
fi

# loop through all CCC configuration files
for oneTask in `/bin/ls /Library/LaunchDaemons/com.bombich.ccc.scheduledtask.* | awk -F. '{print $5}'`
do
	fullFileName="$defaultFilePath$oneTask.plist"
	currentTaskName=`/usr/libexec/PlistBuddy -c "Print :cccTaskDict:cccTaskName" "$fullFileName"`
	
	if [ "$currentTaskName" == "$taskName" ]; then	# compare task name
		taskStatus=`/usr/bin/defaults read $fullFileName Disabled`
		if [ $taskStatus -eq 0 ]; then	# make sure task is disabled before loading
			/bin/echo "Abort: Specified task is already enabled.";
			exit 1;
		else
			/usr/bin/defaults write "$fullFileName" Disabled -bool NO
			/bin/echo "Kickstart: $fullFileName"
			/bin/launchctl load "$fullFileName"
		fi
	fi
done

exit 0

# by Tony S. Wu
# http://houseofmac.wordpress.com