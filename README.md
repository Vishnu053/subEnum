# subEnum
An automated enumeration tool that uses the most popular tools to automate the process in a single command.

### REQUIREMENTS
This script makes use of various popular tools listed below. Please make sure to install the tools **marked as not included**.
1. assetfinder (Included)
2. httprobe (included)
3. dirsearch (included)
4. amass (included)
5. nmap (not included)
6. waybackurls (included)

### INSTALLATION
You can run chmod +x install.sh && ./install.sh to create an alias in your bashrc file.

### SYNTAX
subEnum.sh URL
subEnum.sh -h displays help.

### ANALYSIS
All the reports will be generated automatically inside the output folder by category.

### CONTRIBUTION
All kinds of contributions are welcome. You are welcome to add any useful enumeration tools that you use regularly. 
Please make sure to include that tool inside the *dependencies* folder and call the tool from there.
