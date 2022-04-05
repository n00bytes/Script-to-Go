# Script-To-Go
This script was created to automate the following task:

Port Scanning using Nmap:
  * TCP top 10k ports
  * UDP top 1k ports

Collect 2nd level domain from Nmap result and use to perform Subdomain enumeration using:
  * Amass
  * Subfinder
  
Website screen capturing using:
  * Aquatone

Identified active Webs using HTTP prober:
  * HTTPx

Vulnerability Scanning using:
  * Nuclei
 
This tool will also perform DNS queries againts the discovered subdomains and compare with your supplied target file to avoid any out-of-scope scanning.

Credit to the following for creating these awesome tools.
  * https://github.com/projectdiscovery/
  * https://github.com/OWASP/Amass
  * https://github.com/michenriksen
  * https://nmap.org/

 
 # Check the following links on how to install following tools.
 Go installation
 https://go.dev/doc/install
 
 Subfinder
 https://github.com/projectdiscovery/subfinder
 
 Nuclei Scanner
 https://github.com/projectdiscovery/nuclei
 
 HTTPx
 https://github.com/projectdiscovery/httpx
 
 Amass
 https://github.com/OWASP/Amass/blob/master/doc/install.md
 
 DNSx
 https://github.com/projectdiscovery/dnsx
 
 Aquatone
 https://github.com/michenriksen/aquatone
 
 Note: Once installed make sure to copy the binaries to "/usr/local/bin"
