#!/bin/sh

# Install vim
sudo yum -y install vim-enhanced
echo "set bg=dark" > ~/.vimrc
echo "set tabstop=4" >> ~/.vimrc
echo "set expandtab" >> ~/.vimrc

# Clone my fork of the t-i-e additions from derekh
mkdir -p ~/git; cd ~/git
git clone https://github.com/hardys/tripleo-image-elements
cd tripleo-image-elements/
git fetch -a origin
git checkout -b spinal_stack origin/spinal_stack

# Copy the install-server element under the instack-undercloud element repo
sudo cp -r elements/install-server /usr/share/instack-undercloud/

# Switch back to homedir and modify undercloud json to include install-server
cd; cp /usr/share/instack-undercloud/json-files/fedora-20-undercloud-packages.json fedora-20-undercloud-packages-spinal.json
sed -i 's/"os-cloud-config"/"os-cloud-config", "install-server"/' fedora-20-undercloud-packages-spinal.json

export JSONFILE=$PWD/fedora-20-undercloud-packages-spinal.json
instack-install-undercloud
