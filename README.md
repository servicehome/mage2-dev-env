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
 
Clone this repository


    git clone https://github.com/servicehome/mage2-dev-env.git

Start the initialisation script


    initProject.sh

### Modifiy Homestead.yaml

The script modifies the Homestead.yaml file:

1. Set file sync provider to "NFS"
2. Set Webserver to "Aapche"
3. Set PHP Version to 7.2
4. Changes the sites path to ".../pub" (original is ../public)

Maybe you should change the ip address in the first line.

Then setup your /etc/hosts

        192.168.10.10  mage23.test 

The original file is "Homestead.yaml.backup".

### Modifiy initProject.sh

In this file you should almost setup the admin-url and your user-login. The Directory is also the default domain name.

    DIRECTORY="mage23"
    MAGE_VERSION="^2.3"
    
    _BACKEND_FRONTNAME="shopadmin"
    _ADMIN_LOGIN="adminUser"
    # at least 7 characters!
    _ADMIN_PWD="myPass#123"
    _ADMIN_FIRSTNAME="first"
    _ADMIN_LASTNAME="last"
    _ADMIN_EMAIL="your@domain.tld"

## Start Magento 

**All vagrant commands have to start in the "mage23" folder!** (cd mage23)

        vagrant up

After booting the virtual machine you can visit the shop at: 

Frontend: https://mage23.test

Backend: https://mage23.test/shopadmin

       User:        adminUser
       Password:    myPass#123

**You can and should change this parameters in ./initProject.sh**

## Re-Provision
After changes in the Homestead.yaml file you have to reprovision the container.

        vagrant reload --provision


## Shutdown the Container

        vagrant halt
        
and restart via 

        vagrant up


