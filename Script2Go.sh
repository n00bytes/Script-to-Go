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
usage() { echo "Usage: $0 [-h <usage>] [-f <Target File>]" 1>&2; exit 1; }

while getopts ":h:f:" o; do
    case "${o}" in
        h)
            h=${OPTARG}
            usage
	    exit;;
        f)
            f=${OPTARG}
            ;;
        *)
            usage
            exit;;
    esac
done
shift $((OPTIND-1))

if [ ! -f "${f}" ]; then
    usage
fi

# Colors
BRed='\033[1;31m'         # Red
BGreen='\033[1;32m'       # Green
BYellow='\033[1;33m'      # Yellow

TargetFile=${f}
echo ""
echo -e "${BGreen}Go Grab Some Coffee........"
echo ""
echo -e "${BRed}Scanning in progress..........."
outDir="Result-$(date +"%d-%m-%Y")"
outAquatone="$outDir"/Aquatone-$(date +"%d-%m-%Y")
outNmap="$outDir"/NmapResult$(date +"%d-%m-%Y")
mkdir "$outDir" "$outNmap" "$outAquatone"

###
nmap -T4 -Pn -n --randomize-hosts -sSVC -O --open --min-rate 500 --max-rate 5000 --max-retries 3 --defeat-rst-ratelimit --top-ports 5000 -iL $TargetFile -oA "$outNmap"/Full-Nmap &>/dev/null
echo -e "${BGreen}Port Scanning........${BRed}[DONE]"
###
cat "$outNmap"/Full-Nmap.nmap | grep 'commonName' | awk '{print $4}' | awk -F '=|/' '{print $2}' | rev | cut -d "." -f1-2 | rev | sort -u | awk -F '.' 'NF>1' > "$outDir"/domainLists.txt
echo -e "${BGreen}Extracting domain list........${BRed}[DONE]"
###
amass enum -silent -df "$outDir"/domainLists.txt -o "$outDir"/AmassOut.txt
echo -e "${BGreen}Amass scanning......${BRed}[DONE]"
###
subfinder -silent -dL "$outDir"/domainLists.txt -o "$outDir"/SubfinderOut.txt &>/dev/null
echo -e "${BGreen}Subfinder scanning......${BRed}[DONE]"
###
cat "$outDir"/AmassOut.txt "$outDir"/SubfinderOut.txt | sort -u > "$outDir"/Subdomains.txt
echo -e "${BGreen}Sorting discovered subdomains......${BRed}[DONE]"
###
cat "$outDir"/Subdomains.txt | dnsx -silent -resp -a -aaaa -o "$outDir"/DnsxOut.txt &>/dev/null
echo -e "${BGreen}Performing reverse dns queries......${BRed}[DONE]"
###
cat "$outDir"/DnsxOut.txt | grep -f $TargetFile > "$outDir"/In-ScopeSubdomains.txt
echo -e "${BGreen}Checking In-Scope target......${BRed}[DONE]"
###
cat $TargetFile "$outDir"/In-ScopeSubdomains.txt | aquatone -ports large -out "$outAquatone"/ &>/dev/null
echo -e "${BGreen}Running Aquatone........${BRed}[DONE]"
###
cat "$outAquatone"/aquatone_urls.txt | awk {'print $1'} | httpx -status-code -title -tech-detect -o "$outDir"/HTTPxOut.txt &>/dev/null
echo -e "${BGreen}HTTPx  scanning......${BRed}[DONE]"
###
nuclei -update -ut &>/dev/null
###
cat "$outDir"/HTTPxOut.txt | grep -Fv -e 404 -e 500 -e 401 -e 402 -e 400 -e FAILED | awk {'print $1'} | nuclei -o "$outDir"/NucleiScanOut.txt &>/dev/null
echo -e "${BGreen}Nuclei scanning......${BRed}[DONE]"
#echo ""
echo -e "${BGreen}BreakTime is over, output files on $outDir"
echo -e "${BRed}Now Get those file and start working..........."
