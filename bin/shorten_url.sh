#!/usr/bin/env bash
# ==========================================================
#  shorten_url.sh - Encurtador de URLs via CLI
# ----------------------------------------------------------
#  Suporta múltiplos encurtadores:
#    - is.gd
#    - v.gd
#    - tinyurl
#    - bitly (com token)
#    - mais em breve...
# ----------------------------------------------------------
#  Uso:
#    ./shorten_url.sh <url> <tipo_encurtador> <token(opcional)>
#    Ex: ./shorten_url.sh https://google.com bitly SEU_TOKEN
# ----------------------------------------------------------
#  Autor: Olliv3r
#  GitHub: https://github.com/Olliv3r
# ==========================================================

services_shorten=("isgd" "vgd" "bitly" "tinyurl")

# Encurta uma URL usando o encurtador escolhido ou tenta vários
# Parâmetros:
#   $1 - URL original
#   $2 - (opcional) Encurtador: isgd, vgd, tny, tinyurl, auto (padrão: auto)
shortenUrl() {
	local url="$1"
	local type="$2"
	local token="$3"
	local short_url=""

	# Se um serviço específico foi escolhido
	if [[ -n "$type" && "$type" != "auto" ]]; then
		services_shorten=("$type")
	fi

	for service_shorten in "${services_shorten[@]}"; do
		case "$service_shorten" in
			isgd)
				short_url=$(curl -s "https://is.gd/create.php?format=simple&url=${url}");;
				
			vgd)
				short_url=$(curl -s "https://v.gd/create.php?format=simple&url=${url}");;
				
			bitly)
				[ -z "$token" ] && {
					echo "Precisa do token de acesso da conta."
					exit 1
				}
				
				response=$(curl -s -X POST "https://api-ssl.bitly.com/v4/shorten" \
				-H "Authorization: Bearer $token" \
				-H "Content-Type: application/json" \
				-d '{"long_url": "'"$url"'"}')

				short_url=$(echo "$response" | jq -r ".link")
				;;
				
			tinyurl)
				short_url=$(curl -s "https://tinyurl.com/api-create.php?url=${url}");;
			*)
				echo -e "${red}[x]${reset} Serviço de encurtamento inválido: ${yellow}type${reset}"
				continue;;
		esac

		if [[ "$short_url" =~ ^https?:// ]]; then
			echo -e "${green}[+]${reset} URL encurtada com ${type}: ${yellow}$short_url${reset}"
			return 0
		fi
	done

	echo -e "${red}[x]${reset} Falha ao encurtar a URL com oos serviços disponíveis."
	return 1
	
}


if [ $# -lt 1 ]; then 
	echo "Usage: $(basename "$0") <url> <type_shorten> <token (optional)>"
	exit 1
fi


url="$1"
type="${2:-auto}"
token="${3:-}"

shortenUrl "$url" "$type" "$token"
