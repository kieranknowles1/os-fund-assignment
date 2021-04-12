#!/bin/bash

# Imports the metadata produced from disk_analysis into a database

# Parse parameters

while getopts ":i:d:" arg; do
	case $arg in
        #p)
        #    password="$OPTARG"
        #    ;;
        d)
            database="$OPTARG"
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

	exit 1
fi

# Connect to database and run script
mysql -u root -p $database < db_script.sql > sqlout.txt