#!/bin/bash

# ==============================================================================
# Script Name: csf-installer.sh
# Description: A script for installing CSF and its required packages.
# Author: Mohammad Parhoun <mohammad.parhoun.7@gmail.com>
# Version: 1.0
#
# Copyright (c) 2025 Mohammad Parhoun. All Rights Reserved.
# This script is licensed under the MIT License.
#
# Changelog:
# v1.0 - 2025-03-27: Initial release.
# ==============================================================================


VERBOSE=0
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
RESET="\e[0m"

if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}This script must be run as root.${RESET}"
    exit 1
fi

check_install() {
package=$1
if ! command -v $package &> /dev/null; then
    missing_packages+=("$package")
    [[ $VERBOSE -eq 1 ]] && echo -e "${RED}$package is missing.${RESET}"
fi
}

while getopts "v" opt; do
    case $opt in
        v)
            VERBOSE=1
            ;;
        *)
            echo "Available Options: $0 [-v]"
            exit 1
            ;;
    esac
done

run_command() {
    local command=$1
    if [[ $VERBOSE -eq 1 ]]; then
        eval $command
    else
        eval "$command &> /dev/null"
    fi
}

required_packages=(wget tar perl iptables ipset)
missing_packages=()

for var in ${required_packages[@]}; do
    check_install $var
done

if [[ ${#missing_packages[@]} > 0 ]]; then
    echo -e "The following packages are missing and will be installed: ${RED}${missing_packages[@]}${RESET}"

    if [[ -f /etc/redhat-release ]]; then
        echo "Packages are being installed.."
        rpm --import https://repo.almalinux.org/almalinux/RPM-GPG-KEY-AlmaLinux
        run_command "dnf install -y `echo ${missing_packages[@]}`" # Convert array to string because DNF and APT cannot install multiple packages from an array simultaneously.
        if [[ $? == 0 ]]; then
            echo -e "${GREEN}All required packages have been installed successfully.${RESET}"
        else
            echo -e "${RED}Something went wrong while installing packages..${RESET}"
            exit 1
        fi

    elif [[ -f /etc/debian_version ]]; then
        echo "Packages are being installed.."
        run_command "apt install -y `echo ${missing_packages[@]}`"
        if [[ $? == 0 ]]; then
            echo -e "${GREEN}All required packages have been installed successfully.${RESET}"
        else
            echo -e "${RED}Something went wrong while installing packages..${RESET}"
            exit 1
        fi
    else
        echo -e "${RED}Unknown distro${RESET}"
    fi
else
    echo -e "${YELLOW}All required packages are already installed.${RESET}"
fi


echo "Getting ready to install CSF.."
sleep 5


cd /usr/src && rm -fv csf.tgz
wget -q https://download.configserver.com/csf.tgz
run_command "tar -xzf csf.tgz"
cd csf
run_command "sh install.sh"

if [[ $? == 0 ]]; then
    echo -e "${GREEN}CSF installation completed successfully!${RESET}"

    sed -i 's/TESTING = "1"/TESTING = "0"/g' /etc/csf/csf.conf
    sed -i 's/ICMP_IN_RATE = "1\/s"/ICMP_IN_RATE = "0"/g' /etc/csf/csf.conf
    run_command "csf -r" && run_command "systemctl restart lfd"

    echo -e "${GREEN}CSF is now active and configured.${RESET}"
else
    echo -e "${RED}CSF installation failed!${RESET}"
fi

