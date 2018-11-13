# docker-uptime-monitor

Alpine based Docker image to monitor the uptime of a service. The image is
inpired by the [UptimeRobot](https://uptimerobot.com) job.

## What you need

*   A [Slack](https://slack.com) account
*   [Incoming Webhooks](https://api.slack.com/incoming-webhooks) enabled
*   A Webhook URL
*   [Docke Engine](https://docs.docker.com/install/) and
    [Docker Compose](https://docs.docker.com/compose/install/) installed

## How to configure it

Mandatory environment variables

*   `CHANNEL`: Slack channel where alerts will be published
*   `WEBHOOK`: Webhook URL

Optional environment variables

*   `EMOJI`: Emoji to be used as avatar (default: `:moyai:`)
*   `FREQ`: Cron job frequency (default: `*/5 * * * *`)
*   `SERVICE`: The service name (default: `MyService`)
*   `USERNAME`: The bot name (default: `MyBot`)

Build arguments

*   `extra_packages`: Space separated list of packages to be installed (default: `''`)
*   `tz`: Timezone (default: `Etc/UTC`)

## How to use it

1.  Implement your check script (see [`monitor/check.sh`](./monitor/check.sh))
    in order to echo `1` when your service is UP and `0` when the service is
    DOWN. If needed, extra or specific packages can be installed by defining
    them in `extra_packages` build argument.

2.  Create a compose file like the following
    
        version: '3'
        services:
          monitor:
            build:
              context: .
              args:
                extra_packages: 'coreutils'
                tz: 'Europe/Rome'
            environment:
              CHANNEL: '#monitor'
              WEBHOOK: 'https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX'
              FREQ: '*/1 * * * *'
              EMOJI: ':alien:'
              SERVICE: 'TheAlienService'
              USERNAME: 'ET'

    and run the image

        $ docker-compose up --build

3.  Check your Slack channel and enjoy it!
