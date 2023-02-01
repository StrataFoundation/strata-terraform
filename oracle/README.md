# Oracle Accounts

## Before initial deploymenet

Make sure to create bastion ssh key.

## After initial deployment

- Make sure to add RDS users.
- Make sure to execute `/scripts/aws_cni_patch.sh` to enable pod-level network interafces for security group assignement.


To get the kubeconfig,

```
aws eks --region us-east-1 update-kubeconfig  --name helium-prod
```

## On new cluster create

### Route53

First, make sure you have a route53 zone and set `zone_id`. Create a cert for that zone and put in `zone_cert`. Make sure `argo_url` matches that zone, as well as `domain_filter`

### K8s

Every shared secret in the k8s repo will need to be recreated using the new k8s.
