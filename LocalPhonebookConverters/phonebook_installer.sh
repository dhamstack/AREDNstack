#!/bin/ash
# $Author: Patrick HB9HDH & Daniel HB9HFM & Andreas HB9BLA $
# $Date: 2023/08/08 $
# $Revision: 3.0 $
#


# Definitions
installer_file_name="phonebook_installer.sh"
DIRECT_CREATOR_FILE_NAME="phonebook_creator_direct.sh"
PBX_CREATOR_FILE_NAME="phonebook_creator_pbx.sh"
SETTINGS_FILE_NAME="settings.txt"
PHONEBOOK_URL="AREDN_Phonebook.csv"
CRON_FILE_NAME="/etc/cron.daily/download_phonebook"

# Function to generate XML files for direct calling
generate_phonebooks_direct() {
	if [ $create_yealink == "YES" ]; then
	  output_file1="/www/phonebook_yealink_direct.xml"
	  echo "<YealinkIPPhoneDirectory>" > "$output_file1"
	fi
	if [ $create_cisco == "YES" ]; then
	  output_file2="/www/phonebook_cisco_direct.xml"
	  echo "<CiscoIPPhoneDirectory>" > "$output_file2"
	fi
	if [ $create_noname == "YES" ]; then
	  output_file3="/www/phonebook_noname_direct.xml"
	  echo "<GigasetIPPhoneDirectory>" > "$output_file3"
	fi

	# Read the input file line by line
	while IFS="," read -r first_name name callsign ip_address telephone email club mobile street City; do
		line_number=$((line_number+1))
		
		# Skip the header line
		if [ "$line_number" -le 1 ]; then
			continue
		fi

		# Write the XML structure for Yealink
		if [ $create_yealink == "YES" ]; then
			echo "    <DirectoryEntry>" >> "$output_file1"
			echo "        <Name>$name $first_name $callsign</Name>" >> "$output_file1"
			echo "        <Telephone>$ip_address</Telephone>" >> "$output_file1"
			echo "    </DirectoryEntry>" >> "$output_file1"
		fi
		
		# Write the XML structure for Cisco
		if [ $create_cisco == "YES" ]; then
		  echo "    <DirectoryEntry>" >> "$output_file2"
		  echo "        <Name>$name $first_name $callsign</Name>" >> "$output_file2"
		  echo "        <Telephone>$ip_address</Telephone>" >> "$output_file2"
		  echo "    </DirectoryEntry>" >> "$output_file2"
		fi
		
		# Write the XML structure for Noname
		if [ $create_noname == "YES" ]; then
		  echo "    <DirectoryEntry>" >> "$output_file3"
		  echo "        <Name>$first_name $name $callsign</Name>" >> "$output_file3"
		  echo "        <Telephone>$ip_address</Telephone>" >> "$output_file3"
		  echo "    </DirectoryEntry>" >> "$output_file3"
		fi
	done < "$input_file"

	# Close the XML structure
	if [ $create_yealink == "YES" ]; then
	  echo "</YealinkIPPhoneDirectory>" >> "$output_file1"
	  echo "Conversion completed. Output file: $output_file1"
	fi

	if [ $create_cisco == "YES" ]; then
	  echo "</CiscoIPPhoneDirectory>" >> "$output_file2"
	  echo "Conversion completed. Output file: $output_file2"
	fi

	if [ $create_noname == "YES" ]; then
	  echo "</GigasetIPPhoneDirectory>" >> "$output_file3"
	  echo "Conversion completed. Output file: $output_file3"
	fi
}

