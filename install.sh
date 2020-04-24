#!/bin/bash

#This will create a bashrc alias for quick execution
echo "Taking a backup of your .bashrc file.."
cp ~/.bashrc ~/.bashrc-copy-backup
filepth=`pwd`
sudo echo "alias subEnum='$filepth/./subEnum.sh'" >> ~/.bashrc
echo "Path added to your .bashrc file"
echo "The backup of .bashrc can be found at ~/.bashrc-copy-backup"