#!/usr/bin/env bash

# Based on http://cran.rstudio.com/bin/linux/ubuntu/

# print commands and their expanded arguments
set -x

apt-get update

# install two helper packages we need
apt install --no-install-recommends software-properties-common dirmngr git

# add the signing key (by Michael Rutter) for these repos
# To verify key, run gpg --show-keys /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc 
# Fingerprint: 298A3A825C0D65DFD57CBB651716619E084DAB9
wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | sudo tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc

# add the R 4.0 repo from CRAN 
add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/"

# Finally, install R
apt-get install --no-install-recommends r-base

# Install rstudio
apt-get install gdebi-core
wget https://download2.rstudio.org/server/bionic/amd64/rstudio-server-2022.02.2-485-amd64.deb
gdebi rstudio-server-2022.02.2-485-amd64.deb

# clone this repo so we have any helper scripts (e.g. add_users.sh) available if we SSH onto the VM
# for creation of users and other management.
cd /opt
git clone https://github.com/HSPH-QBRC/rstudio-terraform.git