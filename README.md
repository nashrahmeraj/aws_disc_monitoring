# aws_disc_monitoring

# About Script
This script is used to monitor the disk uitilization in all your aws instances which are marked by your defined tag name.
Also, automatically increase the space by the pre-defined value.

# Description:
Script monitors the utilization in all volumes of every instance.
If the space utilization exceeds certain pre-defined value, then automatically the space gets increased by your defined percentage of volume.
Post modification, it sends out the slack notification on the changes performed by the script.


# Pre-requisites

-> we need .pem file to connect to instances
-> download aws cli in your instances and in your machine
-> generate aws access key and secret access key 
refer to "https://docs.aws.amazon.com/general/latest/gr/managing-aws-access-keys.html" 

-> configure aws_access_key_id, aws_secret_access_key and region using aws configure set command in each instance
can refer to "https://docs.aws.amazon.com/cli/latest/reference/configure/set.html"

->create extend.sh and utilized_space.sh in each instance to get space utilization percentage of volumes and to extend file systems after modifying volume size.

->generate webhook url of channel or user in slack  whom you want to send the notifications.
 for reference to generate webhook url 
        https://slack.com/intl/en-id/help/articles/115005265063-Incoming-Webhooks-for-Slack


# How to Use !!

-> copy extend.sh and utilized_space.sh files to each instance in home directory 

-> execute this file aws_monitoring.sh

# Next plan

-> to monitor partitions inside volume, to check for their space utilization and extend those partitions.

-> to optimize the code in order to avoid copying extend.sh and utilized_space.sh into every instance
