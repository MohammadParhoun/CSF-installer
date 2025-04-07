# CSF Installer Script

A Bash script for installing **ConfigServer Security & Firewall (CSF)** and its required packages on CentOS / AlmaLinux / Debian / Ubuntu systems.

## 📌 Features

- Checks for and installs missing dependencies
- Supports both RedHat-based (DNF/YUM) and Debian-based (APT) distributions
- Optional verbose mode for detailed command output
- Automatically enables and configures CSF after installation
- Turns off testing mode and limits ICMP rate as a security improvement

## 🧰 Requirements

- Root access
- Bash shell
- Internet access to download packages

## 🛠 Installation

```bash
wget https://raw.githubusercontent.com/mohammadparhoun/csf-installer/main/csf-installer.sh
chmod +x csf-installer.sh

