#!/bin/bash
#
# setup.sh - instala pacotes necessários para rodar o datasocial.sh e instala opcionalmente serviços de tunelamento.
#
# 
# Por Oliver Silva - https://github.com/Olliv3r
#

BASE_DIR="$(dirname "$(realpath "$0")")"

source $BASE_DIR/config/msg.sh


# Pacotes necessários
required_packages=("openssh-server" "tar" "php" "jq" "curl" "unzip" "ncurses-bin")
# Pacotes essênciais
essential_packages=("tar" "ncurses-bin")

# Instalador do Ngrok:
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
            msg "err" "Arquitetura desconhecida: $uname_arch."
            return 1
            ;;
    esac

    local url="https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-${arch}.tgz"
    
    msg "info" "Baixando ngrok para arquitetura $arch..."
    curl -sSL "$url" -o ngrok.tgz || { msg "err" "Erro ao baixar ngrok."; return 1; }

    msg "info" "Extraindo ngrok..."
    tar -xzf ngrok.tgz || { msg "err" "Erro ao extrair ngrok."; return 1; }
    chmod +x ngrok
    mv ngrok bin

    rm ngrok.tgz
    msg "ok" "ngrok instalado com sucesso. Versão instalada: $($BASE_DIR/bin/ngrok --version)"
}

# Instalador do cloudflared:
install_cloudflared() {
	set -e
	
	# Detectar arquitetura
	ARCH=$(uname -m)
	
	# Mapear para os nomes usados pela Cloudflare
	case "$ARCH" in
	    x86_64 | amd64)
	        ARCH_DL="amd64"
	        ;;
	    i386 | i686)
	        ARCH_DL="386"
	        ;;
	    armv6l | armv7l)
	        ARCH_DL="arm"
	        ;;
	    aarch64 | arm64)
	        ARCH_DL="arm64"
	        ;;
	    *)
	        msg "err" "Arquitetura $ARCH não suportada automaticamente."
	        exit 1
	        ;;
	esac
	
	# URL de download
	URL="https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-$ARCH_DL"
	
	# Baixar binário
	msg "info" "Baixando cloudflared para arquitetura $ARCH_DL..."
	curl -L "$URL" -o cloudflared
	
	# Tornar executável
	chmod +x cloudflared
	
	# Mover para bin (pode pedir sudo)
	msg "info" "Movendo cloudflared para $BASE_DIR/bin..."
	mv cloudflared $BASE_DIR/bin
	
	# Verificar instalação
	version="$($BASE_DIR/bin/cloudflared --version)"
	msg "ok" "Instalação concluída. Versão instalada: $(msg "ok" "$version")"
}

# Instala pacotes necessários para rodar o datasocial.sh
install() {
	msg "info" "Instalando pacotes..."
	
  	for package in "${required_packages[@]}"; do
    	if ! dpkg -s "$package" &> /dev/null; then
    		msg "info" "Instalando '$package'..."
    		apt install "$package" -yq || {
    			msg "err" "Falha ao tentar instalar o pacote '$package'."
    			continue
    		}
    	else
	  		msg "warn" "O pacote '$package' já existe no sistema."
		fi
  	done
    
  	msg "ok" "Instalando pacotes...OK"
}

# Desinstala requisitos
uninstall() {
	msg "info" "Removendo pacotes..."

  	for package in "${required_packages[@]}" ; do
		if [[ " ${essential_packages[*]} " == *" $package "* ]]; then
			msg "err" "Pacote essêncial detectado, ignorando remoção de $package."
			continue
		fi
  	
    	if dpkg -s "$package" &> /dev/null; then
    		msg "info" "Removendo pacote $package..."
    		
    		if apt remove -y "$package"; then
    			msg "ok" "Removido: '$package'."
    		else
				msg "err" "Falha ao remover o pacote '$package'."
			fi
    		
	    else  	
    		msg "warn" "O pacote '$package' já foi removido antes."
   		fi
  	done

  	if apt autoremove -y && apt autoclean; then
  		msg "ok" "Cache limpo...OK"
  	fi
  	
  	msg "ok" "Removendo pacotes...OK"
}

usage() { echo -e "\nUsage: $(basename $0) --install | --uninstall | --install-ngrok | --install-cloudflared\n" ;}

case "$1" in
  	"") usage;;
  	--install) install;;
  	--uninstall) uninstall;;
  	--install-ngrok) install_ngrok;;
  	--install-cloudflared) install_cloudflared;;
  	*) usage;;
esac
