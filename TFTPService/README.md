# CheckTFTPService
Check if the service is working

Scan the port status with netstat
If there is a listener
 Exit
else If there is no listener,
- Parse the syntax in the DNSMasq configuration file
   - If the 3 necessary lines are missing, it adds them automatically
 - Analyze the global syntax of the DNSMasq configuration file
- Restart the DNSMasq service
- Reanalyze the port status with netstat

The return code of the script
- 0 : The service works, there is a listener on port 69
- 1 : There is no listener on port 69
