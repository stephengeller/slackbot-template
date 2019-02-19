#!/usr/bin/env python

import json
import os

os.environ['SLACK_API_TOKEN'] = "your_slack_token_here"

from src import slackbot

with open('test_event.json') as f:
    test_event = json.load(f)

slackbot.lambda_handler(test_event)