---
title: "Nginx - Full HTTPS Proxy"
hero_image: "hero.jpg"
date: 2019-03-09T19:07:26+01:00
description: How-to configure NGINX in Full HTTPS Proxy.
categories: ["configuration"]
tags: ["nginx", "https", "ssl", "proxy", "letsencrypt", "docker", "docker-compose"]
---

## Introduction

Nowadays most of the websites are secured over HTTPS.
Tools like [Let's Encrypt](https://letsencrypt.org) make it so easy to secure your website that they are no reason to avoid it.

I have made an NGINX setup that allows you to connect any services you need very quickly.

My NGINX setup includes:

- https only configuration
- certificate generation and validation:
  - [Let's Encrypt](https://letsencrypt.org)
  - nginx config for [Let's Encrypt](https://letsencrypt.org) validation and https redirection
  - script to generate a certificate
- optimization for services behind the proxy
- easy includable file to add a new site
- realip:
  - cloudflare autoconfiguration
  - IPV4/IPV6 detection of the host

## Usage

### docker service

You can use the service with docker-compose:

*docker-compose.yml:*
```yaml
version: '2.4'

volumes:
  web.ssl
  web.www

services:
  proxy:
    image: celogeek/nginx-full-https:latest
    restart: always
    volumes:
      - web.ssl:/etc/letsencrypt
      - web.www:/var/www
      - ./sites:/etc/nginx/sites:ro
    ports:
      - "80:80"
      - "443:443"
    logging:
      options:
        max-size: "2m"
        max-file: "5"
```

### add a new certificate

To add a new certificate:
  * setup your domain (ex: static.my.domain) with your server address.
  * create your certificate using my helper.

```sh
docker-compose exec proxy /create-cert.sh "static.my.domain"
```

This will create with [Let's Encrypt](https://letsencrypt.org) your certificate and validate it with your proxy server.

## Examples

Here some example of sites configurations:

### Static:
```nginx
server {
        include conf.d/listen_https.conf;
        server_name  static.my.domain;

        ssl_certificate /etc/letsencrypt/live/static.my.domain/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/static.my.domain/privkey.pem;

        root /var/www/static;

        location / {
                try_files $uri =404;
        }
}
```

### RSPAMD
```nginx
server {
        include conf.d/listen_https.conf;
        server_name  rspamd.my.domain;

        ssl_certificate /etc/letsencrypt/live/rspamd.my.domain/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/rspamd.my.domain/privkey.pem;

        location / {
                include proxy_params;
                proxy_pass http://rspamd:11334;
        }
}
```

### RethinkDB with Auth
```nginx
server {
        include conf.d/listen_https.conf;
        server_name  rethinkdb.my.domain;

        ssl_certificate /etc/letsencrypt/live/rethinkdb.my.domain/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/rethinkdb.my.domain/privkey.pem;

        auth_basic "RethinkDB Admin";
        auth_basic_user_file htpasswd/rethinkdb;

        location / {
                include proxy_params;
                proxy_pass http://rethinkdb:8080;
        }
}
```

You also need to add to your volume:
```yaml
    volumes:
      - ./htpasswd:/etc/nginx/htpasswd:ro
```

### Nextcloud
```nginx
server {
        include conf.d/listen_https.conf;
        server_name  cloud.my.domain;

        ssl_certificate /etc/letsencrypt/live/cloud.my.domain/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/cloud.my.domain/privkey.pem;
        access_log off;

        location / {
                include proxy_params;
                proxy_pass http://nextcloud;
        }

        location = /.well-known/carddav {
                return 301 $scheme://$host/remote.php/dav;
        }

        location = /.well-known/caldav {
                return 301 $scheme://$host/remote.php/dav;
        }
}
```

### OpenOffice for Nextcloud
```nginx
server {
        include conf.d/listen_https.conf;
        server_name  cloud-office.my.domain;
        ssl_certificate /etc/letsencrypt/live/cloud-office.my.domain/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/cloud-office.my.domain/privkey.pem;
        access_log off;
        
        # static files   
        location ^~ /loleaflet {           
                proxy_pass https://nextcloud-office:9980;    
                proxy_set_header Host $http_host;
        }

        # WOPI discovery URL
        location ^~ /hosting/discovery {
                proxy_pass https://nextcloud-office:9980;
                proxy_set_header Host $http_host;
        }

        # main websocket
        location ~ ^/lool/(.*)/ws$ {
                proxy_pass https://nextcloud-office:9980;
                proxy_set_header Upgrade $http_upgrade;
                proxy_set_header Connection "Upgrade";
                proxy_set_header Host $http_host;
                proxy_read_timeout 36000s;
        }

        # download, presentation and image upload
        location ~ ^/lool {
                proxy_pass https://nextcloud-office:9980;
                proxy_set_header Host $http_host;
        }       
        
        # Admin Console websocket
        location ^~ /lool/adminws {
                proxy_pass https://nextcloud-office:9980;
                proxy_set_header Upgrade $http_upgrade;
                proxy_set_header Connection "Upgrade";
                proxy_set_header Host $http_host;
                proxy_read_timeout 36000s;
        }       
}       
```
