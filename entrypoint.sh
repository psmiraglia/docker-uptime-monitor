#!/bin/bash

if [ "X${CHANNEL}" == "X" ]; then
  (>&2 echo "The Slack channel must be set! (use CHANNEL envvar)")
  exit 1
fi

if [ "X${WEBHOOK}" == "X" ]; then
  (>&2 echo "The webhook URL must be set! (use WEBHOOK envvar)")
  exit 1
fi

_FREQ=${FREQ:-"*/5 * * * *"}  # eachi five minutes

echo "${_FREQ} /opt/monitor/cronjob.sh" >> /var/spool/cron/crontabs/root

exec crond -l 2 -f
