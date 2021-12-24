# VPN

Based on https://github.com/dumrauf/openvpn-terraform-install/blob/master/ec2.tf

Once it's done, you can go to s3 and download strata.ovpn

Then 

```
sudo openvpn --config ~/strata.ovpn
```