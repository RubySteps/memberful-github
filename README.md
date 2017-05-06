# memberful-github

webhook to process [memberful events](https://memberful.com/help/integrate/advanced/webhooks/) and
manage github organization membership.

## environment variables

* `MEMBERFUL_WEBHOOK_TOKEN`: an api token sent from memberful to the webhook (add `?token=<MEMBERFUL_WEBHOOK_TOKEN>` to the webhook URL)
* `MEMBERFUL_API_TOKEN`: the api token used to request information from memberful (set up in integrations/custom applications)
* `MEMBERFUL_SUBDOMAIN`: the subdomain component of your memberful site
* `GITHUB_TOKEN`: github api token
* `TEAM_ID`: github team id. new members will be added to this team
* `ORG_NAME`: github org name. members will be removed from the org completely when their subscription deactivates

## TODO

memberful passes a `Secret` to the webhook, so I don't need the hard coded `token` param in the webhook URL.
