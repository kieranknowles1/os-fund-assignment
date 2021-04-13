#!/bin/bash

# Imports the metadata produced from disk_analysis into a database

# Parse parameters
db_user="root"

while getopts ":i:d:u:" arg; do
	case $arg in
        #p)
        #    password="$OPTARG"
        #    ;;
        d)
            database="$OPTARG"
            ;;
		u)
			db_user="$OPTARG"
			;;
		:)
			echo "Option -$OPTARG requires an argument.">&2
			exit 1
			;;
		\?)
			echo "Invalid option: -$OPTARG">&2
			exit 1
			;;
	esac
done

if [[ -z "$database" ]] ; then
	echo "Missing a required parameter">&2
	#echo -e "\t[REQUIRED] -p <pass> Password">&2   # mysql will ask user
	echo -e "\t[REQUIRED] -d <database> Database name">&2
	echo -e "\t[OPTIONAL] -u <user>=root Database user">&2

	exit 1
fi

# Connect to database and run script
echo "Enter password for $db_user"
mysql -u $db_user -p $database < db_script.sql > sqlout.txt