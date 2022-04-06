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
nmap -T4 -Pn -n --randomize-hosts -sSUVC -O --open --min-rate 1000 --max-rate 5000 --max-retries 3 --defeat-rst-ratelimit -p T:1-65535,U:7,9,17,19,49,53,67-69,80,88,111,120,123,135-139,158,161-162,177,427,443,445,497,500,514-515,518,520,593,623,626,631,996-999,1022-1023,1025-1030,1433-1434,1645-1646,1701,1718-1719,1812-1813,1900,2000,2048-2049,2222-2223,3283,3456,3703,4444,4500,5000,5060,5353,5632,9200,10000,17185,20031,30718,31337,32768-32769,32771,32815,33281,49152-49154,49156,49181-49182,49185-49186,49188,49190-49194,49200-49201,65024 -iL $TargetFile -oA "$outNmap"/Full-Nmap &>/dev/null
echo -e "${BGreen}Port Scanning Top-ports 10000 TCP........${BRed}[DONE]"
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
cat "$outDir"/"$outAquatone"/aquatone_urls.txt | awk {'print $1'} | httpx -status-code -title -tech-detect -o "$outDir"/HTTPxOut.txt &>/dev/null
echo -e "${BGreen}HTTPx  scanning......${BRed}[DONE]"
###
nuclei -update -ut
###
cat "$outDir"/HTTPxOut.txt | grep -Fv -e 404 -e 500 -e 401 -e 402 -e 400 -e FAILED | awk {'print $1'} | nuclei -o "$outDir"/NucleiScanOut.txt &>/dev/null
echo -e "${BGreen}Nuclei scanning......${BRed}[DONE]"
#echo ""
echo -e "${BGreen}BreakTime is over, output files on $outDir"
echo -e "${BRed}Now Get those file and start working..........."
