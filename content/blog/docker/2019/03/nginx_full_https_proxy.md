---
title: "Nginx - Full HTTPS Proxy"
hero_image: "hero.jpg"
date: 2019-03-09T19:07:26+01:00
draft: true
description: How-to configure NGINX in Full HTTPS Proxy
categories: ["docker"]
tags: ["nginx", "https"]
---

## Introduction

Nowadays most of the websites are secured over HTTPS.
Tools like [Let's Encrypt](https://letsencrypt.org) make it so easy to secure your website that they are no reason to avoid it.

I have made an easy NGINX setup that allows you to connect any services you need very easily.

My NGINX setup includes:

- https only configuration
- certificate generation and validation:
  - letencrypt
  - nginx config for letencrypt validation
  - script to generate a certificate
- optimization for proxified services
- easy includable file to add new site
- realip:
  - cloudflare auto configuration
  - IPV4/IPV6 detection of the host

## Usage

You can use the service with docker-compose:


*docker-compose.yml:*
```yaml
version: '2.4'

volumes:
  web.ssl
  web.www

services:
  proxy:
    build: proxy
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