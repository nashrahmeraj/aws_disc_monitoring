device=$(aws ec2 describe-volumes  --filters Name=volume-id,Values=$1 --query 'Volumes[*].Attachments[*].{Device:Device}' --region us-east-2 --output text)



percent=`df -H $device |awk 'FNR == 2 {print}'| awk '{ print $5 }'`
echo "$percent"

