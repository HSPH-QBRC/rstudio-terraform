#!/usr/bin/env bash

# Based on http://cran.rstudio.com/bin/linux/ubuntu/

# print commands and their expanded arguments
set -x

DOMAIN=${domain}
ADMIN_EMAIL=${admin_email}

apt-get update

# install two helper packages we need
apt install -y --no-install-recommends software-properties-common dirmngr git nginx

# add the signing key (by Michael Rutter) for these repos
# To verify key, run gpg --show-keys /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc 
# Fingerprint: 298A3A825C0D65DFD57CBB651716619E084DAB9
wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | sudo tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc

# add the R 4.0 repo from CRAN 
add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/"

# Finally, install R
apt-get install -y --no-install-recommends r-base

# Install rstudio
apt-get install gdebi-core
wget https://download2.rstudio.org/server/bionic/amd64/rstudio-server-2022.02.2-485-amd64.deb
gdebi -n rstudio-server-2022.02.2-485-amd64.deb

# install certbot so we can roll a SSL cert:
snap install core
snap refresh core
snap install --classic certbot
ln -s /snap/bin/certbot /usr/bin/certbot
# stop nginx, otherwise it's using port 80
service nginx stop

# now run certbot
certbot certonly -n --agree-tos --email $ADMIN_EMAIL --standalone --domains $DOMAIN

# The location of the files created by certbot:
SSL_CERT=/etc/letsencrypt/live/$DOMAIN/fullchain.pem
SSL_CERT_KEY=/etc/letsencrypt/live/$DOMAIN/privkey.pem

# Removing the existing default conf and create an nginx conf file
rm /etc/nginx/sites-enabled/default
cat > /etc/nginx/sites-enabled/rstudio.conf <<EOF

map \$http_upgrade \$connection_upgrade {
  default upgrade;
  ''        close;
}

server {
  listen 80 default_server;
  listen [::]:80 default_server;
  server_name _;
  return 301 https://\$host\$request_uri;
}

server {

  listen                    443 ssl;
  server_name               $DOMAIN;
  ssl_certificate         $SSL_CERT;
  ssl_certificate_key $SSL_CERT_KEY;

  location /rstudio/ {    
      rewrite ^/rstudio/(.*)\$ /\$1 break;
      proxy_pass http://localhost:8787;
      proxy_redirect http://localhost:8787/ \$scheme://\$host/rstudio/;
      proxy_http_version 1.1;
      proxy_set_header Upgrade \$http_upgrade;
      proxy_set_header Connection \$connection_upgrade;
      proxy_read_timeout 20d;
      proxy_set_header X-Forwarded-Host \$host;
  }
}
EOF

service nginx restart

# clone this repo so we have any helper scripts (e.g. add_users.sh) available if we SSH onto the VM
# for creation of users and other management.
cd /opt
git clone https://github.com/HSPH-QBRC/rstudio-terraform.git