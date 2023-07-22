#!/bin/sh
# $Author: Patrick HB9HDH & Daniel HB9HFM & Andreas HB9BLA $
# $Date: 2023/07/19 $
# $Revision: 2.0 $
# $Source: checkTFTPService-v10.sh,v $
#

# Define the URL variable
#LOCATION_URL="http://hb9edi-apu-1.local.mesh/"
#LOCATION_URL="http://10.148.253.11/"
LOCATION_URL="http://10.55.47.91/"
INSTALLER_URL="phonebook_installer.sh"
DIRECT_CREATOR_FILE_NAME="phonebook_creator_direct.sh"
PBX_CREATOR_FILE_NAME="phonebook_creator_pbx.sh"
SETTINGS_FILE_NAME="settings.txt"
echo
echo
echo
echo
echo "PHONEBOOK INSTALLATION STARTS............."
echo "Download server address: $LOCATION_URL"

  echo
  echo "DOWNLOAD $SETTINGS_FILE_NAME"
  if [ ! -f "settings.txt" ]; then
	curl -o settings.txt "$LOCATION_URL$SETTINGS_FILE_NAME"
	echo "$SETTINGS_FILE_NAME downloaded"
  else
	echo "$SETTINGS_FILE_NAME file already exists, skipping download"
fi
echo
echo

# Remove all phonebook files from the www directory
echo "Remove all phonebook files from the www directory"
rm /www/phonebook*.*
echo
echo


  # Read Setttings File
  directory_direct=$(grep 'download_directory_direct=' /arednstack/phonebook/settings.txt | awk -F '=' '{print $2}'); directory_direct="${directory_direct:0:3}"
  directory_pbx=$(grep 'download_directory_pbx=' /arednstack/phonebook/settings.txt | awk -F '=' '{print $2}'); directory_pbx="${directory_pbx:0:3}"
  
  create_yealink=$(grep 'create_yealink=' /arednstack/phonebook/settings.txt | awk -F '=' '{print $2}'); create_yealink="${create_yealink:0:3}"
  create_cisco=$(grep 'create_cisco=' /arednstack/phonebook/settings.txt | awk -F '=' '{print $2}'); create_cisco="${create_cisco:0:3}"
  create_noname=$(grep 'create_noname=' /arednstack/phonebook/settings.txt | awk -F '=' '{print $2}'); create_noname="${create_noname:0:3}"
  
  echo $create_yealink $create_cisco $create_noname
  
  crontab_hour=$(grep 'crontab_hour=' /arednstack/phonebook/settings.txt | awk -F '=' '{print $2}')
  crontab_min=$(grep 'crontab_min=' /arednstack/phonebook/settings.txt | awk -F '=' '{print $2}')
  crontab_hour=$((crontab_hour))
  crontab_min=$((crontab_min))


function LOGInformation ()
# The LOGInformation function takes a message as an argument and appends it to a log file
{
	if [ ${DEBUG:-test} = "true" ]
	then
		/bin/echo "-`/bin/date +%d.%m.%Y-%H:%M:%S`-: $1" | ${LOG}
	fi
}

# Create directory for AREDN phonebook files
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
  
  
  echo "Download and install $INSTALLER_URL"  
  #curl -o phonebook_installer.sh "$LOCATION_URL$INSTALLER_URL"
  chmod +x phonebook_installer.sh
  echo "$INSTALLER_URL installed"
  echo
  echo
  
# Download phonebook.csv
PHONEBOOK_URL="$LOCATION_URL/AREDN_Phonebook.csv"
curl -o phonebook_original.csv "$PHONEBOOK_URL"
  
  if [ $directory_direct == "YES" ]; then  
	echo "DIRECT call file creator download and execute: $directory_direct"
	echo "$LOCATION_URL$DIRECT_CREATOR_FILE_NAME"
	curl -o $DIRECT_CREATOR_FILE_NAME "$LOCATION_URL$DIRECT_CREATOR_FILE_NAME"
	chmod +x $DIRECT_CREATOR_FILE_NAME
	./$DIRECT_CREATOR_FILE_NAME $create_yealink $create_cisco $create_noname
	echo "Direct call file creator executed"
	echo
	echo
  else
	echo "Direct call file creator NOT installed"
	echo
	echo
  fi
  
  if [ $directory_pbx == "YES" ]; then
	echo "PBX call file creator download and execute: $directory_pbx"
	curl -o $PBX_CREATOR_FILE_NAME "$LOCATION_URL$PBX_CREATOR_FILE_NAME"
	chmod +x $PBX_CREATOR_FILE_NAME
	./$PBX_CREATOR_FILE_NAME $create_yealink $create_cisco $create_noname
	echo "PBX Creator file creator executed"
	echo
 else
	echo "PBX call file creator NOT installed"
	echo
 fi

