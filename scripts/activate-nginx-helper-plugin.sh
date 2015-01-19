#!/bin/bash

# Download nginx helper plugin
#curl -O `curl -i -s https://wordpress.org/plugins/nginx-helper/ | egrep -o "https://downloads.wordpress.org/plugin/[^']+"`
#unzip -o nginx-helper.*.zip -d /usr/share/nginx/www/wp-content/plugins
#chown -R www-data:www-data /usr/share/nginx/www/wp-content/plugins/nginx-helper

# Activate nginx plugin and set up pretty permalink structure once logged in
cat << ENDL >> /usr/share/nginx/www/wp-config.php
\$plugins = get_option( 'active_plugins' );
if ( count( \$plugins ) === 0 ) {
    require_once(ABSPATH .'/wp-admin/includes/plugin.php');
    \$wp_rewrite->set_permalink_structure( '/%postname%/' );
    \$pluginsToActivate = array( 'nginx-helper/nginx-helper.php' );
    foreach ( \$pluginsToActivate as \$plugin ) {
        if ( !in_array( \$plugin, \$plugins ) ) {
            activate_plugin( '/usr/share/nginx/www/wp-content/plugins/' . \$plugin );
        }
    }
}
ENDL
