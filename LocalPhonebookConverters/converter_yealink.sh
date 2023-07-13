#!/bin/ash

input_file="Phonebook.csv"
output_file="phonebook.xml"

# Check if the input file exists
if [ ! -f "$input_file" ]; then
    echo "Input file not found: $input_file"
    exit 1
fi

# Create the output file and write the initial XML structure
echo "<YealinkIPPhoneDirectory>" > "$output_file"

# Read the input file line by line
   while IFS=";" read -r first_name name callsign ip_address telephone; do
    line_number=$((line_number+1))
    
    # Skip the header line
    if [ "$line_number" -le 1 ]; then
        continue
    fi

    # Write the XML structure for each entry
    echo "    <DirectoryEntry>" >> "$output_file"
    echo "        <Name>$first_name $name $callsign</Name>" >> "$output_file"
    echo "        <Telephone>$ip_address</Telephone>" >> "$output_file"
    echo "    </DirectoryEntry>" >> "$output_file"
done < "$input_file"

# Close the XML structure
echo "</YealinkIPPhoneDirectory>" >> "$output_file"

echo "Conversion completed. Output file: $output_file"

