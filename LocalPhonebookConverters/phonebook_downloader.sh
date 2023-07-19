#!/bin/ash
# $Author: Andreas HB9BLA $
# $Date: 2023/07/19 $
# $Revision: 2.0 $

PHONEBOOK_URL="http://10.55.47.92/AREDN_Phonebook.csv"
output_file1="/www/yealink.xml"
output_file2="/www/cisco.xml"
output_file3="/www/output_file3.xml"

#Create the output file and write the initial XML structure
echo "<YealinkIPPhoneDirectory>" > "$output_file1"
echo "<CiscoIPPhoneDirectory>" > "$output_file2"
echo "<GigasetIPPhoneDirectory>" > "$output_file3"

cd /arednstack/phonebook

curl -o phonebook_original "$PHONEBOOK_URL"
input_file="phonebook_original"
echo "$PHONEBOOK_URL downloaded"
tail "$input_file"

# Read the input file line by line
   while IFS="," read -r first_name name callsign ip_address telephone; do
    line_number=$((line_number+1))
    
    # Skip the header line
    if [ "$line_number" -le 1 ]; then
        continue
    fi

    # Write the XML structure for file1
    echo "    <DirectoryEntry>" >> "$output_file1"
    echo "        <Name>$name $first_name $callsign</Name>" >> "$output_file1"
    echo "        <Telephone>$ip_address</Telephone>" >> "$output_file1"
    echo "    </DirectoryEntry>" >> "$output_file1"
	
	    # Write the XML structure for file2
    echo "    <DirectoryEntry>" >> "$output_file2"
    echo "        <Name>$name $first_name $callsign</Name>" >> "$output_file2"
    echo "        <Telephone>$telephone</Telephone>" >> "$output_file2"
    echo "    </DirectoryEntry>" >> "$output_file2"
	
	    # Write the XML structure for file3
    echo "    <DirectoryEntry>" >> "$output_file3"
    echo "        <Name>$first_name $name $callsign</Name>" >> "$output_file3"
    echo "        <Telephone>$ip_address</Telephone>" >> "$output_file3"
    echo "    </DirectoryEntry>" >> "$output_file3"
done < "$input_file"

# Close the XML structure
echo "</YealinkIPPhoneDirectory>" >> "$output_file1"
echo "</CiscoIPPhoneDirectory>" >> "$output_file2"
echo "</GigasetIPPhoneDirectory>" >> "$output_file3"

echo "Conversion completed. Output file: $output_file1"
echo "Conversion completed. Output file: $output_file2"
echo "Conversion completed. Output file: $output_file3"

