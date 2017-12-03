FROM sentry:8.22-onbuild

RUN groupadd -r dokku && useradd -r -m -u 32768 -g dokku dokku
USER dokku
