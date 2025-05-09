#!/bin/bash
#
# setup.sh - instala pacotes obrigatórios para o datasocial.sh

listReq=(
  "ssh" 
  "tar" 
  "php" 
  "jq" 
  "curl" 
  "tar" 
  "toilet" 
  "figlet" 
  "ssh" 
  "unzip"
  "proot"
  "ncurses-utils" 
  "cloudflared"
)

install_ngrok() {
    local uname_arch
    uname_arch=$(uname -m)

    case "$uname_arch" in
        x86_64)
            arch="amd64"
            ;;
        i386|i686)
            arch="386"
            ;;
        aarch64|arm64)
            arch="arm64"
            ;;
        armv7l|armv6l)
            arch="arm"
            ;;
        *)
            echo "Arquitetura desconhecida: $uname_arch"
            return 1
            ;;
    esac

    local url="https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-${arch}.tgz"
    
    echo "Baixando ngrok para arquitetura $arch..."
    curl -sSL "$url" -o ngrok.tgz || { echo "Erro ao baixar ngrok."; return 1; }

    echo "Extraindo ngrok..."
    tar -xzf ngrok.tgz || { echo "Erro ao extrair ngrok."; return 1; }
    chmod +x ngrok
    mv ngrok bin

    rm ngrok.tgz
    echo "ngrok instalado com sucesso."
}

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
      apt install "$package" -yq
		
    else
      echo -e "\n\e[0mThe '\e[1;33m$package\e[0m' package has already been installed before."
    fi
  done
    
  echo -e "\n\e[0m\e[32;1m[+] Installing packages...OK\e[0m"

  install_ngrok
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
      apt purge "$package" -y
		
    else
      echo -e "\n\e[0mThe '\e[1;33m$package\e[0m' package has already been uninstalled before."
    fi
  done

  apt autoremove && apt autoclean
  echo -e "\n\e[0m\e[32;1m[+] Ininstalling packages...OK\e[0m"
}

usage() { echo -e "\nUsage: $(basename $0) --install | --uninstall\n" ;}

case "$1" in
  "") usage;;
  -i | --install) install;;
  -u | --uninstall) uninstall;;
  *) usage;;
esac
