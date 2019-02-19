import json
import os

from slackclient import SlackClient
from urlparse import parse_qs

token = os.environ['SLACK_API_TOKEN']


def make_slack_client_call(
        sc=SlackClient(token),
        text='blank',
        attachments=None,
        message_type='chat.postMessage',
        channel='#general',
        user=''
):
    return sc.api_call(
        message_type,
        channel=channel,
        text=text,
        user=user,
        attachments=attachments
    )


def json_response(msg=None, attachments=None, status_code=200):
    response = {'statusCode': status_code}

    if attachments:
        response['body'] = {}
        response['body']['attachments'] = attachments
        if msg:
            response['body']['text'] = msg
        response['body'] = json.dumps(response['body'])
    elif msg:
        response['body'] = msg

    return response


def map_query_keys_to_string(some_list):
    # TODO: Shorten this
    formatted = ""
    for key in some_list.keys():
        formatted += "*%s*: %s\n" % (key, str(some_list[key][0]))
    return formatted


def request_is_invalid(queries):
    verification_token = str(queries['token'][0])
    return verification_token != os.environ['SLACK_VERIFICATION_TOKEN']


def add_debug_data(res):
    # TODO: shorten this
    res_keys = ''
    for k in res.keys():
        res_keys += "*%s*: %s\n" % (k, str(res[k]))
    return res_keys


def lambda_handler(event={}, context={}):

    if "body" not in event.keys():
        return json_response(msg='Malformed request, bailing...', status_code=400)

    queries = parse_qs(event['body'])

    if request_is_invalid(queries):
        return json_response(status_code=401, msg="Unauthorized!")

    user_id = str(queries['user_id'][0])

    res = make_slack_client_call(
        channel=user_id,
        text='This is the response from calling the SlackClient API for user <@%s>' % user_id
    )

    if not res['ok']:
        error_msg = "It broke, query details:\n" + \
                    map_query_keys_to_string(queries) + \
                    "\n*Error*: %s\n" % str(res['error']) + \
                    add_debug_data(res)
        return json_response(msg=error_msg)
    else:
        return json_response(msg='This is the response from calling a slash command')
