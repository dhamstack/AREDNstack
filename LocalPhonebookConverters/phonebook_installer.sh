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
PHONEBOOK_URL="AREDN_Phonebook.csv"

echo
echo
echo
echo
echo
echo
echo "---------------START------------------"

# $1 is the address of the webserver
webserver=$1
echo "Download from $webserver"
echo
echo ".................................PHONEBOOK INSTALLATION STARTS............."


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
fi
cd /arednstack/phonebook
  
# Download settings file
echo "......Download settings file"
if [ ! -f "/arednstack/phonebook/settings.txt" ]; then
    echo "DOWNLOAD $SETTINGS_FILE_NAME: $webserver$SETTINGS_FILE_NAME"
	curl -o /arednstack/phonebook/settings.txt "$webserver$SETTINGS_FILE_NAME"
	echo "$SETTINGS_FILE_NAME created"
  else
	echo "$SETTINGS_FILE_NAME file already exists, skipping download"
fi
echo
echo
echo "Here is your settings file:"
echo "----------------------------"
cat /arednstack/phonebook/settings.txt
echo
echo "----------------------------"
echo
echo
# Read variables in setttings file
echo "......Read variables from setttings file"
create_directory_direct=$(grep 'create_directory_direct=' /arednstack/phonebook/settings.txt | awk -F '=' '{print $2}'); create_directory_direct="${create_directory_direct:0:3}"
create_directory_pbx=$(grep 'create_directory_pbx=' /arednstack/phonebook/settings.txt | awk -F '=' '{print $2}'); create_directory_pbx="${create_directory_pbx:0:3}"
  
create_yealink=$(grep 'create_yealink=' /arednstack/phonebook/settings.txt | awk -F '=' '{print $2}'); create_yealink="${create_yealink:0:3}"
create_cisco=$(grep 'create_cisco=' /arednstack/phonebook/settings.txt | awk -F '=' '{print $2}'); create_cisco="${create_cisco:0:3}"
create_noname=$(grep 'create_noname=' /arednstack/phonebook/settings.txt | awk -F '=' '{print $2}'); create_noname="${create_noname:0:3}"
  
echo "Telephone books to create: ${create_directory_direct} ${create_directory_pbx}"
echo "Telephone brands to serve: ${create_yealink} ${create_cisco} ${create_noname}"
echo
  
# Download phonebook.csv
echo "......Download Phonebook.csv"
curl -o phonebook_original.csv "$webserver$PHONEBOOK_URL"
echo "$webserver$PHONEBOOK_URL downloaded"
echo
echo

echo "......DIRECT-call file creator download and execute: $create_directory_direct"
if [ $create_directory_direct == "YES" ]; then  
	echo "$webserver$DIRECT_CREATOR_FILE_NAME"
	curl -o $DIRECT_CREATOR_FILE_NAME "$webserver$DIRECT_CREATOR_FILE_NAME"
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
 
echo ".....PBX-call file creator download and execute: $create_directory_pbx"
if [ $create_directory_pbx == "YES" ]; then
	curl -o $PBX_CREATOR_FILE_NAME "$webserver$PBX_CREATOR_FILE_NAME"
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
        (crontab -l 2>/dev/null; echo "$((($(date '+%s')) % 59)) 23 * * * curl $webserver$installer_file_name |sh -s $webserver") | crontab -
		echo "Crontab installed"
		echo
else
        echo "Crontab entry for installer exists"
		echo
fi
crontab -l
echo
echo

