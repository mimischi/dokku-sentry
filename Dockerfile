FROM sentry:8.21-onbuild

RUN adduser -D -u 32768 -g dokku dokku
USER dokku
