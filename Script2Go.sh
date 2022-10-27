#!/bin/bash
BRed='\033[1;31m'         # Red
BGreen='\033[1;32m'       # Green
BYellow='\033[1;33m'      # Yellow
BBlue='\033[1;34m'	  # Blue


Result_Path="Result-$(date +"%d-%m-%Y")"
Aquatone_Result="$Result_Path"/Aquatone-$(date +"%d-%m-%Y")
PortScan_Result="$Result_Path"/PortScan-$(date +"%d-%m-%Y")
Subdomains_Result="$Result_Path"/Subdomains-$(date +"%d-%m-%Y")
Vulnerability_Result="$Result_Path"/Vulnerability-$(date +"%d-%m-%Y")
Webcrawl_Result="$Result_Path"/WebCrawler-$(date +"%d-%m-%Y")

### Config File ###
AmassConfig=/home/consultant/Tools/config.ini    #Edit path to your config.ini
SubfinderConfig=/root/.config/subfinder/provider-config.yaml	#Edit path to your provider-config.yaml

clear
cat << "EOF"
###################################################################################
#									  #	  #						
#										  #
# ███████╗ ██████╗██████╗ ██╗██████╗ ████████╗   ██████╗        ██████╗  ██████╗  #
# ██╔════╝██╔════╝██╔══██╗██║██╔══██╗╚══██╔══╝   ╚════██╗      ██╔════╝ ██╔═══██╗ #
# ███████╗██║     ██████╔╝██║██████╔╝   ██║█████╗ █████╔╝█████╗██║  ███╗██║   ██║ #
# ╚════██║██║     ██╔══██╗██║██╔═══╝    ██║╚════╝██╔═══╝ ╚════╝██║   ██║██║   ██║ #
# ███████║╚██████╗██║  ██║██║██║        ██║      ███████╗      ╚██████╔╝╚██████╔╝ #
# ╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝╚═╝        ╚═╝      ╚══════╝       ╚═════╝  ╚═════╝  #
#    Credit to: https://projectdiscovery.io and owasp.org/www-project-amass       #
#								      	          #
#  						        	"By: n00bytes"	  #			
###################################################################################                                                                                    
EOF

echo ""
usage() { echo "Usage: $0 [-h <usage>] [-f <Target File>] [-d <Domain>]" 1>&2; exit 1; }

while getopts "h:f:d:" opt; do
    case "${opt}" in
        h)
            h=${OPTARG}
            usage
	    exit
	    ;;
        f)
            f=${OPTARG}
            ;;
	d)
	    d=${OPTARG}
	    ;;
        *)
            usage
	    exit
	    ;;
    esac
done
shift $((OPTIND-1))

if [ ! -f "${f}" ] && [  "${d}" == "" ]; then
    usage
fi
TargetFile=${f}
echo ""

echo -e "${BGreen}Go Grab Some Coffee..........."

echo ""

if [ -d $Result_Path ]; then
        echo -e "${BGreen}Directory already exists...${BRed}[SKIP]"
    else
        echo -e "${BGreen}Creating results directory..."
        mkdir $Result_Path $Aquatone_Result $PortScan_Result $Subdomains_Result $Vulnerability_Result $Webcrawl_Result
    fi
echo ""

echo -e "${BGreen}Scanning in progress........."
echo ""
portScan(){
	## Masscan Port Scan ##
	masscan -p 1-65535 --rate 10000 --wait 0 --open -iL $TargetFile -oX $PortScan_Result/masscan.xml &>/dev/null
	Ports=$(cat $PortScan_Result/masscan.xml | grep portid | cut -d "\"" -f 10 | sort -n | uniq | paste -sd,)
	cat $PortScan_Result/masscan.xml | grep portid | cut -d "\"" -f 4 | sort -V | uniq > $PortScan_Result/Nmap_Target
	echo -e "${BGreen}Port Discovery......${BRed}[DONE]"
	## Nmap Scan ##
	nmap -sV -sC -O -p $Ports --open -Pn -n -T4 -iL $PortScan_Result/Nmap_Target -oA $PortScan_Result/Nmap_65k_TCP &>/dev/null
	rm $PortScan_Result/Nmap_Target
	echo -e "${BGreen}Nmap Scanning.......${BRed}[DONE]"
}

subdomainsRecon(){
	if [ "$d" == "" ]; then
	echo -e "${BGreen}No provided domain ..Skipping Subdomain enumeration..${BRed}[SKIP]"
	else
	amass enum -silent -df $d -config $AmassConfig -o $Subdomains_Recon/AmassOut.txt #uncomment out this line and comment the line above if you have config file.
	echo -e "${BGreen}Amass scanning......${BRed}[DONE]"
	subfinder  -silent -d $d -config $SubfinderConfig -o $Subdomains_Recon/SubfinderOut.txt &>/dev/null #uncomment out this line and comment line above if you have config file.
	echo -e "${BGreen}Subfinder scanning......${BRed}[DONE]"
	cat $Subdomains_Recon/AmassOut.txt $Subdomains_Recon/SubfinderOut.txt | sort -u > $Subdomains_Recon/Subdomains.txt
	echo -e "${BGreen}Sorting discovered subdomains......${BRed}[DONE]"
	cat $Subdomains_Recon/Subdomains.txt | dnsx -silent -resp -a -aaaa -o $Subdomains_Recon/DnsxOut.txt &>/dev/null
	echo -e "${BGreen}Performing reverse dns queries......${BRed}[DONE]"
	fi

	if [ -f $Subdomains_Recon/DnsxOut.txt ]; then
	cat $Subdomains_Recon/DnsxOut.txt | grep -f $TargetFile > $Subdomains_Recon/In-ScopeSubdomains.txt
	echo -e "${BGreen}Checking In-Scope target......${BRed}[DONE]"	
	else
	echo -e ""
	fi
}

aquatoneScan(){
	if [ -f $Subdomains_Recon/In-ScopeSubdomains.txt ]; then
	cat $TargetFile $Subdomains_Recon/In-ScopeSubdomains.txt | aquatone -ports large -out $Aquatone_Result/ &>/dev/null
	echo -e "${BGreen}Running Aquatone........${BRed}[DONE]"
	else
	cat $TargetFile | aquatone -ports large -out $Aquatone_Result/ &>/dev/null
	echo -e "${BGreen}Skipping Aquatone........${BRed}[SKIP]"
	fi
}

nucleiScan(){
	cat $Aquatone_Result/aquatone_urls.txt | httpx -status-code -title -tech-detect -o $Subdomains_Recon/HTTPxOut.txt &>/dev/null
	echo -e "${BGreen}HTTPx  scanning......${BRed}[DONE]"
	nuclei -update -ut &>/dev/null
	cat $Subdomains_Recon/HTTPxOut.txt | grep -Fv -e 404 -e 500 -e 401 -e 402 -e 400 -e FAILED | awk {'print $1'} | nuclei -o $Vulnerability_Result/NucleiScanOut.txt &>/dev/null
echo -e "${BGreen}Nuclei scanning......${BRed}[DONE]"
}

webcrawler(){
	cat $Subdomains_Recon/HTTPxOut.txt | hakrawler -d 3 -dr -i -u >> $Webcrawl_Result/WebCrawl_Output.txt

}
portScan
subdomainsRecon
aquatoneScan
nucleiScan
webcrawler
echo -e "${BRed}Now Get those file and start working.........."
