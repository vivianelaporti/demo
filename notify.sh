#!/bin/bash

curl -X POST --data-urlencode "payload={\"channel\": \"#devops\", \"username\": \"webhookbot\", \"text\": \"This is posted to #devops and comes from a bot named webhookbot.\", \"icon_emoji\": \":ghost:\"}" https://hooks.slack.com/services/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
