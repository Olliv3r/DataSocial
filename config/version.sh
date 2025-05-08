#!/usr/bin/env bash
# Versão do programa
#

# Exibe a versão atual do programa
showVersion() {
    echo -ne "$(basename "$0")"
    
    grep "^# Versão" "$0" | tail -1 | cut -d ":" -f 1 | tr -d \# | tr A-Z a-z

    exit 0
}
