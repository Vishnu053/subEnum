#!/bin/bash

#This will create a bashrc alias for quick execution
echo "Taking a backup of your .bashrc file.."
cp ~/.bashrc ~/.bashrc-copy-backup
filepth=`realpath subEnum.sh`
sudo echo "alias subEnum='.$filepth'" >> ~/.bashrc
echo "Path added to your .bashrc file"
echo "The backup of .bashrc cann be found at ~/.bashrc-copy-backup"