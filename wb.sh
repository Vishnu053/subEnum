url=$1
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
