#!/bin/bash
# createUsers.sh
# creates users and sets passwords on a Linux system
# contact: allynstott@gmail.com

# variables for file locations
useraddBin=/usr/sbin/useradd
chpasswdBin=/usr/sbin/chpasswd

# input file
ifile="$1"
ofile="/tmp/tpasswd"

# convert dos to unix via sed
sed 's/$//' $ifile > $ofile

# ./createUsers.sh input.txt
if [ $# -lt 1 -o $# -eq 1 -a "$1" == "-h" -o "$1" == "--help" ]; then
  echo "Batch user creation on a Linux system"
  echo ""
  echo "usage: $0 input.txt"
  echo ""
  echo "input.txt should be in the following format:"
  echo "username1:password1"
  echo "username2:password2"
  echo "username3:password3"
  echo "..."
  echo ""
  exit 1
fi

# check that user is root
if [ $EUID -ne 0 ]; then
   echo "This script must be run as root!" 
   exit 1
fi


# check that useradd exists on system
if [ ! -f $useraddBin ]; then
  echo "Cannot find $useraddBin"
  echo "Please change the useraddBin variable in this script"
  exit 1
fi

# check that chpasswd exists on system
if [ ! -f $chpasswdBin ]; then
  echo "Cannot find $chpasswdBin"
  echo "Please change the chpasswdBin variable in this script"
  exit 1
fi

# create users with home directories
while read line; do
  username="`echo $line | cut -d':' -f1`"
  echo "Creating user $username"
  $useraddBin -m "$username"
  echo "If user already existed, remove the .bash_history file..."
  rm -f /home/$username/.bash_history
done < $ofile

echo "Setting user passwords"
$chpasswdBin < $ofile

echo "Deleting converted file"
rm -rf $ofile

# remove the history
echo "Deleting root's bash history..."
rm -f /root/.bash_history

# finished
echo "Complete!"
