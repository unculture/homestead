#!/usr/bin/env bash

block="server {
    listen 80;
    server_name $1;
    root "$2";

    index index.html index.htm index.php;

    charset utf-8;

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    access_log off;
    error_log  /var/log/nginx/$1-error.log error;

    error_page 404 /index.php;

    sendfile off;

    location / {
	    try_files \$uri /framework/main.php?url=\$uri&\$query_string;
    }

    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/var/run/php5-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_intercept_errors on;
        fastcgi_buffer_size 16k;
        fastcgi_buffers 4 16k;
    }

    location ~ /\.ht {
        deny all;
    }

    location ^~ /assets/ {
	    sendfile on;
	    try_files \$uri =404;
    }

    location ~ /(mysite|framework|cms)/.*\.(php|php3|php4|php5|phtml|inc)$ {
	    deny all;
    }

    location ~ /\.. {
	    deny all;
    }

    location ~ \.ss$ {
	    satisfy any;
	    allow 127.0.0.1;
	    deny all;
    }

    location ~ web\.config$ {
	    deny all;
    }

    location ~ \.ya?ml$ {
	    deny all;
    }

    location ^~ /vendor/ {
	    deny all;
    }

    location ~* /silverstripe-cache/ {
	    deny all;
    }

    location ~* composer\.(json|lock)$ {
	    deny all;
    }

    location ~* /(cms|framework)/silverstripe_version$ {
	    deny all;
    }
}
"

echo "$block" > "/etc/nginx/sites-available/$1"
ln -fs "/etc/nginx/sites-available/$1" "/etc/nginx/sites-enabled/$1"
service nginx restart
service php5-fpm restart
