#!/bin/ash
# $Author: Patrick HB9HDH & Daniel HB9HFM & Andreas HB9BLA $
# $Date: 2023/07/22 $
# $Revision: 2.1 $
# $Source: checkTFTPService-v10.sh,v $
#

# Definitions
INSTALLER_URL="phonebook_installer.sh"
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
echo "Remove all phonebook files from the www directory"
rm /www/phonebook*.*
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
echo "DOWNLOAD $SETTINGS_FILE_NAME: $1$SETTINGS_FILE_NAME"
if [ ! -f "/arednstack/phonebook/settings.txt" ]; then
	curl -o /arednstack/phonebook/settings.txt "$1$SETTINGS_FILE_NAME"
	echo  >> settings.txt
	echo "#WEB Server" >> settings.txt
    echo "location_url=$1" >> settings.txt
	echo "$SETTINGS_FILE_NAME downloaded"
  else
	echo "$SETTINGS_FILE_NAME file already exists, skipping download"
fi
echo
echo
echo "Settings file"
echo
cat /arednstack/phonebook/settings.txt
echo
echo


# Read variables in setttings file
echo
echo
echo "......Read variables in setttings file"
location_url=$(grep 'location_url=' /arednstack/phonebook/settings.txt | awk -F '=' '{print $2}')
directory_direct=$(grep 'download_directory_direct=' /arednstack/phonebook/settings.txt | awk -F '=' '{print $2}'); directory_direct="${directory_direct:0:3}"
directory_pbx=$(grep 'download_directory_pbx=' /arednstack/phonebook/settings.txt | awk -F '=' '{print $2}'); directory_pbx="${directory_pbx:0:3}"
  
create_yealink=$(grep 'create_yealink=' /arednstack/phonebook/settings.txt | awk -F '=' '{print $2}'); create_yealink="${create_yealink:0:3}"
create_cisco=$(grep 'create_cisco=' /arednstack/phonebook/settings.txt | awk -F '=' '{print $2}'); create_cisco="${create_cisco:0:3}"
create_noname=$(grep 'create_noname=' /arednstack/phonebook/settings.txt | awk -F '=' '{print $2}'); create_noname="${create_noname:0:3}"
  
echo "Telehone books to create $create_yealink $create_cisco $create_noname"
  
crontab_hour=$(grep 'crontab_hour=' /arednstack/phonebook/settings.txt | awk -F '=' '{print $2}')
crontab_min=$(grep 'crontab_min=' /arednstack/phonebook/settings.txt | awk -F '=' '{print $2}')
crontab_hour=$((crontab_hour))
crontab_min=$((crontab_min))
echo
echo "Location_url from settings.txt $location_url"

  
# Download and install phonebook_installer.sh
echo
echo
echo "......Download and install $location_url$INSTALLER_URL"  
curl -o phonebook_installer.sh "$location_url$INSTALLER_URL"
chmod +x phonebook_installer.sh
echo "$INSTALLER_URL installed"
echo
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
echo "......Install crontab"
if ! crontab -l | grep -q "${INSTALLER_URL}"; then
        echo "Install cronjob for installer"
        (crontab -l 2>/dev/null; echo "$crontab_min $crontab_hour * * * curl -s -L ${INSTALLER_URL} | sh") | crontab -
else
        echo "cronjob entry exists for installer"
		echo
fi
echo "The crontab job will run at: $crontab_hour:$crontab_min"
echo
