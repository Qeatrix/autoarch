#!/bin/env bash
#
# All functions

GPU=''

function sort_repo {
	local UC

	echo -n -e "$LA Would you like to sort repositories by speed? [Y/n]: "
	read -r UC

	if [[ $UC == 'Y' || $UC == 'y' || $UC == '' ]]; then
    sudo pacman -S reflector rsync curl

    echo -n -e "$LA Enter your country: "
    read -r UC

		sudo reflector --verbose --country "$UC" -l 25 --sort rate --save /etc/pacman.d/mirrorlist
	fi

	return 0;
}


function graphics_drivers_install {
	local UC

	echo -n -e "$LA Would you like to install graphics drivers? [Y/n]: "
	read -r UC

	if [[ $UC == 'Y' || $UC == 'y' || $UC == '' ]]; then

		echo -n -e "Select a manufacturer:\n  1) AMD   2) Nvidia   3) Intel\nSelection $NA "
		read -r UC

		if [[ $UC == '1' ]]; then
			GPU="amd"
			sudo pacman -S mesa lib32-mesa vulkan-radeon lib32-vulkan-radeon vulkan-icd-loader lib32-vulkan-icd-loader mesa-vdpau lib32-mesa-vdpau lib32-libva-mesa-driver

		elif [[ $UC == '2' ]]; then
			GPU="nvidia"
			sudo pacman -S nvidia-dkms nvidia-utils lib32-nvidia-utils nvidia-settings vulkan-icd-loader lib32-vulkan-icd-loader lib32-opencl-nvidia opencl-nvidia libxnvctrl && sudo mkinitcpio -P
		
		elif [[ $UC == '3' ]]; then
			GPU="intel"
			sudo pacman -S mesa lib32-mesa vulkan-intel lib32-vulkan-intel vulkan-icd-loader lib32-vulkan-icd-loader
		fi
	fi
	
	return 0;
}


function mici_edit {
	local UC

	echo -n -e "$LA Would you like to add additional modules to mkinitcpio.conf file? [Y/n]: "
	read -r UC

	if [[ $UC == 'Y' || $UC == 'y' || $UC == '' ]]; then

    #use HDD modules and hooks
    local use_hdd_com=false

    #get modules and hooks strings from file
    local modules		
    modules=$(sed '1q;d' /etc/mkinitcpio.conf | sed 's/.$//')

    local hooks
    hooks=$(sed '4q;d' /etc/mkinitcpio.conf | sed 's/.$//')


    #install additional firmware
    cd temp || exit
    git clone https://aur.archlinux.org/mkinitcpio-firmware.git
    cd mkinitcpio-firmware || exit
    makepkg -sric
    cd "$INIT_DIR" || exit

		echo -n -e "$LA Are you using btrfs? [Y/n]: "
		read -r UC

		if [[ $UC == 'Y' || $UC == 'y' || $UC == '' ]]; then
			modules="$modules btrfs"
		fi

		echo -n -e "$LA Install modules for your graphics card? [Y/n]: "
		read -r UC

		if [[ $UC == 'Y' || $UC == 'y' || $UC == '' ]]; then
      if [[ $GPU != 'amd' || $GPU != 'nvidia' || $GPU != 'intel' ]]; then
        echo -n -e "Select a manufacturer:\n  1) AMD   2) Nvidia   3) Intel\nSelection $NA "
        read -r GPU
      fi
			if [[ $GPU == '1' ]]; then
				modules="$modules amdgpu radeon"
			elif [[ $GPU == '2' ]]; then
				modules="$modules nvidia nvidia_modeset nvidia_uvm nvidia_drm"
			elif [[ $GPU == '3' ]]; then
				modules="$modules crc32c-intel intel_agp i915"
			fi

			echo -n -e "$LA Would you like to speed up the loading of the kernel on the HDD? [y/N]: "
			read -r UC

			if [[ $UC == 'y' ]] || [[ $UC == 'y' ]]; then
				sudo pacman -S lz4

				if sudo grep -q 'COMPRESSION="lz4"' /etc/mkinitcpio.conf; then
					:
				else
					echo 'COMPRESSION="lz4"' | sudo tee /etc/mkinitcpio.conf > /dev/null
				fi
				if sudo grep -q 'COMPRESSION_OPTIONS="-9"' /etc/mkinitcpio.conf; then
					:
				else
						echo 'COMPRESSION_OPTIONS="-9"' | sudo tee /etc/mkinitcpio.conf > /dev/null
				fi

        use_hdd_com=true
				hooks="$hooks shutdown)"
			fi

			modules="${modules})"

      #print edited file
      echo ' Check the changes: '
      echo -e " 1 | ${BGREEN}$modules${COLOR_OFF}"
      echo -e ' 2 | '"$(grep BINARIES /etc/mkinitcpio.conf)"
      echo -e ' 3 | '"$(grep FILES /etc/mkinitcpio.conf)"

      if [[ $use_hdd_com == false ]]; then
        echo -e " 4 | ${hooks})"
      else
        echo -e " 4 | ${BGREEN}$hooks${COLOR_OFF}"
        echo -e " 5 | ${BGREEN}COMPRESSION="lz4"${COLOR_OFF}"
        echo -e " 6 | ${BGREEN}COMPRESSION_OPTIONS="-9"${COLOR_OFF}"
      fi

      echo -n -e "$LA Do you agree with the changes? [Y/n]: "
      read -r UC

      #backup and apply the changes
      if [[ $UC == 'Y' || $UC == 'y' || $UC == '' ]]; then
        if [[ -f "$MICI_FILE" ]]; then
          echo "${BYELLOW}:${COLOR_OFF} The file has already been backed up, a new backup has been cancelled."
        else
          sudo cp /etc/mkinitcpio.conf backup/mkinitcpio.conf
        fi

        sudo sed -i "1s/.*/$modules/" /etc/mkinitcpio.conf
        sudo sed -i "4s/.*/$hooks/" /etc/mkinitcpio.conf

        write_out 

        sudo mkinitcpio -P
      fi
		fi
	fi

	return 0;
}


