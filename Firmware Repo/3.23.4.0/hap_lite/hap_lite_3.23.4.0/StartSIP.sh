#!/bin/ash

# Run the ip command to get the IP address information for br-lan
ip_output=$(ip address show br-lan)
echo "$ip_output"

PROGRAM_PATH="/test"
echo "$PATH"

# Extract the IP address using grep and awk
ip_address=$(echo "$ip_output" | awk '/inet / {split($2, a, "/"); print a[1]}')

# Write the IP address to the file "StartSipServer.sh"
echo "#!/bin/ash" > $PROGRAM_PATH/StartSipServer.sh
echo "/usr/sbin/SipServer --ip=$ip_address --port=5060" >> $PROGRAM_PATH/StartSipServer.sh

# Make the file executable
chmod +x $PROGRAM_PATH/StartSipServer.sh
echo "IP address written to StartSipServer.sh: $ip_address"
