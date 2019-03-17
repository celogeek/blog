---
title: "Nginx - Full HTTPS"
hero_image: "hero.jpg"
date: 2019-03-09T19:07:26+01:00
draft: true
description: How-to configure easily NGINX in HTTPS
categories: ["docker"]
tags: ["nginx", "https"]
---


Nowadays most of the websites are secured over HTTPS.
Tools like [Let's Encrypt](https://letsencrypt.org) make it so easy to secure your website that they are no reason to avoid it.

I have made an easy NGINX setup that allows you to connect any services you need very easily.

My NGINX setup includes:

- https only configuration
- default self certificate for unknown https request
- certificate generation and validation:
  - letencrypt
  - nginx config for letencrypt validation
  - script to generate a certificate
- optimization for proxified services
- easy config file to add new site
- realip:
  - cloudflare auto configuration
  - IPV4/IPV6 detection of the host
