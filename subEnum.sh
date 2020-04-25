#!/bin/bash

################################################################################
Help() {
	# Display Help
	echo "subEnum help"
	echo
	echo "SYNTAX: ./subEnum.sh options"
	echo "options:"
	echo "-h     Print this Help."
	echo "-u     The target to enumerate."
	echo "-A     Run everything."
	echo "-s     Get subdirectories."
	echo "-d     Run dirsearch."
	echo "-a     Run amass."
	echo "-t     Run host identification."
	echo "-b     Run whatweb."
	echo "-n     Run nmap."
	echo "-w     Run wayback."
	echo
}

################################################################################
#Declare Functions
assetfinderfunc() {
	echo "==================================================="
	echo "[+] Getting subdomains with assetfinder..."
	./dependencies/assetfinder $url | tee output/$url/recon/assets.txt
	cat output/$url/recon/assets.txt | grep $url | tee output/$url/recon/subs.txt
	rm output/$url/recon/assets.txt
	echo "[+] Subdomains captured. Probing now to check if hosts are alive..."
	cat output/$url/recon/subs.txt | sort -u | ./dependencies/httprobe | tee output/$url/recon/probed.txt
	echo "[+] Probing done!"
	echo "[+] Beautifying results"
	sed 's~http[s]*://~~g' output/$url/recon/probed.txt | tee output/$url/recon/finaltemp.txt
	echo "Removing duplicates..."
	echo "==================================================="
	sort -u output/$url/recon/finaltemp.txt | tee output/$url/recon/final.txt
	echo "`wc -l < output/$url/recon/final.txt` subdomains captured."
	echo "==================================================="
	echo
}

dirsearchfunc() {
	echo "==================================================="
	echo "[+] Running dirsearch with directory-list-2.3-small wordlist..."
	xterm -e ./dependencies/dirsearch/dirsearch.py -u $url -e php,js -w /usr/share/dirbuster/wordlists/directory-list-2.3-small.txt -t 100 --json-report=output/$url/recon/dirsearch.json
}

amassfunc() {
	echo "==================================================="
	echo "[+] Running amass enum..."
	amass enum -d $url | tee output/$url/recon/amass.txt
	echo "Amass done!"
}

hostinfofunc() {
	if [ ! -d "output/$url/recon/host-details" ]; then
		mkdir output/$url/recon/host-details
	fi
	echo "==================================================="
	echo "[+] Generating host information..."
	for line in $(cat output/$url/recon/final.txt); do host $line >>output/$url/recon/host-details/host-details.txt; done
}

whatwebfunc() {
	if [ ! -d "output/$url/recon/host-details" ]; then
		mkdir output/$url/recon/host-details
	fi
	echo "==================================================="
	echo "[+] Running whatweb on targets..."
	for line in $(cat output/$url/recon/final.txt); do whatweb -t $line >>output/$url/recon/host-details/whatweb.txt; done
}

nmapfunc() {
	if [ ! -d "output/$url/recon/nmap" ]; then
		mkdir output/$url/recon/nmap
	fi
	echo "==================================================="
	echo "[+] Scanning for open ports..."
	nmap -iL output/$url/recon/final.txt -T4 -oA output/$url/recon/nmap/open_ports.txt
}

