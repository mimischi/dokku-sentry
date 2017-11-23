FROM sentry:8.22-onbuild

RUN adduser -D -u 32768 -g dokku dokku
USER dokku
