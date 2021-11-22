#!/bin/bash

#####################################################
#                                                   #
#  Description : Install certbot from Snap Store    #
#  Author      : Unixx.io                           #
#  E-mail      : github@unixx.io                    #
#  GitHub      : https://www.github.com/unixxio     #
#  Last Update : November 22, 2021                  #
#                                                   #
#####################################################
clear

# Variables
distro="$(lsb_release -sd | awk '{print tolower ($1)}')"
release="$(lsb_release -sc)"
version="$(lsb_release -sr)"
kernel="$(uname -r)"
uptime="$(uptime -p | cut -d " " -f2-)"
my_username="$(whoami)"
user_ip="$(who am i --ips | awk '{print $5}' | sed 's/[()]//g')"
user_hostname="$(host ${user_ip} | awk '{print $5}' | sed 's/.$//')"

# Check if script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

# Show the current logged in user
echo -e "\nHello ${my_username}, you are logged in from ${user_ip} (${user_hostname}).\n"

# Show system information
echo -e "Distribution : ${distro}"
echo -e "Release      : ${release}"
echo -e "Version      : ${version}"
echo -e "Kernel       : ${kernel}"
echo -e "Uptime       : ${uptime}"

# Ask which e-mail address to register at letsencrypt
echo -e "\nPlease enter the e-mail address you would like to use for certbot. [example: certbot@example.com]"
echo -e -n "E-mail address : "
read email

# Script feedback
echo -e "\nInstalling Certbot by Let's Encrypt. Please wait..."

# Install snapd
apt-get update > /dev/null 2>&1 && apt-get install snapd -y > /dev/null 2>&1

# Install the core snap
snap install core > /dev/null 2>&1
snap refresh core > /dev/null 2>&1

# Remove old certbot (if installed)
apt-get purge certbot *certbot -y > /dev/null 2>&1
apt-get autoremove -y > /dev/null 2>&1
apt-get clean > /dev/null 2>&1

# Install certbot
snap install --classic certbot > /dev/null 2>&1

# Create a symbolic link
ln -s /snap/bin/certbot /usr/bin/certbot

# Create folders required for deploy.sh
mkdir -p /etc/letsencrypt/renewal-hooks/deploy
mkdir -p /etc/letsencrypt/combined

# Create cli.ini
tee /etc/letsencrypt/cli.ini <<EOF > /dev/null 2>&1
email = ${email}

agree-tos = true
authenticator = webroot
deploy-hook = /etc/letsencrypt/renewal-hooks/deploy/deploy.sh
max-log-backups = 0
webroot-path = /var/www/html
EOF

# Create deploy.sh
tee /etc/letsencrypt/renewal-hooks/deploy/deploy.sh <<'EOF' > /dev/null 2>&1
#!/bin/bash

# Create the combined pem file.
COMBINED=$(basename $RENEWED_LINEAGE | tr '.' '_').pem
umask 077
cat $RENEWED_LINEAGE/privkey.pem $RENEWED_LINEAGE/fullchain.pem > /etc/letsencrypt/combined/$COMBINED

# Reload Nginx (required for renewals)
systemctl reload nginx.service

# ANSI colours.
ANSI_GREEN="\033[0;32m"
ANSI_UNSET="\033[0m"

# Print the combined PEM file.
echo -e ""
echo -e "Combined PEM file: ${ANSI_GREEN}/etc/letsencrypt/combined/${COMBINED}${ANSI_UNSET}"
EOF

# Set correct permissions on script
chmod 755 /etc/letsencrypt/renewal-hooks/deploy/deploy.sh

# Register at letsencrypt with information from cli.ini
/usr/bin/certbot --quiet --non-interactive register > /dev/null 2>&1

# Remove temporary folder created by Snap
rm -rf snap

# End script
echo -e "\nCertbot from Let's Encrypt is now successfully installed. Enjoy! ;-)\n"
exit 0

