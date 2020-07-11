#!/usr/bin/env bash

COMPOSER_BIN=$(command -v composer)
PHP_BIN=$(command -v php)

DIRECTORY="src"
HOMESTEAD_CONFIG_FILE="Homestead.yaml"

MAGE_VERSION="^2.3"
PHP_VERSION="7.2"

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
  $PHP_BIN vendor/bin/homestead make &&
    [ -f "$HOMESTEAD_CONFIG_FILE" ] &&
    cp "$HOMESTEAD_CONFIG_FILE" "$HOMESTEAD_CONFIG_FILE.backup" &&
    awk '/\/home\/vagrant\/code$/ {print "        type: \"nfs\""}1' <"$HOMESTEAD_CONFIG_FILE.backup" | awk '/to: \/home\/vagrant\/code\/public/ { print "        type: apache\n        php: \"7.2\"" }1' >"$HOMESTEAD_CONFIG_FILE"
}

if [ ! -e "$DIRECTORY" ]; then
  createComposerProject &&
    setupHomestead

else
  echo "The project seems to be initialized allready!"
  exit 1

fi
