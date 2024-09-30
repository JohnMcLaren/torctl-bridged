#!/bin/bash

tor_profile_name="system_tor"
tor_profile_abstract="/etc/apparmor.d/abstractions/tor"
tor_profile="/etc/apparmor.d/$tor_profile_name"
tor_profile_local="/etc/apparmor.d/local/$tor_profile_name"
webtunnel_file="/usr/bin/webtunnel-client"
# New Tor perms for 'webtunnel-client'
# Pix - discrete profile execute with inherit fallback -- scrub the environment
tor_new_grants="$webtunnel_file Pix,"

### Check instalation ###

[[ $(dpkg -L $DPKG_MAINTSCRIPT_PACKAGE | grep "^$webtunnel_file") ]] || exit 0 # 'webtunnel-client' was not installed by this package

### Check AppArmor status ###

aa_status=$(aa-status --verbose 2> /dev/null)
aa_error=$?

if [[ $aa_error > 0 ]]; then
	if [[ $aa_error == 4 ]]; then
		echo -e "AppArmor: You do not have enough privilege to read the profile set."
	elif [[ $aa_error == 127 ]]; then
		echo -e "AppArmor not installed, "
		echo -e "no further action is required."
	else
		echo -e "AppArmor: error $aa_error"
	fi
	exit 0
fi

### Check Tor grants ###

if [[ ! $(grep "$webtunnel_file" $tor_profile_abstract $tor_profile $tor_profile_local) ]]; then
	echo -e "\e[93m[[ Confirming Tor permissions ]]\e[39m"
	echo -e "AppArmor installed and Tor don't have permissions for 'webtunnel-client'."
	read -p $'\e[1mDo you agree to grant Tor permission to run '"$webtunnel_file"', installed by this package? [Y/n]: ' yn
	
	while true; do
		case $yn in
		[Yy]*) 
			echo -e "\e[92m[ ALLOWED ]\e[39m Changing Tor permissions .."
			## uncomment ‘include’ for local profile
			sed -i "/$(echo "include <local/system_tor>"  | sed 's:/:\\/:g')/ s/^[[:space:]#]\+//" $tor_profile
			## add new perms to local profile
			awk -v var="$tor_new_grants" \
				'($0 ~ var){ found=1; exit; } END{ if(!found){print var >> ARGV[1]} }' \
				$tor_profile_local
			## reload main profile
			echo -e "Reload AppArmor profile for Tor"
			apparmor_parser -r $tor_profile
			break
			;;
		[Nn]*) 
			echo -e "\e[91m[ DENIED ]\e[39m Tor permissions will not be changed."
			break
			;;
		*) read -p $'\e[21mPlease answer \e[1mYes\e[21m or \e[1mNo\e[21m: ' yn
			;;
		esac
	done
else
	echo -e "AppArmor installed and Tor have permissions for 'webtunnel-client'"
	echo -e "Nothing to do."
fi

echo -e "\e[0mExit"
