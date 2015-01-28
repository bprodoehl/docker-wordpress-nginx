#!/bin/bash

# Download nginx helper plugin
if [ ! -d /app/wp-content/plugins/nginx-helper ]; then
    curl -O `curl -i -s https://wordpress.org/plugins/nginx-helper/ | egrep -o "https://downloads.wordpress.org/plugin/[^']+"`
    unzip -o nginx-helper.*.zip -d /app/wp-content/plugins
    chown -R www-data:www-data /app/wp-content/plugins/nginx-helper
fi

# Activate nginx plugin and set up pretty permalink structure once logged in
if [ `cat /app/wp-config.php | grep nginx\-helper\/nginx\-helper\.php | wc -l` -eq 0 ]; then
    echo "Enabling nginx-helper plugin..."
    cat << ENDL >> /app/wp-config.php
    \$plugins = get_option( 'active_plugins' );
    if ( count( \$plugins ) === 0 ) {
        require_once(ABSPATH .'/wp-admin/includes/plugin.php');
        \$wp_rewrite->set_permalink_structure( '/%postname%/' );
        \$pluginsToActivate = array( 'nginx-helper/nginx-helper.php' );
        foreach ( \$pluginsToActivate as \$plugin ) {
            if ( !in_array( \$plugin, \$plugins ) ) {
                activate_plugin( '/app/wp-content/plugins/' . \$plugin );
            }
        }
    }
ENDL
fi
