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
