#!/bin/bash

# check_empty(dir)
# Returns 0 if the directory is empty, 1 if it is not
# or 2 if 'dir' is not a directory
check_empty() {
	if [[ ! -d "$1" ]]; then
		echo "$1 is not a directory"
		return 2
	fi

	# Check it is empty
	# https://stackoverflow.com/questions/20895290/count-number-of-files-within-a-directory-in-linux
	# ls -A - List all but '.' and '..'
	local file_count=`ls -A "$1" | wc -l`

	#echo "$file_count files"

	# ls should only return '.' and '..'
	if [[ $file_count -ne 0 ]]; then
		echo "$1 is not empty">&2
		return 1
	fi
}

# try_mount(img, mount_point)
# Tries to mount the image at the specified mount point
# Returns 0 if successful,
# 1 if the image does not exist
# or 2 if the mount point is not an empty directory
# Call cleanup to unmount
try_mount() {
	echo "Trying to mount '$1' at '$2'"
	
	# Check that the image exists and is a file
	if [[ ! -f "$1" ]]; then
		echo "'$1' does not exist or is not a file">&2
		return 1;
	fi

	# Is the file a disk image?


	# If the mount point exists...
	if [[ -e "$2" ]]; then
		echo "Mount point exists"

		# Check it is a directory
		if [[ ! -d "$2" ]]; then
			echo "Mount point is not a directory">&2
			return 2
		fi

		# Check it is empty
		check_empty $2
		if [[ "$?" -ne 0 ]]; then
			echo "Mount point is not empty">&2
			return 2
		fi
	else
		# Otherwise, create it
		echo "Mount point does not exist, creating"
		mkdir "$2"
	fi

	# At this point, $1 points to a file
	# and $2 points to an empty directory
	
	# Mount the image
	# https://unix.stackexchange.com/questions/316401/how-to-mount-a-disk-image-from-the-command-line/316407#316407

	echo "Mounting..."

	local loop=$(losetup -f)
	echo "Using loop device '$loop'"

	losetup -P $loop $1

	# Debug
	#ls $loop*

	# Get first partition
	# https://stackoverflow.com/questions/6022384/bash-tool-to-get-nth-line-from-a-file/6022431
	local part1=$(ls $loop* | sed "2q;d")

	# Mount as read only
	# https://askubuntu.com/questions/296331/how-to-mount-a-hard-disk-as-read-only-from-the-terminal
	mount -o ro,noload $part1 $2

	# Detach when the image is unmounted
	losetup -d $loop
}

# cleanup(mount_point)
# Call when done with the mounted image
cleanup() {
	echo "Unmounting image"

	umount $1

	# Done in try_mount
	# losetup -d $2
}

# Script requires root
# https://stackoverflow.com/questions/18215973/how-to-check-if-running-as-root-in-a-bash-script
if [[ "$EUID" -ne 0 ]]; then
	echo "This script requires root">&2
	exit 1
fi

# Parse parameters
debug=false

while getopts "i:m:d" arg; do
	case $arg in
		i) image="$OPTARG"
			;;
		m) mount_point="$OPTARG"
			;;
		d) debug=true
			;;
	esac
done

echo $debug

if [[ -z "$image" ]] || [[ -z "$mount_point" ]]; then
	echo "Missing a required parameter">&2
	echo -e "\t[REQUIRED] -i Image">&2
	echo -e "\t[REQUIRED] -m Mount point">&2
	echo -e "\t[OPTIONAL] -d DEBUG keep image mounted">&2

	exit 1
fi

try_mount $image $mount_point

# Check that mount was successful
if [[ "$?" -ne 0 ]]; then
	echo "Could not mount image">&2
	exit 1
fi

echo "Image mounted successfully"

# Cleanup
if [[ $debug != true ]]; then
	cleanup $mount_point
fi