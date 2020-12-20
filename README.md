# Igor Gvero - Webhook - Protect Main

Sample GitHub API webservice listening for a webhook invocation that has been presetup on the org level. It subsequently attempts to read the webhook payload, protect the main branch, and open an issue with a notification to the author.

## Requirements

1. Sinatra - > Ruby service
2. ngork - > Tunneling to local machine
3. Octokit - > Ruby toolkit for the GitHub API

## Steps

1. Setup environment variables: ```SECRET_TOKEN``` and ```GH_API_TOKEN```
2. Run the service: ```ruby igor_webhook_service.rb```
3. Run ngork: ```ngrok http 4567```
4. Create a new repository and initialize with README (to guarantee at least one commit in the main branch)

## Troubleshooting

The app is currently having issues aithenticating against GitHub API. In progress of identifying the problem...
