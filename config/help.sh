#!/usr/bin/env bash
# Telaa de ajuda para modo de opçôes e interativo
#

showHelp() {
    bold=$'\e[1m'
    reset=$'\e[0m'

    printf "${bold}Uso:${reset} %s [opções]\n\n" "$(basename "$0")"

    printf "${bold}Opções disponíveis:${reset}\n"
    printf "  %-32s %s\n" "-h, --help" "Mostra este menu de ajuda"
    printf "  %-32s %s\n" "-v, --version" "Exibe a versão atual do script"
    printf "  %-32s %s\n" "--auth-ngrok <token>" "Adiciona o token de autenticação do Ngrok"
    printf "  %-32s %s\n" "--generate-ssh-key <email>" "Gera uma chave SSH usando o e-mail fornecido"
    printf "  %-32s %s\n" "--listen <serviço>" "Define o serviço local para escutar"
    printf "  %-32s %s\n" "--tunnel <túnel>" "Define o túnel público para escutar"
    printf "  %-32s %s\n" "--services" "Lista todos os serviços disponíveis"
    printf "  %-32s %s\n" "--tunnels" "Lista todos os túneis disponíveis"
    printf "  %-32s %s\n" "--silent" "Executa sem exibir mensagens na tela"
    printf "  %-32s %s\n" "-i, --interactive" "Modo interativo"

    printf "\n${bold}Exemplo:${reset}\n"
    printf "  %s\n" "$(basename "$0") --listen google --tunnel ngrok --silent"

    exit 0
}

showHelpInteractive() {
    # Cores (opcional)
    bold='\e[1m'; reset='\e[0m'

    printf "\n${bold}Comandos disponíveis:${reset}\n\n"
    printf "  %-22s %s\n" "help, ?"           "Exibir esta ajuda"
    printf "  %-22s %s\n" "show"              "Exibir serviços, túneis e configurações"
    printf "  %-22s %s\n" "use"               "Selecionar serviço"
    printf "  %-22s %s\n" "set"               "Definir túnel ou modo silencioso"
    printf "  %-22s %s\n" "execute, run"      "Iniciar ataque"
    printf "  %-22s %s\n" "exploit"           "Sinônimo de execute"
    printf "  %-22s %s\n" "exit, quit"        "Sair do programa"
    echo
}
