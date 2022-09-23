# Script2Go
This script was created to automate the following task:

Usage: ./Script2GO.sh -f TargetFile <List of IPv4 target address>

Port Scanning using Nmap:
  * Nmap TCP port scan ALL ports.
  * Nmap UDP port scan top ports.

Perform Subdomain enumeration using:
  * Amass
  * Subfinder
  
Website screen capturing using:
  * Aquatone

Fetch URLS
  * GAU

Identify active Web urls using HTTP prober:
  * HTTPx

Vulnerability Scanning using:
  * Nuclei
 
This tool will also perform DNS queries againts the discovered subdomains and compare it on your supplied target file to avoid any out-of-scope scanning.

Credit to the following for creating these awesome tools.
  * https://github.com/projectdiscovery/
  * https://github.com/OWASP/Amass
  * https://github.com/michenriksen
  * https://github.com/lc/gau
  * https://nmap.org/

 
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
 * Gau
 https://github.com/lc/gau

# Or install them using the installation script.
* Make sure to run the install.sh as root and run the script on the background.

