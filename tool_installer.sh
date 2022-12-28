#!/bin/bash
#
# tool_installer.sh - Automate the installation of Zabbix Server and Agent
# Any issues contact with Carlos Soto Pedreira (carlos.soto@trisonworld.com)

main() 
{
    clear
    loadkeys es
    echo "Starting the installation"
    installBase
    echo "Installing ZSH"
    createZSHFile
    configureZSH
    echo "Installing Zabbix"
    installZabbix
}
upgrade()
{
	sudo apt-get autoremove
	sudo apt-get update
    sudo apt-get upgrade
}
installBase()
{
    sudo apt-get install net-tools npm software-properties-common apt-transport-https wget curl kitty zsh mysql-server -y
    snap install lsd --devmode
    upgrade
}
configureZSH()
{
    sudo chsh -s /bin/zsh trison
    sudo chsh -s /bin/zsh root
}
createZSHFile()
{
    touch ~/.zshrc
    lines={
        "autoload -Uz promptinit"
        "promptinit"
        "prompt adam1"
        "setopt histignorealldups sharehistory"
        ""
        "bindkey -e"
        ""
        "HISTSIZE=1000"
        "SAVEHIST=1000"
        "HISTFILE=~/.zsh_history"
        ""
        "autoload -Uz compinit"
        "compinit"
        ""
        "alias ls='lsd --group-dirs=first'"
        "alias ll='lsd -lh --group-dirs=first'"
        "alias la='lsd -a --group-dirs=first'"
        "alias lah='lsd -lah --group-dirs=first'"
    }
    for line in "${lines[@]}"; do
        echo "$line" >> ~/.zshrc
    done
}
installZabbix()
{
    wget https://repo.zabbix.com/zabbix/6.2/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.2-4%2Bubuntu20.04_all.deb # Remember to change to arm64
    dpkg -i zabbix-release_6.2-4+ubuntu20.04_all.deb
    sudo apt-get update
    sudo apt-get install zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-agent -y
    installZabbixDB
}
installZabbixDB()
{
    mysql -u root -p
    create database zabbix character set utf8mb4 collate utf8mb4_bin;
    grant all privileges on zabbix.* to zabbix@localhost identified by 'Tr1s0nPRO';
    set global log_bin_trust_function_creators=1;
    quit
    setupZabbixDB
    configureDatabaseForZabbix
}
setupZabbixDB()
{
    zcat /usr/share/doc/zabbix-server-mysql/create.sql.gz | mysql -uzabbix -p zabbix
}
configureDatabaseForZabbix()
{
    sudo sed -i 's/# DBPassword=/DBPassword=Tr1s0nPRO/g' /etc/zabbix/zabbix_server.conf
    sudo systemctl restart zabbix-server zabbix-agent apache2
    sudo systemctl enable zabbix-server zabbix-agent apache2
}
main