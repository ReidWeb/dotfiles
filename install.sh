#!/usr/bin/env bash

# Install dependencies
apt-get install nano sudo curl git zsh

# Add reid user
adduser --disabled-password --gecos "Peter Reid,,," reid
# Add to sudoers
usermod -aG sudo {user}
# Sudo as reid
sudo su reid
cd ~
# Setup ssh keys
mkdir .ssh
nano authorized_keys
curl https://launchpad.net/~peter-reid/+sshkeys > .ssh/authorized_keys

# Disable Root login
sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
systemctl restart sshd

# Disable passwordless login
sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
sed -i 's/UsePAM yes/UsePAM no/g' /etc/ssh/sshd_config
systemctl restart sshd

# Change SSH port
sed -i 's/Port 22/Port 222/g' /etc/ssh/sshd_config
#Restart SSH
systemctl restart sshd

# Install Oh-My-Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
# Set as reid user default shell
sed -i 's|/home/reid:/bin/bash|/home/reid:/usr/bin/zsh|g' /etc/passwd
# Setup zsh profile
curl https://raw.githubusercontent.com/ReidWeb/dotfiles/master/.zshrc > /home/reid/.zshrc

# Install MOTD script
cd /tmp
git clone https://github.com/ReidWeb/linuxmotd.git
cd linuxmotd

#### MOTD INSTALL SCRIPT
nstalldir="/etc/dynmotd"
mkdir $installdir
cp dynmotd.sh $installdir/dynmotd.sh
chmod 755 $installdir/dynmotd.sh
touch $installdir/dynmotdart
chmod 755 $installdir/dynmotdart
echo "MOTD ART MISSING: Please place some ASCII MOTD art in /etc/dynmotd/dynmotdart" >> $installdir/dynmotdart
cp update-checker.sh $installdir/update-checker.sh
chmod 755 $installdir/update-checker.sh
touch $installdir/updates-available
chmod 755 $installdir/updates-available
echo "--" >> $installdir/updates-available
$installdir/update-checker.sh
echo -e "\033[0;33mScript setup complete, please refer to https://github.com/ReidWeb/linuxmotd/blob/master/README.md for instructions on how to complete the installation process \033[1;37m"
####

# Ensure reid is added to sudoers (read by motd script)
sed -i 's/sudo:x:27:/sudo:x:27:reid/g' /etc/group

# Disable last log motd
sed -i 's/PrintLastLog yes/PrintLastLog no/g' /etc/ssh/sshd_config  
# Disable default motd
sed -i 's/PrintMotd yes/PrintMotd no/g' /etc/ssh/sshd_config  
# Apply
systemctl restart sshd

# Add motd to profile
echo "/etc/dynmotd/dynmotd.sh" >> /etc/profile

# Setup cron script to check for updates
line="0 * * * * /etc/dynmotd/update-checker.sh"
(crontab -u userhere -l; echo "$line" ) | crontab -u root -

# Set system to UTC
sudo timedatectl set-timezone Etc/UTC

# Add docker deb dependencies
sudo apt-get install apt-transport-https ca-certificates software-properties-common
# Add docker gpg key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
# Add docker repos
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
# Update
apt-get update
# Install Docker CE
apt-get install docker-ce=17.06.2~ce-0~ubuntu
# Add reid to permitted docker users
usermod -aG docker reid
