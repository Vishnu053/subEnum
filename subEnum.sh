#!/bin/bash

echo "------^-------------^-----"
echo "------ｓｕｂＥｎｕｍ------"
echo "--------------------ⓥⓜⓚ---"
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
	# echo "-c     Clears the clutter. Removes segregated lists and creates a single list."
	echo "-e     Take screenshots using gowitness."
	echo "-p     Run Paramspider."
	echo "-M     Run Mayonaise Recon methodology."
	echo
}

################################################################################
#Declare Functions
assetfinderfunc() {
	echo "==================================================="
	echo "----^---------^--------ⓢⓤⓑⒺⓝⓤⓜ------"
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
	echo "$(wc -l <output/$url/recon/final.txt) subdomains captured."
	echo "==================================================="
	echo "----^---------^--------ⓢⓤⓑⒺⓝⓤⓜ------"
	echo
}

dirsearchfunc() {
	echo "==================================================="
	echo "----^---------^--------ⓢⓤⓑⒺⓝⓤⓜ------"
	echo "[+] Running dirsearch with directory-list-2.3-small wordlist..."
	xterm -e ./dependencies/dirsearch/dirsearch.py -u $url -e php,js,json,csv,pdf,zip,backup,html,cshtml,xml,sql,nosql -w /usr/share/dirbuster/wordlists/directory-list-2.3-small.txt -t 100 --json-report=output/$url/recon/dirsearch.json
}

amassfunc() {
	echo "==================================================="
	echo "----^---------^--------ⓢⓤⓑⒺⓝⓤⓜ------"
	echo "[+] Running amass enum..."
	./dependencies/amass enum -d $url | tee output/$url/recon/amass.txt
	echo "Amass done!"
}

hostinfofunc() {
	if [ ! -d "output/$url/recon/host-details" ]; then
		mkdir output/$url/recon/host-details
	fi
	echo "==================================================="
	echo "----^---------^--------ⓢⓤⓑⒺⓝⓤⓜ------"
	echo "[+] Generating host information..."
	for line in $(cat output/$url/recon/final.txt); do host $line >>output/$url/recon/host-details/host-details.txt; done
}

whatwebfunc() {
	if [ ! -d "output/$url/recon/host-details" ]; then
		mkdir output/$url/recon/host-details
	fi
	echo "==================================================="
	echo "----^---------^--------ⓢⓤⓑⒺⓝⓤⓜ------"
	echo "[+] Running whatweb on targets..."
	for line in $(cat output/$url/recon/final.txt); do whatweb -t $line >>output/$url/recon/host-details/whatweb.txt; done
}

nmapfunc() {
	if [ ! -d "output/$url/recon/nmap" ]; then
		mkdir output/$url/recon/nmap
	fi
	echo "==================================================="
	echo "----^---------^--------ⓢⓤⓑⒺⓝⓤⓜ------"
	echo "[+] Scanning for open ports..."
	nmap -iL output/$url/recon/final.txt -T4 -oA output/$url/recon/nmap/open_ports.txt
}

gowitnessfunc() {
	if [ ! -d "output/$url/recon/screenshots" ]; then
		mkdir output/$url/recon/screenshots
	fi
	echo "==================================================="
	echo "----^---------^--------ⓢⓤⓑⒺⓝⓤⓜ------"
	./dependencies/gowitness file --source=./output/$url/recon/probed.txt --threads=6 --resolution="1200,750" --log-format=json --timeout=60 --destination="./output/$url/recon/screenshots/"
}

paramspiderfun() {
	if [ ! -d "output/$url/recon/" ]; then
		mkdir output/$url/recon
	fi
	echo "==================================================="
	echo "----^---------^--------ⓢⓤⓑⒺⓝⓤⓜ------"
	python3 ./dependencies/ParamSpider/paramspider.py --domain $url --exclude php,jpg --output ./output/$url/recon/paramspider.txt
}

waybackfunc() {
	if [ ! -d "output/$url/recon/wayback-data" ]; then
		mkdir output/$url/recon/wayback-data
	fi
	echo "==================================================="
	echo "----^---------^--------ⓢⓤⓑⒺⓝⓤⓜ------"
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
	echo "----^---------^--------ⓢⓤⓑⒺⓝⓤⓜ------"
}

################################################################################
#main()

################################################################################

#make necesary directories if not there

