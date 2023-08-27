#!/bin/bash
#
#

listReq=("ssh" "tar" "php" "jq" "curl" "tar" "toilet" "figlet" "ssh")

installPackage() {
    echo -e "\e[0m\e[33;1m[*] Installing packages...\e[0m"
    for package in ${listReq[*]} ; do
	if [ $package == "ssh" ] ; then
	    if [ -d "$PREFIX" ] ; then
	        package="openssh"
	    else
		package="openssh-server"
	    fi
	fi

	apt update && apt upgrade -y && apt install $package -y

    done
    echo -e "\e[0m\e[32;1m[+] Installing packages...OK\e[0m"
}


installPackage