function microcodes_install {
	local UC

	echo -n -e "$LA Would you like to install microcodes? [Y/n]: "
	read -r UC

	if [[ $UC == 'Y' || $UC == 'y' || $UC == '' ]]; then
		echo -n -e "Select a manufacturer:\n  1) Intel   2) AMD\nSelection $NA "
		read -r UC

		if [[ $UC == '1' ]]; then
			sudo pacman -S intel-ucode
		elif [[ $UC == '2' ]]; then
			sudo pacman -S amd-ucode
		fi
	
		sudo mkinitcpio -P

		echo -n -e "$LA Are you using GRUB? [Y/n]: "
		read -r UC

		if [[ $UC == 'Y' || $UC == 'y' || $UC == '' ]]; then
			sudo grub-mkconfig -o /boot/grub/grub.cfg
		fi
	fi

  return 0;
}


function install_serdae {
	local UC

	echo -n -e "$LA Do you want to install useful services and daemons? [Y/n]: "
	read -r UC

	if [[ $UC == 'y' ||  $UC == 'y' || $UC == '' ]]; then

		echo -n -e "$LA Is the system loading speed important to you?\n   Y: Install Rng-tools, Dbus-broker\n   N: Install Ananicy, Haveged, Dbus-broker\n   C: Do not install\n [y/n/C]: "
		read -r UC

		if [[ $UC == 'Y' || $UC == 'y' ]]; then
      sudo pacman -Rscun rng-tools

			# Install rng-tools - A daemon that monitors the entropy of the system through a hardware timer
			sudo pacman -S rng-tools
			sudo systemctl enable --now rngd
			
      # Install dbus-broker - implementation of a message bus in accordance with the D-Bus specification
			sudo pacman -S dbus-broker
			sudo systemctl enable --now dbus-broker.service
			sudo systemctl --global enable dbus-broker.service
		elif [[ $UC == 'N' || $UC == 'n' ]]; then
      sudo pacman -Rscun rng-tools

			cd temp || exit
			git clone https://aur.archlinux.org/ananicy-cpp.git
			cd ananicy-cpp || exit
			makepkg -sric
      cd "$INIT_DIR" || exit
			sudo systemctl enable --now ananicy-cpp

			sudo pacman -S haveged
			sudo systemctl enable haveged

			sudo pacman -S dbus-broker
			sudo systemctl enable --now dbus-broker.service
			sudo systemctl --global enable dbus-broker.service
		fi

    echo -n -e  "$LA Would you like to use TRIM (Only for SSD)? [Y/n]: "
    read -r UC

    if [[ $UC == 'Y' || $UC == 'y' || $UC == '' ]]; then
			sudo systemctl enable fstrim.timer
			sudo fstrim -v /
    fi
	fi

  return 0;
}


function parallel_download {
	local UC
	echo -n -e "$LA Do you want to change the restrictions from parallel pacman downloads? [Y/n]: "
	read -r UC

	if [[ $UC == 'Y' || $UC == 'y' || $UC == '' ]]; then
    echo -n -e "Maximum number of parallel downloads $NA "
    read -r UC

    #get the line number of 'ParallelDownloads' string in file
    local line_number
    line_number=$(sudo grep -n 'ParallelDownloads' /etc/pacman.conf | cut -d: -f1)

    #backup and override string in file
    if [[ -f "$PACMAN_FILE" ]]; then
      echo "${BYELLOW}:${COLOR_OFF} The file has already been backed up, a new backup has been cancelled."
    else
      sudo cp /etc/pacman.conf backup/pacman.conf
    fi

    sudo sed -i "${line_number}s/.*/ParallelDownloads = $UC/" /etc/pacman.conf

    write_out
	fi	

  return 0;
}


function cpu_powermode {
  local UC
  
  echo -n -e "$LA Do you want to put the processor into performance mode? [Y/n]: "
  read -r UC

  if [[ $UC == 'Y' || $UC == 'y' || $UC == '' ]]; then
    sudo pacman -S cpupower
    sudo cpupower frequency-set -g performance

    sudo sed -i "3s/.*/governor='performance'/" /etc/default/cpupower 
  fi

  return 0;
}

#
# ----- | Revert changes functions | -----
#

function restore_cfgs {
  sudo cp backup/mkinitcpio.conf /etc/mkinitcpio.conf
  sudo cp backup/pacman.conf /etc/pacman.conf
}
