#!/bin/sh

# Install vim
sudo yum -y install vim-enhanced
echo "set bg=dark" > ~/.vimrc
echo "set tabstop=4" >> ~/.vimrc
echo "set expandtab" >> ~/.vimrc

# Install instack undercloud pieces
sudo yum install -y http://rdo.fedorapeople.org/openstack-juno/rdo-release-juno.rpm
sudo yum -y install instack-undercloud

# Download images if you're not scping the from the host
#wget -r -nd -np --reject "index.html*" https://repos.fedorapeople.org/repos/openstack-m/tripleo-images-rdo-juno/ 

# Prepare answerfile
cp /usr/share/instack-undercloud/instack.answers.sample ~/instack.answers

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

# Jenkins seems to need starting..
sudo systemctl start jenkins
sudo systemctl status jenkins

# Install the jenkins job builder jobs
cd ~/git/
git clone https://github.com/hardys/jjb-openstack.git
cd jjb-openstack/
sudo cp jenkins_jobs.ini /etc/jenkins_jobs/
for j in jobs/*
do
  echo "Adding jenkins job $j"
  # FIXME: not sure sudo is really needed here..
  sudo jenkins-jobs update jobs/$j
done
