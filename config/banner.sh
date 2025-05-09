#!/usr/bin/env bash
# banner.sh
#

showBanner() {
    local w="\e[0m"       # Reset
    local b="\e[34;1m"    # Azul forte
    local f="\e[34;3m"    # Azul itálico

    echo -e "${b}

                '
              '   '  TIOOLIVER | ${f}https://t.me/tiooliver_sh
            '       '   ${f}https://youtube.com/@tioolive ${w}${b}- BRAZIL
        . ' .    '    '                       '
     '              '                      '   '
  █▀▄ ▄▀█ ▀█▀ ▄▀█   █▀ █▀█ █▀▀ █ ▄▀█ █░░
  █▄▀ █▀█ ░█░ █▀█   ▄█ █▄█ █▄▄ █ █▀█ █▄▄
  .                          ..'.    ' .
    '  .                   .     '       '
          ' .  .  .  .  . '.    .'         '  '
             '         '    '. '              .
               '       '      '
                 ' .  '   Site: ${f}https://toolmuxapp.pythonanywhere.com${w}
"
}

showBannerInteractive() {
	clear
	echo -e "${red}     ____        _        ____             _      _ "
	echo -e "${red}    |  _ \  __ _| |_ __ _/ ___|  ___   ___| | __ (_)"
	echo -e "${red}    | | | |/ _\` | __/ _\` \___ \ / _ \ / __| |/ / | |"
	echo -e "${red}    | |_| | (_| | || (_| |___) | (_) | (__|   < _| |"
	echo -e "${red}    |____/ \__,_|\__\__,_|____/ \___/ \___|_|\_(_)_|"
	echo -e "${reset}"
	echo -e "${cyan}             Welcome to DataSocial Framework"
	echo -e "${cyan}              Type 'help' for commands"
	echo -e "${reset}"
}
