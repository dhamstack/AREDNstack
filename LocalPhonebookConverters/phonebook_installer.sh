#!/bin/sh
# $Author: Patrick HB9HDH & Daniel HB9HFM & Andreas HB9BLA $
# $Date: 2023/07/19 $
# $Revision: 2.0 $
# $Source: checkTFTPService-v10.sh,v $
#

# Define the URL variable
#LOCATION_URL="http://hb9edi-apu-1.local.mesh"
LOCATION_URL="http://10.148.253.11"
INSTALLER_URL="/phonebook_installer.sh"
DOWNLOADER_URL="/phonebook_downloader.sh"
SETTINGS_URL="/settings.txt"

echo "$SETTINGS_URL"
echo "$DOWNLOADER_URL"

  echo "Download settings.txt"
  if [ ! -f "settings.txt" ]; then
	curl -o settings.txt "$LOCATION_URL$SETTINGS_URL"
	echo "settings.txt installed"
  else
	echo "settings.txt file already exists, skipping installation."
fi

  # Read Setttings File
  crontab_hour=$(grep 'crontab_hour=' /arednstack/phonebook/settings.txt | awk -F '=' '{print $2}')
  crontab_min=$(grep 'crontab_min=' /arednstack/phonebook/settings.txt | awk -F '=' '{print $2}')
  echo "The crontab hour is: $crontab_hour"
  echo "The crontab minute is: $crontab_min"
  echo


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
  
  echo "Install phonebook_downloader"  
  # curl -o phonebook_installer.sh "$LOCATION_URL$INSTALLER_URL"
  chmod +x phonebook_installer.sh
  echo "phonebook_downloader installed"
  echo
  
  echo "Download and execute phonebook_downloader"
  curl -o phonebook_downloader.sh "$LOCATION_URL$DOWNLOADER_URL"
  chmod +x phonebook_downloader.sh
  ./phonebook_downloader.sh
  echo "phonebook_downloader installed and executed"
  echo


# cronjob test (installroutine). It runs every day at
{
    if ! crontab -l | grep -q "${INSTALLER_URL}"; then
        echo "Install cronjob for installer"
        (crontab -l 2>/dev/null; echo "$crontab_min $crontab_hour * * * curl -s -L ${INSTALLER_URL} | sh") | crontab -
    else
        echo "cronjob entry exists for installer"
    fi
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
