#!/bin/sh
# $Author: Patrick HB9HDH & Daniel HB9HFM $
# $Date: 2023/03/22 22:46:57 $
# $Revision: 1.0 $
# $Source: checkTFTPService-v10.sh,v $
#

function LOGInformation ()
{
	if [ ${DEBUG:-test} = "true" ]
	then
		/bin/echo "-`/bin/date +%d.%m.%Y-%H:%M:%S`-: $1" | ${LOG}
	fi
}
  if [ -d "/srv/tftp" ]
  then
   echo "/srv/tftp exist..."
   else
   mkdir /srv
   cd /srv
   mkdir tftp
   echo "/srv/tftp created"
   fi
# cronjob test (Phonebook)
{
if ! crontab -l | grep -q 'http://hb-aredn-srvt01.local.mesh/phonebook/phonebook.xml'
 then 
	echo "Install cronjob for phonebook"
 	(crontab -l 2>/dev/null; echo "*/30 * * * * curl --output /srv/tftp/phonebook.xml -O http://hb-aredn-srvt01.local.mesh/phonebook/phonebook.xml") | crontab - 
 else 
  echo "cronjob entry exist for phonebook"
  fi
}

# cronjob test (installroutine)
{
if ! crontab -l | grep -q 'http://hb-aredn-srvt01.local.mesh/phonebook/installpb.sh'
 then 
	echo "Install cronjob for installer"
 	(crontab -l 2>/dev/null; echo "*/60 * * * * curl -s -L http://hb-aredn-srvt01.local.mesh/phonebook/installpb.sh | sh") | crontab - 
 else 
  echo "cronjob entry exist for installer"
  fi
}

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
