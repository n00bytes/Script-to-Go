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

AmassConfig=/home/consultant/Tools/config.ini    #Edit path to your config.ini
SubfinderConfig=/root/.config/subfinder/provider-config.yaml	#Edit path to your provider-config.yaml

#### Comment out if you want to use config file for Amass and Subfinder ###
#AmassConfig=/Path/config.ini    #Uncomment and edit path to your config.ini
#SubfinderConfig=/Path/provider-config.yaml	#Uncomment and edit path to your provider-config.yaml

### Nmap Top ports TCP ###
#nmap -T4 -Pn -n -sS -A --open --top-ports 1000 --min-rate 500 --max-rate 1000 --max-retries 3 --defeat-rst-ratelimit -iL $targetFile -oA $outNmap/Nmap_TopPorts_TCP &>/dev/null
echo -e "${BGreen}Port Scanning Top-ports 1000 TCP........${BRed}[DONE]"

### Nmap Top ports UDP ###
#nmap -T4 -Pn -n -sU -A --open --top-ports 200 --min-rate 500 --max-rate 1000 --max-retries 3 --defeat-rst-ratelimit -iL $targetFile -oA $outNmap/Nmap_TopPorts_UDP &>/dev/null
echo -e "${BGreen}Port Scanning Top-ports 200 UDP........${BRed}[DONE]"

#cat $outNmap/nmap_top_10k.nmap | grep 'commonName' | awk '{print $4}' | awk -F '=|/' '{print $2}' | rev | cut -d "." -f1-2 | rev | sort -u | awk -F '.' 'NF>1' > $outDir/domainLists.txt
#echo -e "${BGreen}Extracting domain list........${BRed}[DONE]"

if [  "$d" == "" ]; then

	# If no domain names found.
	echo -e "${BBlue}No provided domain ..Skipping Subdomain enumeration..${BRed}[SKIP]"
        # If domain names found.
       	
else
	#amass enum -silent -df $outDir/domainLists.txt -o $outDir/AmassOut.txt &>/dev/null
	amass enum -silent -d $d -config $AmassConfig -o $outDir/AmassOut.txt #uncomment out this line and comment the line above if you have config file.
	echo -e "${BGreen}Amass scanning......${BRed}[DONE]"

	#subfinder -silent -dL $outDir/domainLists.txt -o $outDir/SubfinderOut.txt &>/dev/null
	subfinder  -silent -d $d -config $SubfinderConfig -o $outDir/SubfinderOut.txt &>/dev/null #uncomment out this line and comment line above if you have config file.
	echo -e "${BGreen}Subfinder scanning......${BRed}[DONE]"

	cat $outDir/AmassOut.txt $outDir/SubfinderOut.txt | sort -u > $outDir/Subdomains.txt
	echo -e "${BGreen}Sorting discovered subdomains......${BRed}[DONE]"

	cat $outDir/Subdomains.txt | dnsx -silent -resp -a -aaaa -o $outDir/DnsxOut.txt &>/dev/null
	echo -e "${BGreen}Performing reverse dns queries......${BRed}[DONE]"
fi

if [ -f $outDir/DnsxOut.txt ]; then
	cat $outDir/DnsxOut.txt | grep -f $TargetFile > $outDir/In-ScopeSubdomains.txt
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
