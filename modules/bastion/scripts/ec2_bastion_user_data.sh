#! /bin/bash

# Add repos
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/focal.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/focal.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list

# Update
sudo apt-get update

# Dependency install
sudo apt-get -y install postgresql
sudo apt-get -y install tailscale
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb

# Tailscale
echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
sudo sysctl -p /etc/sysctl.d/99-tailscale.conf
sudo tailscale up --advertise-routes=<INSERT_SUBNETS>

# Upackage CloudWatch Agent
sudo dpkg -i -E ./amazon-cloudwatch-agent.deb

# Create config for CloudWatch Agent to export ssh logs 
cat <<EOF >> config.json
{
  "logs":{
    "logs_collected":{
      "files":{
        "collect_list":[
          {
            "file_path":"/var/log/auth.log",
            "log_group_name":"/aws/ec2/bastion/ssh",
            "log_stream_name":"bastion/var/log/auth"
          }
        ]
      }
    }   
  }
}
EOF

# Initialize CloudWatch Agent with config
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:config.json -s