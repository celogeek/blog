---
title: "Nginx - Full HTTPS Proxy"
hero_image: "hero.jpg"
date: 2019-03-09T19:07:26+01:00
description: How-to configure NGINX in Full HTTPS Proxy.
categories: ["docker"]
tags: ["nginx", "ssl", "proxy", "letsencrypt"]
---

## Introduction

Nowadays most of the websites are secured over HTTPS.
Tools like [Let's Encrypt](https://letsencrypt.org) make it so easy to secure your website that they are no reason to avoid it.

I have made an NGINX setup that allows you to connect any services you need very quickly.

## Usage

### [docker-compose.yml](https://github.com/celogeek/nginx-full-https/blob/master/docker-compose.example.yml)
```yaml
version: '2.4'

volumes:
  web.ssl
  web.www

services:
  proxy:
    image: celogeek/nginx-full-https
    restart: always
    volumes:
      - web.ssl:/etc/letsencrypt
      - web.www:/var/www
      - ./sites:/etc/nginx/sites:ro
    ports:
      - "80:80"
      - "443:443"
```

### Create a new SSL certificate

```sh
docker-compose exec proxy /create-cert.sh "blog.example.com"
```

### Connect your site

You can proxified a service with a simple configuration:
```nginx
server {
  include conf.d/listen_https.conf;
  server_name  mysite.example.com;

  ssl_certificate /etc/letsencrypt/live/mysite.example.com/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/mysite.example.com/privkey.pem;

  location / {
    include conf.d/proxy_params;
    proxy_pass http://mysite;
  }
}
```

You only need to handle the HTTPS requests because the HTTP ones are redirected to the HTTPS equivalent.

## Functionalities

### Auto redirect to HTTPS

All HTTP requests are automatically redirected to the HTTPS equivalent.

Example:

| from | to |
|------|----|
| ```http://example.com``` | ```https://example.com``` |
| ```http://example.com?my=params``` | ```https://example.com?my=params``` |
| ```http://example.com?my=params#anchor``` | ```https://example.com?my=params#anchor``` |

### [Let's Encrypt](https://letsencrypt.org)

A helper to create an SSL certificate is included in the image:

```sh
docker-compose exec proxy /create-cert.sh "blog.example.com"
```

This command creates an SSL certificate and validates it with the server.

All the certificates you generate are also automatically renewed on time.

### Real IP

A crontab is set up to detect the IP of your visitors by filtering [Cloudflare](https://cloudflare.com/) IP addresses and your docker host IP addresses automatically.

## Links

In order to use the docker image, you can find several usefull link below:

- [Github Repos](https://github.com/celogeek/nginx-full-https)
- [Docker Image](https://hub.docker.com/r/celogeek/nginx-full-https)
- [Docker Compose Example](https://github.com/celogeek/nginx-full-https/blob/master/docker-compose.example.yml)
- [Configuration Examples](https://github.com/celogeek/nginx-full-https/tree/master/sites.example)