waybackfunc() {
	if [ ! -d "output/$url/recon/wayback-data" ]; then
		mkdir output/$url/recon/wayback-data
	fi
	echo "==================================================="
	echo "[+] Gathering wayback data... Press ctrl+c to omit this."
	cat output/$url/recon/final.txt | ./dependencies/waybackurls >>output/$url/recon/wayback-data/wayback-data.txt
	sort -u output/$url/recon/wayback-data/wayback-data.txt

	echo "[+] Pulling and compiling all possible params found in wayback data..."
	cat output/$url/recon/wayback-data/wayback-data.txt | grep '?*=' | cut -d '=' -f 1 | sort -u >>output/$url/recon/wayback-data/wayback-params.txt
	for line in $(cat output/$url/recon/wayback-data/wayback-params.txt); do echo $line'='; done

	echo "[+] Pulling and compiling js/php/aspx/jsp/json files from wayback output..."

	if [ ! -d "output/$url/recon/wayback-data/extensions" ]; then
		mkdir output/$url/recon/wayback-data/extensions
	fi

	for line in $(cat output/$url/recon/wayback-data/wayback-data.txt); do
		ext="${line##*.}"
		if [[ "$ext" == "js" ]]; then
			echo $line >>output/$url/recon/wayback-data/extensions/jstemp.txt
			sort -u output/$url/recon/wayback-data/extensions/jstemp.txt >>output/$url/recon/wayback-data/extensions/js.txt
		fi
		if [[ "$ext" == "html" ]]; then
			echo $line >>output/$url/recon/wayback-data/extensions/jsptemp.txt
			sort -u output/$url/recon/wayback-data/extensions/jsptemp.txt >>output/$url/recon/wayback-data/extensions/jsp.txt
		fi
		if [[ "$ext" == "json" ]]; then
			echo $line >>output/$url/recon/wayback-data/extensions/jsontemp.txt
			sort -u output/$url/recon/wayback-data/extensions/jsontemp.txt >>output/$url/recon/wayback-data/extensions/json.txt
		fi
		if [[ "$ext" == "php" ]]; then
			echo $line >>output/$url/recon/wayback-data/extensions/phptemp.txt
			sort -u output/$url/recon/wayback-data/extensions/phptemp.txt >>output/$url/recon/wayback-data/extensions/php.txt
		fi
		if [[ "$ext" == "aspx" ]]; then
			echo $line >>output/$url/recon/wayback-data/extensions/aspxtemp.txt
			sort -u output/$url/recon/wayback-data/extensions/aspxtemp.txt >>output/$url/recon/wayback-data/extensions/aspx.txt
		fi
	done
	rm output/$url/recon/wayback-data/extensions/jstemp.txt
	rm output/$url/recon/wayback-data/extensions/jsptemp.txt
	rm output/$url/recon/wayback-data/extensions/jsontemp.txt
	rm output/$url/recon/wayback-data/extensions/phptemp.txt
	rm output/$url/recon/wayback-data/extensions/aspxtemp.txt
	echo "==================================================="
}

################################################################################
#main()

################################################################################

#make necesary directories if not there

# Get the options
while getopts :hu:Asdabtnw option; do
	case $option in
	# h)	Help
	h) # display Help
		Help
		exit
		;;
	u)
		url=${OPTARG}
		if [ ! -d "output" ]; then
			mkdir output
		fi

		if [ ! -d "output/$url" ]; then
			mkdir output/$url
		fi

		if [ ! -d "output/$url/recon" ]; then
			mkdir output/$url/recon
		fi
		# exit
		;;
	A)
		assetfinderfunc
		amassfunc
		hostinfofunc &
		whatwebfunc &
		nmapfunc &
		dirsearchfunc &
		waybackfunc
		echo "All done! Results are saved to output/"$url
		echo "============================================"
		# exit
		;;
	s)
		assetfinderfunc
		echo "All done! Results are saved to output/"$url
		echo "============================================"
		# exit
		;;
	d)
		dirsearchfunc
		echo "All done! Results are saved to output/"$url
		echo "============================================"
		# exit
		;;
	a)
		amassfunc
		echo "All done! Results are saved to output/"$url
		echo "============================================"
		# exit 1
		;;
	t)
		if [ ! -f "output/$url/recon/final.txt" ]; then
			echo "Could not find final.txt! Running with -s now."
			assetfinderfunc
		fi
		hostinfofunc
		echo "All done! Results are saved to output/"$url
		echo "============================================"
		# exit
		;;
	b)
		if [ ! -f "output/$url/recon/final.txt" ]; then
			echo "Could not find final.txt! Running with -s now."
			assetfinderfunc
		fi
		whatwebfunc
		echo "All done! Results are saved to output/"$url
		echo "============================================"
		# exit
		;;
	n)
		nmapfunc
		echo "All done! Results are saved to output/"$url
		echo "============================================"
		# exit
		;;
	w)
		if [ ! -f "output/$url/recon/final.txt" ]; then
			echo "Could not find final.txt! Running with -s now."
			assetfinderfunc
		fi
		waybackfunc
		echo "All done! Results are saved to output/"$url
		echo "============================================"
		# exit
		;;
	*) echo "Invalid arg" ;;
	esac
done

if [ -z "$url" ]; then
	echo "Please provide a url!"
	Help
	exit 0
fi
