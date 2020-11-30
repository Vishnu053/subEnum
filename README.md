# subEnum
An automated enumeration tool that uses the most popular tools to automate the process in a single command. A seperate termux branch is also available.

### REQUIREMENTS
This script makes use of various popular tools listed below. Please make sure to install the tools **marked as not included**.
1. assetfinder (Included)
2. httprobe (included)
3. dirsearch (included)
4. amass (included)
5. nmap (not included)
6. waybackurls (included)
7. whatweb (not included)
8. paramSpider (included)
9. gowitness (included)

### INSTALLATION
#### The install.sh is not yet ready! Use this file at your own risk! 
You can run chmod +x install.sh && ./install.sh to create an alias in your bashrc file. This is not essential to run subEnum.

### SYNTAX
./subEnum.sh options

	options:
	-h     Print this Help.
	-u     The target to enumerate.
	-A     Run everything.
	-s     Get subdirectories.
	-d     Run dirsearch.
	-t     Run host identification.
    -b     Run whatweb.
	-a     Run amass.
	-n     Run nmap.
	-w     Run wayback.
	-p 	   Run ParamSpider.
	-e     Take screenshots using gowitness.

### ANALYSIS
All the reports will be generated automatically inside the output folder by category.


### CONTRIBUTION
All kinds of contributions are welcome. You are welcome to add any useful enumeration tools that you use regularly. 
Please make sure to include that tool inside the *dependencies* folder and call the tool from there.
