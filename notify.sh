#!/bin/bash

curl -X POST -H 'Content-type: application/json' --data '{"text":"Pipeline successfully executed!"}' $SLACK_WEBHOOK_URL
