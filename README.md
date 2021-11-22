# Install Certbot by Let's Encrypt

This installer should work on any Debian based OS. This also includes Ubuntu. This will install Certbot using Snap Store. It will remove Certbot installed by APT if it's installed.

**Install CURL first**
```
apt-get install curl -y
```

### Run the installer with the following command
```
bash <( curl -sSL https://raw.githubusercontent.com/unixxio/install-certbot/main/install-certbot.sh )
```

**Requirements**
* Execute as root
* NGINX must be installed

**What does it do**
* Install the latest Certbot version from Snap Store
* Register your e-mail address at letsencrypt
* Automatically reload NGINX when a certificate is renewed

**Certbot Commands**

Show all certificates
```
certbot certificates
```
Request a certificate
```
certbot certonly -d example.com,www.example.com
```
Expand existing certificate
```
certbot certonly --expand -d example.com,www.example.com,sub1.example.com
```
Force renew a certificate
```
certbot certonly --force-renewal -d example.com
```
Delete a certificate
```
certbot delete --cert-name example.com
```

Use `certbot --help` for more options.

**Tested on**
* Debian 10 Buster
* Debian 11 Bullseye

## Support
Feel free to [buy me a beer](https://paypal.me/sonnymeijer)! ;-)

## DISCLAIMER
Use at your own risk and always make sure you have backups!
