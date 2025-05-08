#!/usr/bin/env bash
# Menu de ajuda
#

showHelp() {
    echo -e "
Uso: $(basename "$0") [opções]

Opções disponíveis:
  -h, --help                 Mostra este menu de ajuda
  
  -v, --version              Exibe a versão atual do script

  --auth-ngrok <token>       Adiciona o token de autenticação do Ngrok
  
  --auth-localxpose <token>  Adiciona o token de autenticação do Localxpose
  
  --generate-ssh-key <email> Gera uma chave SSH usando o e-mail fornecido

  --listen <serviço>         Define o serviço local para escutar
  
  --tunnel <túnel>           Define o túnel público para escutar

  --services                 Lista todos os serviços disponíveis
  
  --tunnels                  Lista todos os túneis disponíveis

  --silent                   Executa sem exibir mensagens na tela

Exemplo:
  $(basename "$0") --listen google --tunnel ngrok --silent
"
    exit 0
}