# Function to generate XML files for direct calling
generate_phonebooks_pbx() {
	if [ $create_yealink == "YES" ]; then
	  output_file1="/www/phonebook_yealink_pbx.xml"
	  echo "<YealinkIPPhoneDirectory>" > "$output_file1"
	fi
	if [ $create_cisco == "YES" ]; then
	  output_file2="/www/phonebook_cisco_pbx.xml"
	  echo "<CiscoIPPhoneDirectory>" > "$output_file2"
	fi
	if [ $create_noname == "YES" ]; then
	  output_file3="/www/phonebook_noname_pbx.xml"
	  echo "<GigasetIPPhoneDirectory>" > "$output_file3"
	fi

	# Read the input file line by line
	while IFS="," read -r first_name name callsign ip_address telephone email club mobile street City; do
		line_number=$((line_number+1))
		
		# Skip the header line
		if [ "$line_number" -le 1 ]; then
			continue
		fi

		# Write the XML structure for file1
		if [ $create_yealink == "YES" ]; then
		  echo "    <DirectoryEntry>" >> "$output_file1"
		  echo "        <Name>$name $first_name $callsign</Name>" >> "$output_file1"
		  echo "        <Telephone>$telephone</Telephone>" >> "$output_file1"
		  echo "    </DirectoryEntry>" >> "$output_file1"
		fi
		
		# Write the XML structure for file2
		if [ $create_cisco == "YES" ]; then
		  echo "    <DirectoryEntry>" >> "$output_file2"
		  echo "        <Name>$name $first_name $callsign</Name>" >> "$output_file2"
		  echo "        <Telephone>$telephone</Telephone>" >> "$output_file2"
		  echo "    </DirectoryEntry>" >> "$output_file2"
		fi
		
		# Write the XML structure for file3
		if [ $create_noname == "YES" ]; then
		  echo "    <DirectoryEntry>" >> "$output_file3"
		  echo "        <Name>$first_name $name $callsign</Name>" >> "$output_file3"
		  echo "        <Telephone>$telephone</Telephone>" >> "$output_file3"
		  echo "    </DirectoryEntry>" >> "$output_file3"
		fi
	done < "$input_file"

	# Close the XML structure
	if [ $create_yealink == "YES" ]; then
	  echo "</YealinkIPPhoneDirectory>" >> "$output_file1"
	  echo "Conversion completed. Output file: $output_file1"
	fi

	if [ $create_cisco == "YES" ]; then
	  echo "</CiscoIPPhoneDirectory>" >> "$output_file2"
	  echo "Conversion completed. Output file: $output_file2"
	fi

	if [ $create_noname == "YES" ]; then
	  echo "</GigasetIPPhoneDirectory>" >> "$output_file3"
	  echo "Conversion completed. Output file: $output_file3"
	fi
}

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
echo
# Create directory for AREDN phonebook files
echo "......Create directory for AREDN phonebook files"
if [ -d "/arednstack/phonebook" ]
  then
   echo "Directory /arednstack/phonebook exist..."
   else
   mkdir /arednstack/
   cd /arednstack
   mkdir phonebook
   echo "/arednstack/phonebook created"
fi
echo
echo

cd /arednstack/phonebook
  
# Download settings file
echo "......Download settings file"
if [ ! -f "$SETTINGS_FILE_NAME" ]; then
    echo "DOWNLOAD $SETTINGS_FILE_NAME: $webserver$SETTINGS_FILE_NAME"
	curl -o $SETTINGS_FILE_NAME "$webserver$SETTINGS_FILE_NAME"
	echo "$SETTINGS_FILE_NAME downloaded"
  else
	echo "$SETTINGS_FILE_NAME already exists, skipping download"
fi
echo
echo
echo "Here is your settings file:"
echo "----------------------------"
cat $SETTINGS_FILE_NAME
echo
echo "----------------------------"
echo
echo
# Read variables in setttings file
echo "......Read variables from setttings file"
create_directory_direct=$(grep 'create_directory_direct=' $SETTINGS_FILE_NAME | awk -F '=' '{print $2}'); create_directory_direct="${create_directory_direct:0:3}"
create_directory_pbx=$(grep 'create_directory_pbx=' $SETTINGS_FILE_NAME | awk -F '=' '{print $2}'); create_directory_pbx="${create_directory_pbx:0:3}"
  
create_yealink=$(grep 'create_yealink=' $SETTINGS_FILE_NAME | awk -F '=' '{print $2}'); create_yealink="${create_yealink:0:3}"
create_cisco=$(grep 'create_cisco=' $SETTINGS_FILE_NAME | awk -F '=' '{print $2}'); create_cisco="${create_cisco:0:3}"
create_noname=$(grep 'create_noname=' $SETTINGS_FILE_NAME | awk -F '=' '{print $2}'); create_noname="${create_noname:0:3}"
echo
  
# Download phonebook.csv
echo "......Download Phonebook.csv"
curl -o phonebook_original.csv "$webserver$PHONEBOOK_URL"
echo
echo "$webserver$PHONEBOOK_URL downloaded"
input_file="phonebook_original.csv"
echo
echo
tail "$input_file"
echo
echo
echo "......Create DIRECT-call phonebook"
if [ $create_directory_direct == "YES" ]; then  
   generate_phonebooks_direct
   echo "Direct-call phonebook created"
  else
	echo "Direct-call phonebook NOT created"
fi

echo
echo
 
echo ".....Create PBX-call phonebook"
if [ $create_directory_pbx == "YES" ]; then
generate_phonebooks_pbx
   echo "Direct-call phonebook created"
  else
	echo "Direct-call phonebook NOT created"
fi
echo
echo

# crontab test (installroutine). It runs every day at
rm $CRON_FILE_NAME

cat << EOF > "$CRON_FILE_NAME"
#!/bin/ash

curl "$webserver$installer_file_name" |sh -s $webserver
EOF

chmod 755 $CRON_FILE_NAME
echo
echo "Here is the daily phonebook downloader"
echo
cat $CRON_FILE_NAME
echo
echo
echo "......Remove phonebook_original.csv file"
rm *.csv