# Get the options
while getopts :hu:AsdabtnwepM option; do
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
		whatwebfunc
		nmapfunc
		dirsearchfunc &
		gowitnessfunc
		waybackfunc
		echo "All done! Results are saved to output/"$url
		echo "============================================"
		echo "----^---------^--------ⓢⓤⓑⒺⓝⓤⓜ------"
		# exit
		;;
	s)
		assetfinderfunc
		echo "All done! Results are saved to output/"$url
		echo "============================================"
		echo "----^---------^--------ⓢⓤⓑⒺⓝⓤⓜ------"
		# exit
		;;
	d)
		dirsearchfunc
		echo "All done! Results are saved to output/"$url
		echo "============================================"
		echo "----^---------^--------ⓢⓤⓑⒺⓝⓤⓜ------"
		# exit
		;;
	a)
		amassfunc
		echo "All done! Results are saved to output/"$url
		echo "============================================"
		echo "----^---------^--------ⓢⓤⓑⒺⓝⓤⓜ------"
		# exit 1
		;;
	t)
		if [ ! -f "output/$url/recon/final.txt" ]; then
			echo "[!] Could not find final.txt! Running with -s now."
			assetfinderfunc
		fi
		hostinfofunc
		echo "All done! Results are saved to output/"$url
		echo "============================================"
		echo "----^---------^--------ⓢⓤⓑⒺⓝⓤⓜ------"
		# exit
		;;
	b)
		if [ ! -f "output/$url/recon/final.txt" ]; then
			echo "[!] Could not find final.txt! Running with -s now."
			assetfinderfunc
		fi
		whatwebfunc
		echo "All done! Results are saved to output/"$url
		echo "============================================"
		echo "----^---------^--------ⓢⓤⓑⒺⓝⓤⓜ------"
		# exit
		;;
	n)
		nmapfunc
		echo "All done! Results are saved to output/"$url
		echo "============================================"
		echo "----^---------^--------ⓢⓤⓑⒺⓝⓤⓜ------"
		# exit
		;;
	e)
		if [ ! -f "output/$url/recon/final.txt" ]; then
			echo "[!] Could not find final.txt! Running with -s now."
			assetfinderfunc
		fi
		gowitnessfunc
		echo "All done! Results are saved to output/"$url
		echo "============================================"
		echo "----^---------^--------ⓢⓤⓑⒺⓝⓤⓜ------"
		# exit
		;;
	w)
		if [ ! -f "output/$url/recon/final.txt" ]; then
			echo "[!] Could not find final.txt! Running with -s now."
			assetfinderfunc
		fi
		waybackfunc
		echo "All done! Results are saved to output/"$url
		echo "============================================"
		echo "----^---------^--------ⓢⓤⓑⒺⓝⓤⓜ------"
		# exit
		;;
	p)
		paramspiderfun
		echo "All done! Results are saved to output/"$url
		echo "============================================"
		echo "----^---------^--------ⓢⓤⓑⒺⓝⓤⓜ------"
		# exit
		;;
	M)
		if [ ! -f "output/$url/recon/mayonaiseRecon/subDomains.txt" ]; then
			if [ ! -f "output/$url/recon/final.txt" ]; then
				echo "[!] Could not find final.txt! Running with -s now."
				assetfinderfunc
			fi
			if [ ! -f "output/$url/recon/amass.txt" ]; then
				echo "[!] Could not find amass.txt! Running with -s now."
				amassfunc
			fi
			if [ ! -d "output/$url/recon/mayonaiseRecon" ]; then
				mkdir output/$url/recon/mayonaiseRecon
			fi
			echo "============================================"
			echo "----^---------^--------ⓢⓤⓑⒺⓝⓤⓜ------"
			echo "[+] Combining, sorting and cleaning up results.."
			cat output/$url/recon/final.txt >output/$url/recon/mayonaiseRecon/subDomains.txt
			cat output/$url/recon/amass.txt >>output/$url/recon/mayonaiseRecon/subDomains.txt
			sort -u output/$url/recon/mayonaiseRecon/subDomains.txt
		fi
		if [ ! -f "output/$url/recon/mayonaiseRecon/livetargets.txt" ]; then
			echo "============================================"
			echo "----^---------^--------ⓢⓤⓑⒺⓝⓤⓜ------"
			echo "[+] Getting LiveTargers..."
			sudo python3 dependencies/LiveTargetsFinder/liveTargetsFinder.py --target-list output/$url/recon/mayonaiseRecon/subDomains.txt --massdns-path dependencies/LiveTargetsFinder/massdns/bin/massdns --masscan-path dependencies/LiveTargetsFinder/masscan/bin/masscan
			cp -r dependencies/LiveTargetsFinder/output/. output/$url/recon/mayonaiseRecon/
			if [ ! -d "output/$url/recon/mayonaiseRecon/massDnsRaw" ]; then
				mkdir output/$url/recon/mayonaiseRecon/massDns
				mv output/$url/recon/mayonaiseRecon/subDomains_massdns.txt output/$url/recon/mayonaiseRecon/massDns
			fi
			if [ ! -d "output/$url/recon/mayonaiseRecon/massScanRaw" ]; then
				mkdir output/$url/recon/mayonaiseRecon/massScan
				mv output/$url/recon/mayonaiseRecon/subDomains_masscan.txt output/$url/recon/mayonaiseRecon/massScan
			fi
			if [ ! -d "output/$url/recon/mayonaiseRecon/liveDomains" ]; then
				mkdir output/$url/recon/mayonaiseRecon/liveDomains
				mv output/$url/recon/mayonaiseRecon/subDomains_domains_alive.txt output/$url/recon/mayonaiseRecon/liveDomains
			fi
			if [ ! -d "output/$url/recon/mayonaiseRecon/liveIPs" ]; then
				mkdir output/$url/recon/mayonaiseRecon/liveIPs
				mv output/$url/recon/mayonaiseRecon/subDomains_ips_alive.txt output/$url/recon/mayonaiseRecon/liveIPs
			fi
			if [ ! -d "output/$url/recon/mayonaiseRecon/liveURLs" ]; then
				mkdir output/$url/recon/mayonaiseRecon/liveURLs
				mv output/$url/recon/mayonaiseRecon/subDomains_targetUrls.txt output/$url/recon/mayonaiseRecon/liveURLs
			fi
		fi
		if [ ! -d "output/$url/recon/mayonaiseRecon/wayback-data" ]; then
			echo "============================================"
			echo "----^---------^--------ⓢⓤⓑⒺⓝⓤⓜ------"
			echo "[+] Running wayback machine..."
			if [ ! -d "output/$url/recon/wayback-data" ]; then
			waybackfunc
			fi
			cp output/$url/recon/wayback-data/ output/$url/recon/mayonaiseRecon/
		fi
		echo "All done! Results are saved to output/"$url
		echo "============================================"
		echo "----^---------^--------ⓢⓤⓑⒺⓝⓤⓜ------"
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
