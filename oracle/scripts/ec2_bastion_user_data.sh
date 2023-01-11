#! /bin/bash

# EC2 updates
sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
apt-get update

# Dependency install
apt-get -y install postgresql
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb

# Upackage CloudWatch Agent
dpkg -i -E ./amazon-cloudwatch-agent.deb

# Create config for CloudWatch Agent to export ssh logs 
cat <<EOF >> config-1.json
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
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:config.json -s