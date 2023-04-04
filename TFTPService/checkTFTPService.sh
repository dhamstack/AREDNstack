#!/bin/sh
# $Author: Daniel HB9HFM $
# $Date: 2023/03/23 11:55:57 $
# $Revision: 1.1 $
# $Source: checkTFTPService.sh,v $
# Don't forget to convert the line breaks to Unix mode!

function Help()
{
	echo "Usage: $1 [ -v | --verbose ]"
	exit 2
}

function LOGInformation ()
{
	if [ ${DEBUG:-test} = "true" ]
	then
		/bin/echo "-`/bin/date +%d.%m.%Y-%H:%M:%S`-: $1" | ${LOG}
	fi
}

function StatusTFTPPort()
{
	# Exist the Listener on the ${TFTPPort} port
	# Return code : 0 -> OK, 1 -> NOK
	Status=`/bin/netstat -tulpn | grep "0.0.0.0:${TFTPPort} "`
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
		     LOGInformation "Service DNSMasq is dead and pid file exist. Failure"
		     ;;
		"2") myRestartDNSMasqService="2"
		     LOGInformation "Service DNSMasq is dead and lock file exist. Failure"
			 ;;
		"3") myRestartDNSMasqService="3"
		     LOGInformation "Service DNSMasq is not running. Failure"
			 ;;
		"4") myRestartDNSMasqService="4"
		     LOGInformation "Service DNSMasq is unknown. Failure"
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
	# Check the configuration on the ${TFTPConfigFile} file
	# First occurence
	Status=`grep "config dnsmasq" ${TFTPConfigFile}`
	if [ "$?" = "0" ]
	then
		Config="0"
		LOGInformation "option dnsmasq was found in ${TFTPConfigFile}"
	else
		Config="1"
		LOGInformation "option dnsmasq was NOT found in ${TFTPConfigFile}"
	fi

	# 2nd occurence
	Status=`grep "option enable_tftp '1'" ${TFTPConfigFile}`
	if [ "$?" = "0" ]
	then
		Enable="0"
		LOGInformation "option enable_tftp '1' was found in ${TFTPConfigFile}"
	else
		Enable="1"
		LOGInformation "option enable_tftp '1' was NOT found in ${TFTPConfigFile}"
	fi

	# Third occurence
	Status=`grep "option tftp_root '/srv/tftp'" ${TFTPConfigFile}`
	if [ "$?" = "0" ]
	then
		TFTP="0"
		LOGInformation "option tftp_root '/srv/tftp' was found in ${TFTPConfigFile}"
	else
		TFTP="1"
		LOGInformation "option tftp_root '/srv/tftp' was NOT found in ${TFTPConfigFile}"
	fi

	# If the 3 lines and only the 3 lines are missing, then we add them
	if [ ${Config} = "1" ] && [ ${Enable} = "1" ] && [ ${TFTP} = "1" ]
	then
		AddTFTPConfiguration
	fi
}

function AddTFTPConfiguration()
{
	LOGInformation "Add the TFTP needed configuration in ${TFTPConfigFile} for DNSMasq"

# We add the 2 missing lines
cat << EOF >> ${TFTPConfigFile}
config dnsmasq
        option enable_tftp '1'
        option tftp_root '/srv/tftp'
EOF
}

function RemoveTempFile ()
{
	if [ ${DEBUG:-test} = "true" ]
	then
		rm -f ${LOGFile}
	fi
}


# Turn debuging information on or off
DEBUG=false

# Parse command line arguments
while [[ $# -gt 0 ]]
do
	case "$1" in
	-v | --verbose )
		DEBUG="true"
		shift
		;;
	-h | --help)
		Help $0
		;;
	*)
		echo "Unexpected option: $1"
		Help $0
		;;
	esac
done


# UDP Port from TFTP
TFTPPort=69
TFTPConfigFile=/etc/config/dhcp

# Create a temp file for debuging purpose only
if [ ${DEBUG:-test} = "true" ]
then
	LOGFile=`/bin/mktemp /tmp/$0.XXXXXX`
	# If DEBUG= true, Display on stdout and write to the log file at the same time
	LOG="/usr/bin/tee -a ${LOGFile}"
fi


# Check if there is a listener 
StatusTFTPPort
if [ "${myStatusTFTPPort}" = "1" ]
then
	# No listener
	
	# Exists the configuration in the file ?
	CheckTFTPConfiguration
	
	# DNSMasq tests its own configuration
	DNSMasqSyntaxCheck
	
	# Restart the service DNSMasq
	RestartDNSMasqService
	
	# Check if there is a listener 
	StatusTFTPPort
fi

# Delete the created LOG File
RemoveTempFile

# Exit with the state of the listener
# 0 : OK and running
# 1 : Failure
exit ${myStatusTFTPPort}
