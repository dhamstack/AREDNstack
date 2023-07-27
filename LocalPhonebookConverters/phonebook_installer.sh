#!/bin/ash
# $Author: Patrick HB9HDH & Daniel HB9HFM & Andreas HB9BLA $
# $Date: 2023/07/22 $
# $Revision: 2.1 $
# $Source: checkTFTPService-v10.sh,v $
#

# Definitions
installer_file_name="phonebook_installer.sh"
DIRECT_CREATOR_FILE_NAME="phonebook_creator_direct.sh"
PBX_CREATOR_FILE_NAME="phonebook_creator_pbx.sh"
SETTINGS_FILE_NAME="settings.txt"

function LOGInformation ()
# The LOGInformation function takes a message as an argument and appends it to a log file
{
	if [ ${DEBUG:-test} = "true" ]
	then
		/bin/echo "-`/bin/date +%d.%m.%Y-%H:%M:%S`-: $1" | ${LOG}
	fi
}

echo
echo
echo
echo
echo ".................................PHONEBOOK INSTALLATION STARTS............."

# Remove all phonebook files from the www directory
rm /www/phonebook*.*
echo "All phonebook files from the www directory removed"
echo
echo


# Create directory for AREDN phonebook files
echo "......Create directory for AREDN phonebook files"
if [ -d "/arednstack/phonebook" ]
  then
   echo "Directory /arednstack/phonebook exist..."
   echo
   else
   mkdir /arednstack/
   cd /arednstack
   mkdir phonebook
   echo "/arednstack/phonebook created"
   echo
   echo
   location_url=$1
   echo "location_url $location_url"
fi
cd /arednstack/phonebook
  
# Download settings file
echo
echo
echo "......Download settings file"
if [ ! -f "/arednstack/phonebook/settings.txt" ]; then
    echo "DOWNLOAD $SETTINGS_FILE_NAME: $1$SETTINGS_FILE_NAME"
	curl -o /arednstack/phonebook/settings.txt "$1$SETTINGS_FILE_NAME"
	echo  >> settings.txt
#	echo "# Time when the phonebook is updated" >> /arednstack/phonebook/settings.txt
#	echo "crontab_hour=23" >> /arednstack/phonebook/settings.txt
#	echo "crontab_min=$((($(date '+%s')) % 59))" >> /arednstack/phonebook/settings.txt  # random minutes to avoid that all cronjobs run at the same time
	echo  >> settings.txt  #add aa blank line
	echo "#WEB Server" >> /arednstack/phonebook/settings.txt
    echo "location_url=$1" >> /arednstack/phonebook/settings.txt
	echo "$SETTINGS_FILE_NAME created"
  else
	echo "$SETTINGS_FILE_NAME file already exists, skipping download"
fi
echo
echo
echo "Here is your settings file:"
echo
cat /arednstack/phonebook/settings.txt
echo

# Read variables in setttings file
echo
echo
echo "......Read variables from setttings file"
location_url=$(grep 'location_url=' /arednstack/phonebook/settings.txt | awk -F '=' '{print $2}')
directory_direct=$(grep 'download_directory_direct=' /arednstack/phonebook/settings.txt | awk -F '=' '{print $2}'); directory_direct="${directory_direct:0:3}"
directory_pbx=$(grep 'download_directory_pbx=' /arednstack/phonebook/settings.txt | awk -F '=' '{print $2}'); directory_pbx="${directory_pbx:0:3}"
  
create_yealink=$(grep 'create_yealink=' /arednstack/phonebook/settings.txt | awk -F '=' '{print $2}'); create_yealink="${create_yealink:0:3}"
create_cisco=$(grep 'create_cisco=' /arednstack/phonebook/settings.txt | awk -F '=' '{print $2}'); create_cisco="${create_cisco:0:3}"
create_noname=$(grep 'create_noname=' /arednstack/phonebook/settings.txt | awk -F '=' '{print $2}'); create_noname="${create_noname:0:3}"
  
echo "Telephone books to create: ${create_yealink} ${create_cisco} ${create_noname}"
  
#crontab_hour=$(grep 'crontab_hour=' /arednstack/phonebook/settings.txt | awk -F '=' '{print $2}')
#crontab_min=$(grep 'crontab_min=' /arednstack/phonebook/settings.txt | awk -F '=' '{print $2}')
#crontab_hour=$((crontab_hour))
#crontab_min=$((crontab_min))
echo
  
# Download phonebook.csv
echo "......Download Phonebook.csv"
PHONEBOOK_URL="$location_url/AREDN_Phonebook.csv"
curl -o phonebook_original.csv "$PHONEBOOK_URL"
echo "Phonebook.csv downloaded"
echo
echo

echo "......DIRECT-call file creator download and execute: $directory_direct"
if [ $directory_direct == "YES" ]; then  
	echo "$location_url$DIRECT_CREATOR_FILE_NAME"
	curl -o $DIRECT_CREATOR_FILE_NAME "$location_url$DIRECT_CREATOR_FILE_NAME"
	chmod +x $DIRECT_CREATOR_FILE_NAME
	./$DIRECT_CREATOR_FILE_NAME $create_yealink $create_cisco $create_noname
	echo "Direct-call file creator executed"
	echo
	echo
  else
	echo "Direct-call file creator NOT executed"
	echo
	echo
fi
 
echo ".....PBX-call file creator download and execute: $directory_pbx"
if [ $directory_pbx == "YES" ]; then
	curl -o $PBX_CREATOR_FILE_NAME "$location_url$PBX_CREATOR_FILE_NAME"
	chmod +x $PBX_CREATOR_FILE_NAME
	./$PBX_CREATOR_FILE_NAME $create_yealink $create_cisco $create_noname
	echo "PBX-call file creator executed"
	echo
else
	echo "PBX-call file creator NOT executed"
	echo
fi

# crontab test (installroutine). It runs every day at
echo
echo
echo "......Crontab installation"
if ! crontab -l >/dev/null 2>&1; then
   echo "disregard the following error message"
fi

if ! crontab -l | grep -q "${installer_file_name}"; then
        (crontab -l 2>/dev/null; echo "$((($(date '+%s')) % 59)) 23 * * * /arednstack/phonebook/$installer_file_name") | crontab -
		echo "Crontab installed"
		echo
else
        echo "Crontab entry for installer exists"
		echo
fi
crontab -l
echo
