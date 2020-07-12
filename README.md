# mage2-dev-env
Simple environment for development around Magento2 on **macos**.

Setup a running Magento 2 Project with a view clicks and the power of virtualisation and orchestration.
 
## Requirements

1. VirtualBox (https://www.virtualbox.org)
2. Vagrant (https://www.vagrantup.com)
3. PHP >= 7.2.x
4. Composer installed (https://getcomposer.org)
 
You can install all of them with homebrew (https://brew.sh/index_de).

        brew install virtualbox vagrant php composer

Install homestead vagrant box:

(I had some problems with the newest version, so i use the older one at version >= 9.5, < 10)

        vagrant box add --box-version '~> 9.5' laravel/homestead

## Install
 
1. clone this repository
 
2. start the initialisation script


    initProject.sh

## Modifiy Homestead.yaml

The script modifies the Homestead.yaml file:

1. Set file sync provider to "NFS"
2. Set Webserver to "Aapche"
3. Set PHP Version to 7.2
4. Changes the sites path to ".../pub" (original is ../public)

Maybe you should change the ip address in the first line.

Then setup your /etc/hosts

        192.168.10.10  mage23.test 

The original file is "Homestead.yaml.backup".

## Start Magento 

        cd ./mage23 

        vagrant up

After startup of the virtual machine you can visit the shop at https://mage23.test

