#!/bin/bash
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

# Colors
BRed='\033[1;31m'         # Red
BGreen='\033[1;32m'       # Green
BYellow='\033[1;33m'      # Yellow
BBlue='\033[1;34m'	  # Blue

targetFile=${f}
echo ""
echo -e "${BGreen}Go Grab Some Coffee........"
echo ""
echo -e "${BRed}Scanning in progress..........\033[0;31m'"
outDir="Result-$(date +"%d-%m-%Y")"
outAquatone="$outDir"/Aquatone-$(date +"%d-%m-%Y")
outNmap="$outDir"/NmapResult$(date +"%d-%m-%Y")
mkdir "$outDir" "$outNmap" "$outAquatone"

### Nmap All ports TCP ###
nmap -T4 -Pn -n -sS -A --open -p- --min-rate 500 --max-rate 10000 --max-retries 3 --defeat-rst-ratelimit -iL $targetFile -oA $outNmap/Nmap_TopPorts_TCP &>/dev/null
echo -e "${BGreen}Port Scanning All TCP........${BRed}[DONE]"

### Nmap Top ports UDP ###
nmap -T4 -Pn -n -sU -A --open --top-ports 200 --min-rate 500 --max-rate 1000 --max-retries 3 --defeat-rst-ratelimit -iL $targetFile -oA $outNmap/Nmap_TopPorts_UDP &>/dev/null
echo -e "${BGreen}Port Scanning Top-ports 200 UDP........${BRed}[DONE]"

if [  "$d" == "" ]; then

	# If no domain names found.
	echo -e "${BBlue}No provided domain ..Skipping Subdomain enumeration..${BRed}[SKIP]"
       	
else
	# If domain names found.
	amass enum -silent -d $d -o $outDir/AmassOut.txt # Subdomain Enum Amass
	echo -e "${BGreen}Amass scanning......${BRed}[DONE]"

	subfinder  -silent -d $d -o $outDir/SubfinderOut.txt &>/dev/null # Subdomain Enum Subfinder
	echo -e "${BGreen}Subfinder scanning......${BRed}[DONE]"

	cat $outDir/AmassOut.txt $outDir/SubfinderOut.txt | sort -u > $outDir/Subdomains.txt
	echo -e "${BGreen}Sorting discovered subdomains......${BRed}[DONE]"

	cat $outDir/Subdomains.txt | dnsx -silent -resp -a -aaaa -o $outDir/DnsxOut.txt &>/dev/null
	echo -e "${BGreen}Performing reverse dns queries......${BRed}[DONE]"
fi

if [ -f $outDir/DnsxOut.txt ]; then
	cat $outDir/DnsxOut.txt | grep -f $targetFile > $outDir/In-ScopeSubdomains.txt
	echo -e "${BGreen}Checking In-Scope target......${BRed}[DONE]"	

else
	echo -e ""
fi

if [ -f $outDir/In-ScopeSubdomains.txt ]; then
	cat $TargetFile $outDir/In-ScopeSubdomains.txt | aquatone -ports large -out $outAquatone/ &>/dev/null
	echo -e "${BGreen}Running Aquatone........${BRed}[DONE]"
else
	cat $TargetFile | aquatone -ports large -out $outAquatone/ &>/dev/null
	echo -e "${BGreen}Skipping Aquatone........${BRed}[SKIP]"
fi

cat $outAquatone/aquatone_urls.txt | awk {'print $1'} | httpx -status-code -title -tech-detect -o $outDir/HTTPxOut.txt &>/dev/null
echo -e "${BGreen}HTTPx  scanning......${BRed}[DONE]"

nuclei -update -ut &>/dev/null

cat $outDir/HTTPxOut.txt | grep -Fv -e 404 -e 500 -e 401 -e 402 -e 400 -e FAILED | awk {'print $1'} | nuclei -o $outDir/NucleiScanOut.txt &>/dev/null
echo -e "${BGreen}Nuclei scanning......${BRed}[DONE]"

echo -e "${BRed}Now Get those file and start working.........."
