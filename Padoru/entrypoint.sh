#!/bin/bash
set -e

echo "Starting Drupal installation and setup..."

# Wait for database to be ready
echo "Waiting for MariaDB to be ready..."
for i in {1..60}; do
  if nc -z ${DRUPAL_DB_HOST} ${DRUPAL_DB_PORT} 2>/dev/null; then
    echo "✓ Database is ready!"
    break
  fi
  echo "Attempt $i/60: Waiting for database..."
  sleep 2
done

DRUPAL_ROOT_DIR="${DRUPAL_ROOT:-/opt/drupal}"
DRUPAL_WEB_ROOT="${DRUPAL_ROOT_DIR}/web"

# Ensure files directory exists with correct permissions
mkdir -p "${DRUPAL_WEB_ROOT}/sites/default/files/css"
mkdir -p "${DRUPAL_WEB_ROOT}/sites/default/files/php"
chown -R www-data:www-data "$DRUPAL_ROOT_DIR"
chmod -R 755 "$DRUPAL_ROOT_DIR"
chmod 777 "${DRUPAL_WEB_ROOT}/sites/default/files"

# Create settings.php if it doesn't exist
if [ ! -f "${DRUPAL_WEB_ROOT}/sites/default/settings.php" ]; then
  echo "Creating settings.php..."
  cp "${DRUPAL_WEB_ROOT}/sites/default/default.settings.php" "${DRUPAL_WEB_ROOT}/sites/default/settings.php"
  chmod 666 "${DRUPAL_WEB_ROOT}/sites/default/settings.php"
fi

# Configure database in settings.php
if ! grep -q "databases\['default'\]" "${DRUPAL_WEB_ROOT}/sites/default/settings.php"; then
  echo "Configuring database connection..."
  
  cat >> "${DRUPAL_WEB_ROOT}/sites/default/settings.php" << 'DBEOF'

$databases['default']['default'] = array(
  'driver' => 'mysql',
  'database' => getenv('DRUPAL_DB_NAME'),
  'username' => getenv('DRUPAL_DB_USER'),
  'password' => getenv('DRUPAL_DB_PASSWORD'),
  'host' => getenv('DRUPAL_DB_HOST'),
  'port' => getenv('DRUPAL_DB_PORT'),
  'prefix' => '',
);

$settings['hash_salt'] = 'drupal_hash_salt_' . md5(uniqid());
$settings['update_free_access'] = FALSE;
DBEOF
fi

chmod 644 "${DRUPAL_WEB_ROOT}/sites/default/settings.php"

# Generate random admin credentials
ADMIN_USER="anzuukino_$(openssl rand -hex 4)"
ADMIN_PASS=$(openssl rand -base64 24)
ADMIN_EMAIL="admin@anzuukino.local"

# Check if Drupal is already installed (look for users_field_data table)
if ! mysql -h${DRUPAL_DB_HOST} -u${DRUPAL_DB_USER} -p${DRUPAL_DB_PASSWORD} ${DRUPAL_DB_NAME} \
    -Nse "SELECT 1 FROM information_schema.tables WHERE table_schema='${DRUPAL_DB_NAME}' AND table_name='users_field_data';" 2>/dev/null; then
  echo "Installing Drupal..."

  cd "$DRUPAL_ROOT_DIR"

  DRUSH_BIN="$(command -v drush || true)"
  if [ -n "$DRUSH_BIN" ]; then
    echo "Running installation via Drush..."
    "$DRUSH_BIN" --root="$DRUPAL_WEB_ROOT" site:install standard \
      --db-url="mysql://${DRUPAL_DB_USER}:${DRUPAL_DB_PASSWORD}@${DRUPAL_DB_HOST}:${DRUPAL_DB_PORT}/${DRUPAL_DB_NAME}" \
      --site-name="Infobahn CTF" \
      --account-name="$ADMIN_USER" \
      --account-pass="$ADMIN_PASS" \
      --account-mail="$ADMIN_EMAIL" \
      --yes
    "$DRUSH_BIN" --root="$DRUPAL_WEB_ROOT" config:set system.site mail "$ADMIN_EMAIL" --yes --input-format=string 2>&1 || true
  else
    echo "✗ Drush CLI not found in PATH. Automated installation cannot continue."
    exit 1
  fi
  
  # Set permissions after installation
  chown -R www-data:www-data "$DRUPAL_ROOT_DIR"
  chmod -R 755 "$DRUPAL_ROOT_DIR"
  mkdir -p "${DRUPAL_WEB_ROOT}/sites/default/files/css"
  mkdir -p "${DRUPAL_WEB_ROOT}/sites/default/files/php"
  chmod 777 "${DRUPAL_WEB_ROOT}/sites/default/files"
  
  echo ""
  echo "========================================" 
  echo "DRUPAL INSTALLATION COMPLETE"
  echo "========================================" 
  echo "Username: $ADMIN_USER"
  echo "Password: $ADMIN_PASS"
  echo "Email: $ADMIN_EMAIL"
  echo "========================================" 
  echo ""
else
  echo "✓ Drupal is already installed"
fi

# Start services (PHP-FPM first, then Nginx in the foreground)
echo "Starting PHP-FPM..."
php-fpm --daemonize

echo "Starting Nginx..."
exec "$@"
