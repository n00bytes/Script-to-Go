# Script2Go
This script is created to automate the following task:

Usage: ./Script2GO.sh -f ListofIPaddress -d TargetDomain

Port Scanning using Masscan:
  * TCP port scan 65k ALL ports

Port Service Enumeration using Nmap:
  * Service enumeration using the output from Masscan

Perform Subdomain enumeration using:
  * Amass
  * Subfinder
  
Website screen capturing using:
  * Aquatone

Identify active Web urls using HTTP prober:
  * HTTPx

Vulnerability Scanning using:
  * Nuclei

Add-Ons
Web crawler: Checking all posible web application endpoint and link
  * hakrawler
 
This tool will also perform DNS queries againts the discovered subdomains and compare it on your supplied target file to avoid any out-of-scope scanning.

Credit to the author these awesome tools.
  * https://github.com/projectdiscovery/
  * https://github.com/OWASP/Amass
  * https://github.com/michenriksen
  * https://github.com/hakluke/hakrawler
  * https://nmap.org/
  * https://github.com/robertdavidgraham/masscan

 
 # Check the following links to manually install the tools needed.
Note: Make sure to install them as root and once installed run " export PATH=$PATH:/root/go/bin " 

 * Go installation
 https://go.dev/doc/install
 * Subfinder
 https://github.com/projectdiscovery/subfinder
 * Nuclei Scanner
 https://github.com/projectdiscovery/nuclei
 * HTTPx
 https://github.com/projectdiscovery/httpx
 * Amass
 https://github.com/OWASP/Amass/blob/master/doc/install.md
 * DNSx
 https://github.com/projectdiscovery/dnsx
 * Aquatone
 https://github.com/michenriksen/aquatone
 * Hakrawler
 https://github.com/hakluke/hakrawler

Or install them using the installation script.

Note: Make sure to run the script as "root"
