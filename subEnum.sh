#!/bin/bash

url=$1

if [ -z "$url" ]; then
	echo "Please provide a url!"
	echo "SYNTAX: ./subEnum.sh <URL>"
	exit 0
fi

# Help                                                                         #
################################################################################
Help()
{
   # Display Help
   echo "subEnum help"
   echo
   echo "SYNTAX: ./subEnum.sh <URL>"
   echo "options:"
   echo "h     Print this Help."
   echo
}

# Get the options
while getopts ":h" option; do
   case $option in
      h) # display Help
         Help
         exit;;
   esac
done
################################################################################

#make necesary directories if not there

if [ ! -d "output" ]; then
	mkdir output
fi

if [ ! -d "output/$url" ]; then
	mkdir output/$url
fi

if [ ! -d "output/$url/recon" ]; then
	mkdir output/$url/recon
fi

echo "[+] Getting subdomains with assetfinder..."
./dependencies/assetfinder $url >> output/$url/recon/assets.txt
cat output/$url/recon/assets.txt | grep $1 | tee output/$url/recon/subs.txt
rm output/$url/recon/assets.txt
echo "[+] Subdomains captured. Probing now to check if hosts are alive..."
cat output/$url/recon/subs.txt | sort -u | ./dependencies/httprobe | tee output/$url/recon/probed.txt 
echo "[+] Probing done!"
echo "[+] Beautifying results"
sed 's~http[s]*://~~g' output/$url/recon/probed.txt | tee output/$url/recon/finaltemp.txt
echo "Removing duplicates..."
sort -u output/$url/recon/finaltemp.txt | tee final.txt
echo "==================================================="
echo "[+] Running dirsearch with directory-list-2.3-small wordlist..."
xterm -e ./dependencies/dirsearch/dirsearch.py -u 192.168.43.233:3000 -e php,js -w /usr/share/dirbuster/wordlists/directory-list-2.3-small.txt -t 100 | tee output/$url/recon/dirsearch.txt
echo "==================================================="
echo "[+] Running amass enum..."
amass enum -d $url | tee output/$url/recon/amass.txt
echo "Level 1 done!"
echo "[+] Proceeding to level 2..."
echo "==================================================="
echo "[+] Initialising further enumeration..."

if [ ! -d "output/$url/recon/host-details" ];then
	mkdir output/$url/recon/host-details
fi

echo "[+] Generating host information..."
for line in $(cat output/$url/recon/final.txt);do host $line >> output/$url/recon/host-details/host-details.txt ;done

if [ ! -d "output/$url/recon/nmap" ];then
	mkdir output/$url/recon/nmap
fi

echo "[+] Scanning for open ports..."
nmap -iL output/$url/recon/final.txt -T4 -oA output/$url/recon/nmap/open_ports.txt

if [ ! -d "output/$url/recon/wayback-data" ];then
	mkdir output/$url/recon/wayback-data
fi

echo "[+] Gathering wayback data... Press ctrl+c to omit this."
cat output/$url/recon/final.txt | ./dependencies/waybackurls >> output/$url/recon/wayback-data/wayback-data.txt
sort -u output/$url/recon/wayback-data/wayback-data.txt

echo "[+] Pulling and compiling all possible params found in wayback data..."
cat output/$url/recon/wayback-data/wayback-data.txt | grep '?*=' | cut -d '=' -f 1 | sort -u >> output/$url/recon/wayback-data/wayback-params.txt
for line in $(cat output/$url/recon/wayback-data/wayback-params.txt);do echo $line'=';done

echo "[+] Pulling and compiling js/php/aspx/jsp/json files from wayback output..."

if [ ! -d "output/$url/recon/wayback-data/extensions" ]; then
	mkdir output/$url/recon/wayback-data/extensions
fi

for line in $(cat output/$url/recon/wayback-data/wayback-data.txt);do
	ext="${line##*.}"
	if [[ "$ext" == "js" ]]; then
		echo $line >> output/$url/recon/wayback-data/extensions/jstemp.txt
		sort -u output/$url/recon/wayback-data/extensions/jstemp.txt >> output/$url/recon/wayback-data/extensions/js.txt
	fi
	if [[ "$ext" == "html" ]];then
		echo $line >> output/$url/recon/wayback-data/extensions/jsptemp.txt
		sort -u output/$url/recon/wayback-data/extensions/jsptemp.txt >> output/$url/recon/wayback-data/extensions/jsp.txt
	fi
	if [[ "$ext" == "json" ]];then
		echo $line >> output/$url/recon/wayback-data/extensions/jsontemp.txt
		sort -u output/$url/recon/wayback-data/extensions/jsontemp.txt >> output/$url/recon/wayback-data/extensions/json.txt
	fi
	if [[ "$ext" == "php" ]];then
		echo $line >> output/$url/recon/wayback-data/extensions/phptemp.txt
		sort -u output/$url/recon/wayback-data/extensions/phptemp.txt >> output/$url/recon/wayback-data/extensions/php.txt
	fi
	if [[ "$ext" == "aspx" ]];then
		echo $line >> output/$url/recon/wayback-data/extensions/aspxtemp.txt
		sort -u output/$url/recon/wayback-data/extensions/aspxtemp.txt >> output/$url/recon/wayback-data/extensions/aspx.txt
	fi
done

rm output/$url/recon/wayback-data/extensions/jstemp.txt
rm output/$url/recon/wayback-data/extensions/jsptemp.txt
rm output/$url/recon/wayback-data/extensions/jsontemp.txt
rm output/$url/recon/wayback-data/extensions/phptemp.txt
rm output/$url/recon/wayback-data/extensions/aspxtemp.txt

echo "==================================================="
echo "All done! Results are saved to output/"$url