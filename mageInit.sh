#!/bin/sh

BASE_DIR="/home/vagrant/code"
DOMAIN="!!!DOMAIN!!!"

_BASE_URL="https://$DOMAIN"
_BACKEND_FRONTNAME="!!!_BACKEND_FRONTNAME!!!"

_ADMIN_LOGIN="!!!_ADMIN_LOGIN!!!"
_ADMIN_PWD="!!!_ADMIN_PWD!!!"
_ADMIN_FIRSTNAME="!!!_ADMIN_FIRSTNAME!!!"
_ADMIN_LASTNAME="!!!_ADMIN_LASTNAME!!!"
_ADMIN_EMAIL="!!!_ADMIN_EMAIL!!!"

# switch to php 7.x cli
PHP_CLI_VERSION="!!!PHP_CLI_VERSION!!!"

sudo update-alternatives --set php /usr/bin/php$PHP_CLI_VERSION
sudo update-alternatives --set php-config /usr/bin/php-config$PHP_CLI_VERSION
sudo update-alternatives --set phpize /usr/bin/phpize$PHP_CLI_VERSION

#_DRY_RUN=false
#--dry-run=$_DRY_RUN \

# setup magento
setupMagento() {

  if [ ! -f "$BASE_DIR/app/etc/env.php" ]; then

    cd /home/vagrant/code/bin && ./magento setup:install \
      --backend-frontname="$_BACKEND_FRONTNAME" \
      --base-url="$_BASE_URL" \
      --db-host=127.0.0.1 \
      --db-name=homestead \
      --db-user=homestead \
      --db-password=secret \
      --admin-firstname="$_ADMIN_FIRSTNAME" \
      --admin-lastname="$_ADMIN_LASTNAME" \
      --admin-email="$_ADMIN_EMAIL" \
      --admin-user="$_ADMIN_LOGIN" \
      --admin-password="$_ADMIN_PWD" \
      --language=de_DE \
      --currency=EUR \
      --timezone=Europe/Berlin \
      --use-rewrites=1 \
      --cache-backend=redis \
      --cache-backend-redis-server=127.0.0.1 \
      --cache-backend-redis-db=0 &&
      ./magento deploy:mode:set developer
  else
    echo "app/etc/env.php allready existing? Maybe its allready installed?"
  fi
}

# configure vhost with http2
enableHttp2() {
  sudo a2enmod http2

  VHOST_SSL_CONFIG="/etc/apache2/sites-available/$DOMAIN-ssl.conf"
  ADD_TO_VHOST="Protocols h2 h2c http/1.1"

  sudo sed -i '/DocumentRoot/a\
'"\t$ADD_TO_VHOST" "$VHOST_SSL_CONFIG"
  sudo systemctl restart apache2
}

### Opcache Setup for magento
changeOpcacheSettingsForFpm() {
  FPM_PHP_INI_FILE="/etc/php/$PHP_CLI_VERSION/fpm/php.ini"

  OP_MEMORY_CONSUMPTION=512
  INTERNED_STRINGS_BUFFER=12
  MAX_ACCELERATED_FILES=65406

  VALIDATE_TIMESTAMPS=1  # If enabled, OPcache will check for updated scripts every opcache.revalidate_freq seconds. When this directive is disabled, you must reset OPcache manually via opcache_reset(), opcache_invalidate() or by restarting the Web server for changes to the filesystem to take effect.
  REVALIDATE_FREQ=30     # How often to check script timestamps for updates, in seconds. 0 will result in OPcache checking for updates on every request. This configuration directive is ignored if opcache.validate_timestamps is disabled.

  ENABLE_FILE_OVERRIDE=1 # When enabled, the opcode cache will be checked for whether a file has already been cached when file_exists(), is_file() and is_readable() are called. This may increase performance in applications that check the existence and readability of PHP scripts, but risks returning stale data if opcache.validate_timestamps is disabled.

  sudo sed -i '/\[opcache\]/a\
opcache.memory_consumption='"$OP_MEMORY_CONSUMPTION\n"'opcache.interned_strings_buffer='"$INTERNED_STRINGS_BUFFER\n"'opcache.max_accelerated_files='"$MAX_ACCELERATED_FILES\n"'opcache.validate_timestamps='"$VALIDATE_TIMESTAMPS\n"'opcache.enable_file_override='"$ENABLE_FILE_OVERRIDE\n"'opcache.revalidate_freq='"$REVALIDATE_FREQ\n" "$FPM_PHP_INI_FILE"
}

setupMagento
enableHttp2
changeOpcacheSettingsForFpm
