#!/bin/bash

curl -X POST --data-urlencode "payload={\"channel\": \"#devops\", \"username\": \"webhookbot\", \"text\": \"This is posted to #devops and comes from a bot named webhookbot.\", \"icon_emoji\": \":ghost:\"}" $SLACK_WEBHOOK_URL
