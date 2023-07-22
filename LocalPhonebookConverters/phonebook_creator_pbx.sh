#!/bin/ash
# $Author: Andreas HB9BLA $
# $Date: 2023/07/22 $
# $Revision: 2.1 $


echo
echo "Start PHONEBOOK_CREATOR_PBX........"

cd /arednstack/phonebook

echo $1 $2 $3

if [ $1 == "YES" ]; then
  output_file1="/www/phonebook_yealink_pbx.xml"
  echo "<YealinkIPPhoneDirectory>" > "$output_file1"
fi
if [ $2 == "YES" ]; then
  output_file2="/www/phonebook_cisco_pbx.xml"
  echo "<CiscoIPPhoneDirectory>" > "$output_file2"
fi
if [ $3 == "YES" ]; then
  output_file3="/www/phonebook_noname_pbx.xml"
  echo "<GigasetIPPhoneDirectory>" > "$output_file3"
fi

# Open phonebook.csv as $input_file
input_file="phonebook_original.csv"
echo "$PHONEBOOK_URL opened"
tail "$input_file"

# Read the input file line by line
   while IFS="," read -r first_name name callsign ip_address telephone email club mobile street City; do
    line_number=$((line_number+1))
    
    # Skip the header line
    if [ "$line_number" -le 1 ]; then
        continue
    fi

    # Write the XML structure for file1
	if [ $1 == "YES" ]; then
      echo "    <DirectoryEntry>" >> "$output_file1"
      echo "        <Name>$name $first_name $callsign</Name>" >> "$output_file1"
      echo "        <Telephone>$telephone</Telephone>" >> "$output_file1"
      echo "    </DirectoryEntry>" >> "$output_file1"
	fi
	
	# Write the XML structure for file2
    if [ $2 == "YES" ]; then
      echo "    <DirectoryEntry>" >> "$output_file2"
      echo "        <Name>$name $first_name $callsign</Name>" >> "$output_file2"
      echo "        <Telephone>$telephone</Telephone>" >> "$output_file2"
      echo "    </DirectoryEntry>" >> "$output_file2"
	fi
	
	# Write the XML structure for file3
    if [ $3 == "YES" ]; then
      echo "    <DirectoryEntry>" >> "$output_file3"
      echo "        <Name>$first_name $name $callsign</Name>" >> "$output_file3"
      echo "        <Telephone>$telephone</Telephone>" >> "$output_file3"
      echo "    </DirectoryEntry>" >> "$output_file3"
	fi
done < "$input_file"

# Close the XML structure
echo "</YealinkIPPhoneDirectory>" >> "$output_file1"
echo "</CiscoIPPhoneDirectory>" >> "$output_file2"
echo "</GigasetIPPhoneDirectory>" >> "$output_file3"

echo "Conversion completed. Output file: $output_file1"
echo "Conversion completed. Output file: $output_file2"
echo "Conversion completed. Output file: $output_file3"

