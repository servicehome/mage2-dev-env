#!/usr/bin/env bash

COMPOSER_BIN=$(command -v composer)
PHP_BIN=$(command -v php)

DIRECTORY="mage23"
HOMESTEAD_CONFIG_FILE="Homestead.yaml"
MAGE_INIT_SCRIPT="mageInit.sh"

MAGE_VERSION="^2.3"
PHP_VERSION="7.2"
SHOP_DOMAIN_NAME="$DIRECTORY.test"

### magento variables
###
### You should modify these variables for your needs.
##########################################################
_BACKEND_FRONTNAME="shopadmin"
_ADMIN_LOGIN="adminUser"
# at least 7 characters!
_ADMIN_PWD="myPass#123"
_ADMIN_FIRSTNAME="first"
_ADMIN_LASTNAME="last"
_ADMIN_EMAIL="your@domain.tld"

function createComposerProject() {
  $COMPOSER_BIN create-project --no-install --repository=https://repo.magento.com/ magento/project-community-edition:"$MAGE_VERSION" $DIRECTORY &&
    if [ ! -d "$DIRECTORY" ]; then
      echo "Error, project folder does not exist!"
      return 2
    fi &&
    cd "$DIRECTORY" &&
    $COMPOSER_BIN config platform.php "$PHP_VERSION" &&
    $COMPOSER_BIN require --dev --no-update laravel/homestead &&
    $COMPOSER_BIN install
}

function setupHomestead() {

  # folders: type: "nfs"
  # sites: add type: "apache" and php: "7.2"
  # ../public -> ../pub
  # sites: map: homestead.test -> $SHOP_DOMAIN_NAME

  $PHP_BIN vendor/bin/homestead make &&
    [ -f "$HOMESTEAD_CONFIG_FILE" ] &&
    cp "$HOMESTEAD_CONFIG_FILE" "$HOMESTEAD_CONFIG_FILE.backup" &&
    awk '/\/home\/vagrant\/code$/ {print "        type: \"nfs\""}1' <"$HOMESTEAD_CONFIG_FILE.backup" | awk '/to: \/home\/vagrant\/code\/public/ { print "        type: apache\n        php: \"7.2\"" }1' | awk '{ gsub(/\/public$/, "/pub") }1' | awk '{ gsub(/homestead\.test/, "'$SHOP_DOMAIN_NAME'")}1' >"$HOMESTEAD_CONFIG_FILE"
}

function setupAfterScript() {
  awk '{ gsub(/!!!DOMAIN!!!/, "'$SHOP_DOMAIN_NAME'"); gsub(/!!!_BACKEND_FRONTNAME!!!/, "'$_BACKEND_FRONTNAME'"); gsub(/!!!_ADMIN_LOGIN!!!/, "'$_ADMIN_LOGIN'"); gsub(/!!!_ADMIN_PWD!!!/, "'$_ADMIN_PWD'"); ; gsub(/!!!_ADMIN_FIRSTNAME!!!/, "'$_ADMIN_FIRSTNAME'"); ; gsub(/!!!_ADMIN_LASTNAME!!!/, "'$_ADMIN_LASTNAME'");  gsub(/!!!_ADMIN_EMAIL!!!/, "'$_ADMIN_EMAIL'"); gsub(/!!!PHP_CLI_VERSION!!!/, "'$PHP_VERSION'") }1' <"../$MAGE_INIT_SCRIPT" >"$MAGE_INIT_SCRIPT" &&
    chmod +x "$MAGE_INIT_SCRIPT" &&
    echo "./code/$MAGE_INIT_SCRIPT" >>after.sh
}

if [ ! -e "$DIRECTORY" ]; then
  createComposerProject &&
    setupHomestead &&
    setupAfterScript

else
  echo "The project seems to be initialized allready!"
  exit 1

fi
