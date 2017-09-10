# Sentry on Dokku

This project is a clone of the official bootstrap repository ([getsentry/onpremise](https://github.com/getsentry/onpremise)) for running your own [Sentry](https://sentry.io/) with [Dokku](http://dokku.viewdocs.io/dokku/).

## Current version

The current version of the repository will run [Sentry 8.19](https://github.com/getsentry/sentry/releases/tag/8.19.0).

## Requirements

 * [Dokku](https://github.com/dokku/dokku)
 * [dokku-postgres](https://github.com/dokku/dokku-postgres)
 * [dokku-redis](https://github.com/dokku/dokku-redis)
 * [dokku-memcached](https://github.com/dokku/dokku-memcached)
 * [dokku-letsencrypt](https://github.com/dokku/dokku-letsencrypt)


# Setup

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
need to set the settings accordingly.

```
dokku config:set --no-restart sentry SENTRY_EMAIL_HOST=smtp.example.com
dokku config:set --no-restart sentry SENTRY_EMAIL_USERNAME=<yourusername>
dokku config:set --no-restart sentry SENTRY_EMAIL_PASSWORD=<yourmailpassword>
dokku config:set --no-restart sentry SENTRY_EMAIL_PORT=25
dokku config:set --no-restart sentry SENTRY_EMAIL_USE_TLS=True
```

## Domain and SSL certificate

Now we set up a domain name and grab a SSL certificate with Let's Encrypt.

```
dokku domains:set sentry sentry.example.com

dokku config:set --no-restart sentry DOKKU_LETSENCRYPT_EMAIL=you@example.com
dokku config:set --no-restart sentry SENTRY_USE_SSL=True
dokku letsencrypt sentry
```

The Dockerfile will listen on port `9000` for web requests. We need to forward
it using Dokku.

```
dokku proxy:ports-add sentry http:80:9000
```

## Persistent storage

To persists user uploads (e.g. avatars) between restarts, we create a folder on
the host machine and tell Dokku to mount it to the app container.

```
mkdir -p /var/dokku/sentry/data
chown dokku:dokku /var/dokku/sentry/data
dokku storage:mount sentry /var/dokku/sentry/data:/var/lib/sentry/file
```

# Push Sentry to Dokku

First clone this repository onto your machine.

## Via SSH

```git clone git@github.com:mimischi/dokku-sentry.git```

## Via HTTPS

```git clone https://github.com/mimischi/dokku-sentry.git```

Now you need to set up your Dokku server as a remote.

```git remote add dokku dokku@example.com:sentry```

Finally, we can push Sentry to Dokku.

```git push dokku master```