# cronjob test (installroutine). It runs every day at
{
    if ! crontab -l | grep -q "${INSTALLER_URL}"; then
        echo "Install cronjob for installer"
        (crontab -l 2>/dev/null; echo "$crontab_min $crontab_hour * * * curl -s -L ${INSTALLER_URL} | sh") | crontab -
    else
        echo "cronjob entry exists for installer"
		echo
    fi
    echo "The crontab job will run at: $crontab_hour:$crontab_min"
    echo
    echo
}


# Make TFTP run (might not be needed in the future)

function StatusTFTPPort()
{
	Status=`/bin/netstat -tulpn | grep ":${TFTPPort} "`
	if [ "$?" = "0" ]
	then
		myStatusTFTPPort="0"
		LOGInformation "Service ${TFTPPort} is running"
	else
		myStatusTFTPPort="1"
		LOGInformation "Service ${TFTPPort} is NOT running"
	fi
}

function RestartDNSMasqService()
{
	Status=`/etc/init.d/dnsmasq restart 2> /dev/null`	
	case $? in
		"0") myRestartDNSMasqService="0"
		     LOGInformation "Service DNSMasq was successfuly restarted"
		     ;;
		"1") myRestartDNSMasqService="1"
		     LOGInformation "Service DNSMasq was NOT restarted. Failure"
		     ;;
		"2") myRestartDNSMasqService="2"
		     ;;
	esac
}

function DNSMasqSyntaxCheck()
{
	# dnsmasq -C /etc/config/dhcp  --test
	Status=`dnsmasq --test 2> /dev/null`	
	case $? in
		"0") myDNSMasqSyntaxCheck="0"
		     LOGInformation "${TFTPConfigFile} was successfuly checked"
		     ;;
		"1") myDNSMasqSyntaxCheck="1"
		     LOGInformation "${TFTPConfigFile} reported a syntax failure"
		     ;;
	esac
}

function CheckTFTPConfiguration()
{
	Status=`grep "config dnsmasq" ${TFTPConfigFile}`
	if [ "$?" = "0" ]
	then
		Config="0"
		LOGInformation "option dnsmasq was found in ${TFTPConfigFile}"
	else
		Config="1"
		LOGInformation "option dnsmasq was NOT found in ${TFTPConfigFile}"
	fi

	Status=`grep "option enable_tftp '1'" ${TFTPConfigFile}`
	if [ "$?" = "0" ]
	then
		Enable="0"
		LOGInformation "option enable_tftp '1' was found in ${TFTPConfigFile}"
	else
		Enable="1"
		LOGInformation "option enable_tftp '1' was NOT found in ${TFTPConfigFile}"
	fi

	Status=`grep "option tftp_root '/srv/tftp'" ${TFTPConfigFile}`
	if [ "$?" = "0" ]
	then
		TFTP="0"
		LOGInformation "option tftp_root '/srv/tftp' was found in ${TFTPConfigFile}"
	else
		TFTP="1"
		LOGInformation "option tftp_root '/srv/tftp' was NOT found in ${TFTPConfigFile}"
	fi

	if [ ${Config} = "1" ] && [ ${Enable} = "1" ] && [ ${TFTP} = "1" ]
	then
		AddTFTPConfiguration
	fi
}

function AddTFTPConfiguration()
{
	LOGInformation "Add the TFTP needed configuration in ${TFTPConfigFile} for DNSMasq"

cat << EOF >> ${TFTPConfigFile}
config dnsmasq
        option enable_tftp '1'
        option tftp_root '/srv/tftp'
EOF
}

function RemoveTempFile ()
{
	rm -f ${LOGFile}
}

DEBUG=true

TFTPPort=69
TFTPConfigFile=/etc/config/dhcp

LOGFile=`/bin/mktemp /tmp/$0.XXXXXX`
LOG="/usr/bin/tee -a ${LOGFile}"


StatusTFTPPort
if [ "${myStatusTFTPPort}" = "1" ]
then
	CheckTFTPConfiguration
	DNSMasqSyntaxCheck
	RestartDNSMasqService
	StatusTFTPPort
fi

RemoveTempFile

exit ${myStatusTFTPPort}
