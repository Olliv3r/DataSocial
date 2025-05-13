#!/bin/bash
#
# setup.sh - instala pacotes necessários para rodar o datasocial.sh e instala opcionalmente serviços de tunelamento.
#
# 
# Por Oliver Silva - https://github.com/Olliv3r
#

BASE_DIR="$(dirname "$(realpath "$0")")"

source $BASE_DIR/config/msg.sh
source $BASE_DIR/config/help.sh


# Pacotes necessários
required_packages=("openssh-server" "tar" "php" "jq" "curl" "unzip" "ncurses-bin")
# Pacotes essênciais
essential_packages=("tar" "curl" "ncurses-bin")

# Configura o DataSocial pra rodar de forma global
install() {
	local INSTALL_DIR="$PREFIX/opt/datasocial"
	local BIN_LINK="$PREFIX/bin/datasocial"

	[ ! -d "$INSTALL_DIR" ] && mkdir -p "$INSTALL_DIR"

	cp -rf bin config websites datasocial.sh "$INSTALL_DIR"
	chmod +x "$INSTALL_DIR/datasocial.sh"


	cat ->> "$BIN_LINK" <<- EOF
	#!/bin/bash
	exec $INSTALL_DIR/datasocial.sh "\$@"
	EOF

	chmod +x "$BIN_LINK"

	msg "ok" "DataSocial instalado com sucesso." "is_prefix"
	msg "ok" "Use o comando: $(msg "warn" "datasocial")" "is_prefix"
}

# Desconfigura o DataSocial
uninstall() {
	local INSTALL_DIR="$PREFIX/opt/datasocial"
	local BIN_LINK="$PREFIX/bin/datasocial"

	msg "info" "Desinstalado DataSocial..." "is_prefix"

	if [ -f "$BIN_LINK" ]; then
		rm -f "$BIN_LINK"
		msg "ok" "Removido: $(msg "warn" "$BIN_LINK")" "is_prefix"
	else
		msg "warn" "Binário não foi encontrado." "is_prefix"
	fi

	if [ -d "$INSTALL_DIR" ]; then
		rm -rf "$INSTALL_DIR"
		msg "ok" "Removido: $(msg "warn" "$INSTALL_DIR")" "is_prefix"
	else
		msg "warn" "Diretório de instalação não foi encontrado." "is_prefix"
	fi

	msg "ok" "DataSocial desinstalado com sucesso." "is_prefix"
	
}

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
install_req() {
	msg "info" "Instalando pacotes..."
	
  	for package in "${required_packages[@]}"; do
		if [ -d "$PREFIX" ] || [ -d "/data/data/com.termux/files/home" ]; then
			case "$package" in
				openssh-server) original_package="openssh";;
				ncurses-bin) original_package="ncurses-utils";;
				*) original_package=$package;;
			esac
		else
			case "$package" in
				openssh) original_package="openssh-server";;
				ncurses-utils) original_package="ncurses-bin";;
				*) original_package=$package;;
			esac
		fi
  		
    	if ! command -v "$original_package" > /dev/null 2>&1; then
    		msg "info" "Instalando '$original_package'..."
    		apt install "$original_package" -y || {
    			msg "err" "Falha ao tentar instalar o pacote '$original_package'."
    			continue
    		}
    	else
	  		msg "warn" "O pacote '$original_package' já existe no sistema."
		fi
  	done
    
  	msg "ok" "Instalando pacotes...OK"
}

# Desinstala requisitos
uninstall_req() {
	msg "info" "Removendo pacotes..."

  	for package in "${required_packages[@]}" ; do
 		if [ -d "$PREFIX" ] || [ -d "/data/data/com.termux/files/home" ]; then
 			case "$package" in
 				openssh-server) original_package="openssh";;
 				ncurses-bin) original_package="ncurses-utils";;
 				*) original_package=$package;;
 			esac
 		else
 			case "$package" in
 				openssh) original_package="openssh-server";;
 				ncurses-utils) original_package="ncurses-bin";;
 				*) original_package=$package;;
 			esac
 		fi
  	
		if [[ " ${essential_packages[*]} " == *" $original_package "* ]]; then
			msg "err" "Pacote essêncial detectado, ignorando remoção de $original_package."
			continue
		fi
  	
    	if command -v "$original_package" > /dev/null 2>&1; then
    		msg "info" "Removendo pacote $original_package..."
    		
    		if apt remove -y "$original_package"; then
    			msg "ok" "Removido: '$original_package'."
    		else
				msg "err" "Falha ao remover o pacote '$original_package'."
			fi
    		
	    else  	
    		msg "warn" "O pacote '$original_package' já foi removido antes."
   		fi
  	done

  	if apt autoremove -y && apt autoclean; then
  		msg "ok" "Cache limpo...OK"
  	fi
  	
  	msg "ok" "Removendo pacotes...OK"
}

case "$1" in
  	"") showHelpSetup;;
  	--install) install;;
  	--uninstall) uninstall;;
  	--install-req) install_req;;
  	--uninstall-req) uninstall_req;;
  	--install-ngrok) install_ngrok;;
  	--install-cloudflared) install_cloudflared;;
  	*) usage;;
esac
