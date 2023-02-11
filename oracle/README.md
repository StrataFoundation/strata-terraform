# Oracle Accounts

## Before initial deploymenet

Make sure to create bastion ssh key.

## After initial deployment

- Add uuid-ossp extension
- Create databases
- Add RDS users to databases with proper permissions
  - `create role iot_oracle with login;`
  - `grant rds_iam to iot_oracle`
  - `grant select on table reward_index to iot_oracle`
- Execute `/scripts/aws_cni_patch.sh` to enable pod-level network interafces for security group assignement.


To get the kubeconfig,

```
aws eks --region <us-east-1|us-west-2> update-kubeconfig  --name <env>-<stage>
```

## On new cluster create

### Route53

First, make sure you have a route53 zone and set `zone_id`. Create a cert for that zone and put in `zone_cert`. Make sure `argo_url` matches that zone, as well as `domain_filter`

### K8s

Every shared secret in the k8s repo will need to be recreated using the new k8s.
