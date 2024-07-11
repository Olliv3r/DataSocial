#!/bin/bash
#
#

listReq=("ssh" "tar" "php" "jq" "curl" "tar" "toilet" "figlet" "ssh" "unzip" "proot")

install() {
    echo -e "\e[0m\e[33;1m[*] Installing packages...\e[0m"
    for package in ${listReq[*]} ; do
    	if [ -z "$(dpkg -l | grep $package)" ]; then

			if [ $package == "ssh" ] ; then
	    		if [ -d "$PREFIX" ] ; then
	        		package="openssh"
	    		else
					package="openssh-server"
		    	fi
			fi

			echo -e "\n\e[0mInstalling $package package...\e[0m"
			apt install $package -yq
		
		else
			echo -e "\n\e[0mThe '\e[1;33m$package\e[0m' package has already been installed before."
		fi
    done
    
    echo -e "\n\e[0m\e[32;1m[+] Installing packages...OK\e[0m"
}

uninstall() {
	    echo -e "\e[0m\e[33;1m[*] Uninstalling packages...\e[0m"
    for package in ${listReq[*]} ; do
    	if [ -n "$(dpkg -l | grep $package)" ]; then

			if [ $package == "ssh" ] ; then
	    		if [ -d "$PREFIX" ] ; then
	        		package="openssh"
	    		else
					package="openssh-server"
		    	fi
			fi

			echo -e "\n\e[0mUninstalling $package package...\e[0m"
			apt purge $package -y
		
		else
			echo -e "\n\e[0mThe '\e[1;33m$package\e[0m' package has already been uninstalled before."
		fi
    done

    apt autoremove && apt autoclean
    
    echo -e "\n\e[0m\e[32;1m[+] Ininstalling packages...OK\e[0m"
}

usage() { echo -e "\nUsage: $(basename $0) --install | --uninstall\n" ;}

case "$1" in
	"") usage				   ;;
	"--install")   install     ;;
	"--uninstall") uninstall   ;;
	*)
		usage				   ;;
esac
