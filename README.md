# wumbo-terraform
Wumbo terraform for AWS infra

## Management

Use https://app.terraform.io/app/wumbo-terraform for deploying.

## Routes

This will deploy the full wumbo cluster. See wumbo-data-pipelines repo for architecture diagram.

| Route | Public Facing? | Description |
---------------------
| dev-kowl.teamwumbo.com | Internal | Explore kafka topics |
| dev-redis.teamwumbo.com | Internal | Explore redis |
| dev-api.teamwumbo.com/graphiql | External | Hit the graphql |


Note that to connect to the non public facing apps, you'll need to run the VPN

## How to connect to VPN

Go to https://s3.console.aws.amazon.com/s3/buckets/dev-wumbo-vpn-keys?region=us-east-2&tab=objects.

Download `wumbo.ovpn`

Install openvpn with homebrew. Then:

```
sudo openvpn --config ~/wumbo.ovpn
```
