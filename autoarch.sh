#!/usr/bin/env bash
#
# Main script

source setupfuncs.sh
source outcolors.sh

export INIT_DIR
INIT_DIR=$(pwd)
export MICI_FILE='backup/mkinitcpio.conf'
export PACMAN_FILE='/etc/pacman.conf'

while getopts ":hr" option; do
   case $option in
      h) # Display Help
        help_out
        exit;;
      r) # Run reset_cfgs function
        restore_cfgs
        exit;;
     \?) # Invalid option
        echo "Error: Invalid option"
        exit;;
   esac
done

logo_out

echo -n -e "$LA Would you like to optimize the system? [Y/n]: "
read -r UC

if [[ $UC == 'Y' || $UC == 'y' || $UC == '' ]]; then
  mkdir backup
  mkdir temp
  sudo pacman -Syu

  sort_repo
  graphics_drivers_install
  mici_edit
  microcodes_install
  install_serdae
  parallel_download
  cpu_powermode
fi
