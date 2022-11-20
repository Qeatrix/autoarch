#!/bin/env bash
#
# All output graphics and color variables

export COLOR_OFF='\033[0m'
export BGREEN='\033[0;32m'
export BBLUE='\033[1;34m'
export BYELLOW='\033[1;33m'

export LA="${BGREEN}::${COLOR_OFF}"
export NA="${BGREEN}=>${COLOR_OFF}"

function logo_out {
  echo
  echo '   ___       __       ___           __ '
  echo '  / _ |__ __/ /____  / _ | ________/ / '
  echo ' / __ / // / __/ _ \/ __ |/ __/ __/ _ \'
  echo '/_/ |_\_,_/\__/\___/_/ |_/_/  \__/_//_/'
  echo '                                       '
}

function help_out {
  echo 'AutoArch - Automatically configure your Arch Linux'
  echo 
  echo 'Options:'
  echo '  -r     Restore mkinitcpio.conf and pacman.conf'
  echo
}

function write_out {
  echo -e " ${BGREEN}######################${COLOR_OFF}"
  echo -e " ${BGREEN}# ---- [ Done ] ---- #${COLOR_OFF}"
  echo -e " ${BGREEN}######################${COLOR_OFF}"
}

