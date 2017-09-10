web: uwsgi --ini=uwsgi.ini --http=0.0.0.0:9000
worker: sentry --config=sentry.conf.py run worker --loglevel=INFO
beat: sentry --config=sentry.conf.py run cron --loglevel=INFO
release: sentry --config=sentry.conf.py upgrade --noinput
