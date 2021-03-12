#!/bin/bash

# check_empty(dir)
# Returns 0 if the directory is empty, 1 if it is not
# or 2 if 'dir' is not a directory
check_empty() {
	if [ ! -d "$1" ]; then
		echo "$1 is not a directory"
		return 2
	fi

	# Check it is empty
	# https://stackoverflow.com/questions/20895290/count-number-of-files-within-a-directory-in-linux
	# ls -A - List all but '.' and '..'
	local file_count=`ls -A "$1" | wc -l`

	#echo "$file_count files"

	# ls should only return '.' and '..'
	if [ $file_count -ne 0 ]; then
		echo "$1 is not empty">&2
		return 1
	fi
}

# try_mount(img, mount_point)
# Tries to mount the image at the specified mount point
# Returns 0 if successful,
# 1 if the image does not exist
# or 2 if the mount point is not an empty directory
try_mount() {
	echo "Trying to mount '$1' at '$2'"
	
	# Check that the image exists and is a file
	if [ ! -f "$1" ]; then
		echo "'$1' does not exist or is not a file">&2
		return 1;
	fi

	# If the mount point exists...
	if [ -e "$2" ]; then
		echo "Mount point exists"

		# Check it is a directory
		if [ ! -d "$2" ]; then
			echo "Mount point is not a directory">&2
			return 2
		fi

		# Check it is empty
		check_empty $2
		if [ "$?" -ne 0 ]; then
			echo "Mount point is not empty">&2
			return 2
		fi
	else
		# Otherwise, create it
		echo "Mount point does not exist, creating"
		mkdir "$2"
		return 0
	fi

	# At this point, $1 points to a file
	# and $2 points to an empty directory
}


# Check that the right number of arguments were provided
# https://stackoverflow.com/questions/4341630/checking-for-the-correct-number-of-arguments
if [ "$#" -ne 2 ]; then
	# Echo to stderr
	echo "Usage: $0 image mount_point">&2
	exit 1
fi

image=$1
mount_point=$2

try_mount $image $mount_point

# Check that mount was successful
if [ "$?" -ne 0 ]; then
	echo "Could not mount image">&2
	exit 1
fi


# Cleanup

