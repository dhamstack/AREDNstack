#!/bin/ash

input_file="AREDN_Phonebook_CH - Sheet1.csv"
output_file1="/www/yealink.xml"
output_file2="/www/output_file2.xml"
output_file3="/www/output_file3.xml"

# Check if the input file exists
if [ ! -f "$input_file" ]; then
    echo "Input file not found: $input_file"
    exit 1
fi

# Get the modification time of the input file
input_file_mtime=$(date -r "$input_file"  +%s)

# Check if the modification time is empty (file not found or ls command not available)
if [ -z "$input_file_mtime" ]; then
    echo "Unable to retrieve input file modification time. Skipping script execution."
    exit 0
fi

# Get the current time
current_time=$(date +"%Y-%m-%d %H:%M:%S")

# Convert modification times to Unix timestamps for comparison
current_time=$(date -d "$current_time" +"%s")
echo "$input_file_mtime"
echo "$current_time"


# Calculate the time difference in seconds
time_diff=$((current_time - input_file_mtime))

echo "$time_diff"

# Check if the input file is older than 10 minutes (600 seconds)
if [ "$time_diff" -gt 600 ]; then
    echo "Input file is older than 10 minutes. Skipping script execution."
    exit 0
fi

#Create the output file and write the initial XML structure
echo "<YealinkIPPhoneDirectory>" > "$output_file1"
echo "<CiscoIPPhoneDirectory>" > "$output_file2"
echo "<GigasetIPPhoneDirectory>" > "$output_file3"

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

echo "Conversion completed. Output file: $output_file"

