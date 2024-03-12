#!/bin/bash

# optional components installation
my_icewm_config=yes # set no if just want an empty icewm setup
icewm_themes=yes # set no if do not want to install extra icewm themes
audio=yes # set no if do not want to use pipewire audio server
extra_pkg=no # set no if do not want to install the extra packages
nm=yes # set no if do not want to use network-manager for network interface management
nano_config=no # set no if do not want to configure nano text editor

install () {
	# install swaywm and other packages
	sudo apt-get update && sudo apt-get upgrade -y
	sudo apt-get install icewm xorg xinit qt5ct lxappearance papirus-icon-theme \
		xdg-utils xdg-user-dirs policykit-1 libnotify-bin dunst nano less \
		software-properties-gtk policykit-1-gnome dex -y

	# copy my icewm configuration
	if [[ $my_icewm_config == "yes" ]]; then
		if [[ -d $HOME/.icewm ]]; then mv $HOME/.icewm $HOME/.icewm_`date +%Y_%d_%m_%H_%M_%S`; fi
		#mkdir -p $HOME/{Documents,Downloads,Music,Pictures,Videos}
		mkdir -p $HOME/.icewm
		cp -r ./icewm/* $HOME/.icewm/
		chmod +x $HOME/.icewm/startup
	fi

 	# install extra IceWM themes
  	if [[ $icewm_themes == "yes" ]]; then
		mkdir -p $HOME/.icewm/themes
  
  		git clone https://github.com/Brottweiler/win95-dark.git /tmp/win95-dark
    		cp -r /tmp/win95-dark $HOME/.icewm/themes && rm $HOME/.icewm/themes/win95-dark/.gitignore
      
      		git clone https://github.com/Vimux/icewm-theme-icepick.git /tmp/icewm-theme-icepick
		cp -r /tmp/icewm-theme-icepick/IcePick $HOME/.icewm/themes

  		git clone https://github.com/Brottweiler/Arc-Dark.git /tmp/Arc-Dark
    		cp -r /tmp/Arc-Dark $HOME/.icewm/themes
   	fi

	# configure nano with line number
	if [[ $nano_config == "yes" ]]; then
		if [[ -f $HOME/.nanorc ]]; then mv $HOME/.nanorc $HOME/.nanorc_`date +%Y_%d_%m_%H_%M_%S`; fi
		cp /etc/nanorc $HOME/.nanorc
		sed -i 's/# set const/set const/g' $HOME/.nanorc
	fi

	# use pipewire with wireplumber or pulseaudio-utils
	if [[ $audio == "yes" ]]; then
		# install pulseaudio-utils to audio management for Ubuntu 22.04 due to out-dated wireplumber packages
		if [[ ! $(cat /etc/os-release | awk 'NR==3' | cut -c12- | sed s/\"//g) == "22.04" ]]; then
			sudo apt-get install pipewire pipewire-pulse wireplumber pavucontrol pnmixer -y
		else
			sudo apt-get install pipewire pipewire-media-session pulseaudio pulseaudio-utils pavucontrol pnmixer -y
		fi
	fi

	# optional to insstall the extra packages
	if [[ $extra_pkg == "yes" ]]; then
		sudo apt-get install thunar gvfs gvfs-backends thunar-archive-plugin thunar-media-tags-plugin avahi-daemon \
			lximage-qt geany sddm qpdfview -y
	fi

	# optional install NetworkManager
	if [[ $nm == yes ]]; then
	sudo apt-get install network-manager network-manager-gnome -y
		if [[ -n "$(uname -a | grep Ubuntu)" ]]; then
			for file in `find /etc/netplan/* -maxdepth 0 -type f -name *.yaml`; do
				sudo mv $file $file.bak
			done
			echo -e "# Let NetworkManager manage all devices on this system\nnetwork:\n  version: 2\n  renderer: NetworkManager" | \
				sudo tee /etc/netplan/01-network-manager-all.yaml
			sudo systemctl disable systemd-networkd-wait-online.service
		else
			sudo cp /etc/NetworkManager/NetworkManager.conf /etc/NetworkManager/NetworkManager.conf.bak
			sudo sed -i 's/managed=false/managed=true/g' /etc/NetworkManager/NetworkManager.conf
			sudo mv /etc/network/interfaces /etc/network/interfaces.bak
			sudo cp ./config/interfaces /etc/network/interfaces
			sudo systemctl disable networking.service
		fi
	fi

}

printf "\n"
printf "Start installation!!!!!!!!!!!\n"
printf "88888888888888888888888888888\n"
printf "My Custom IceWM Config  : $my_icewm_config\n"
printf "Extra IceWM themes      : $icewm_themes\n"
printf "Pipewire Audio          : $audio\n"
printf "Extra Packages          : $extra_pkg\n"
printf "NetworkManager          : $nm\n"
printf "Nano's configuration    : $nano_config\n"
printf "88888888888888888888888888888\n"

while true; do
read -p "Do you want to proceed with above settings? (y/n) " yn
	case $yn in
		[yY] ) echo ok, we will proceed; install; echo "Remember to reboot system after the installation!";
			break;;
		[nN] ) echo exiting...;
			exit;;
		* ) echo invalid response;;
	esac
done
