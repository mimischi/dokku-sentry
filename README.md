![Project logo](.github/header.png)

![Sentry version](https://img.shields.io/badge/Sentry-8.22-blue.svg) ![Dokku version](https://img.shields.io/badge/Dokku-v0.10.4-blue.svg)

# Run Sentry on Dokku

Deploy your own instance of [Sentry](https://sentry.io) onto
[Dokku](https://github.com/dokku/dokku)!

This project is a clone of the official bootstrap repository
([getsentry/onpremise](https://github.com/getsentry/onpremise)) with a few
modifications for a seamless deploy to Dokku.

## What you get

This repository will deploy [Sentry
8.22](https://github.com/getsentry/sentry/releases/tag/8.22.0). It has been
tested with Dokku 0.10+.

## Requirements

 * [Dokku](https://github.com/dokku/dokku)
 * [dokku-postgres](https://github.com/dokku/dokku-postgres)
 * [dokku-redis](https://github.com/dokku/dokku-redis)
 * [dokku-memcached](https://github.com/dokku/dokku-memcached)
 * [dokku-letsencrypt](https://github.com/dokku/dokku-letsencrypt)

# Setup

This will guide you through the set up of your Sentry instance. Make sure to
follow these steps one after another.

## App and databases

First create a new Dokku app. We'll call it `sentry`.

```
dokku apps:create sentry
```

Next we create the databases needed by Sentry and link them.

```
dokku postgres:create sentry-postgres
dokku postgres:link sentry-postgres sentry

dokku redis:create sentry-redis
dokku redis:link sentry-redis sentry

dokku memcached:create sentry-memcached
dokku memcached:link sentry-memcached sentry
```

## Configuration

### Set a secret key

```
dokku config:set --no-restart sentry SENTRY_SECRET_KEY=$(echo `openssl rand -base64 64` | tr -d ' ')
```

### Email settings

If you want to receive emails from sentry (notifications, activation mails), you
need to set the following settings accordingly.

```
dokku config:set --no-restart sentry SENTRY_EMAIL_HOST=smtp.example.com
dokku config:set --no-restart sentry SENTRY_EMAIL_USERNAME=<yourusername>
dokku config:set --no-restart sentry SENTRY_EMAIL_PASSWORD=<yourmailpassword>
dokku config:set --no-restart sentry SENTRY_EMAIL_PORT=25
dokku config:set --no-restart sentry SENTRY_SERVER_EMAIL=sentry@example.com
dokku config:set --no-restart sentry SENTRY_EMAIL_USE_TLS=True
```

## Persistent storage

To persists user uploads (e.g. avatars) between restarts, we create a folder on
the host machine and tell Dokku to mount it to the app container.

```
sudo mkdir -p /var/lib/dokku/data/storage/sentry
sudo chown 32768:32768 /var/lib/dokku/data/storage/sentry
dokku storage:mount sentry /var/lib/dokku/data/storage/sentry:/var/lib/sentry/files
```

## Domain setup

To get the routing working, we need to apply a few settings. First we set
the domain.

```
dokku domains:set sentry sentry.example.com
```

The parent Dockerfile, provided by the sentry project, exposes port `9000` for
web requests. Dokku will set up this port for outside communication, as
explained in [its
documentation](http://dokku.viewdocs.io/dokku/advanced-usage/proxy-management/#proxy-port-mapping).
Because we want Sentry to be available on the default port `80` (or `443` for
SSL), we need to fiddle around with the proxy settings.

First remove the proxy mapping added by Dokku.

```
dokku proxy:ports-remove sentry http:80:5000
```

If `dokku proxy:report sentry` shows that `DOKKU_PROXY_PORT_MAP` is not empty,
remove all remaining port mappings. Next add the correct port mapping for this
project.

```
dokku proxy:ports-add sentry http:80:9000
```

## Push Sentry to Dokku

### Grabbing the repository

First clone this repository onto your machine.

#### Via SSH

```
git clone git@github.com:mimischi/dokku-sentry.git
```

#### Via HTTPS

```
git clone https://github.com/mimischi/dokku-sentry.git
```

### Set up git remote

Now you need to set up your Dokku server as a remote.

```
git remote add dokku dokku@example.com:sentry
```

### Push Sentry

Now we can push Sentry to Dokku (_before_ moving on to the [next part](#domain-and-ssl-certificate)).

```
git push dokku master
```

## SSL certificate

Last but not least, we can go an grab the SSL certificate from [Let's
Encrypt](https://letsencrypt.org/).

```
dokku config:set --no-restart sentry DOKKU_LETSENCRYPT_EMAIL=you@example.com
dokku config:set --no-restart sentry SENTRY_USE_SSL=True
dokku letsencrypt sentry
```

## Create a user

Sentry is now up and running on your domain ([https://sentry.example.com](#)).
Before you're able to use it, you need to create a user.

```
dokku run sentry sentry createuser
```

This will prompt you to enter an email, password and whether the user should be a superuser.
