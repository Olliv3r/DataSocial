#!/bin/bash
# mag.sh - Imprime alertas personalizados
#
# Por Oliver Silva - https://github.com/Olliv3r
#

# Alertas personalizados
msg() {
	local type="$1"
	local text="$2"
	local is_prefix="$3"
	local reset="\e[0m"

	case "$type" in
		info) n=34; prefix="*";;
		err) n=31; prefix="-";;
		warn) n=33; prefix="!";;
		ok) n=32; prefix="+";;
		reset) n=0; prefix="?";;
	esac

	cor="\e[1;${n}m"

	if [ "$is_prefix" == "is_prefix" ]; then
		echo -e "${cor}[${prefix}] ${text}${reset}"
	else
		echo -e "${cor}${text}${reset}"
	fi
}
