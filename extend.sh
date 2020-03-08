device=$(aws ec2 describe-volumes  --filters Name=volume-id,Values=$1 --query 'Volumes[*].Attachments[*].{Device:Device}' --region us-east-2 --output text)

sudo apt-get update > /dev/null 2>&1;

sudo yum install xfsprogs -y > /dev/null 2>&1 ;

typef=`df -T $device |awk 'FNR == 2 {print}'| awk '{ print $2 }'`
mount_point=`df -T /dev/sdf |awk 'FNR == 2 {print}'| awk '{ print $7 }'`
if [ "$typef" == "xfs" ]
then

        sudo apt-get update > /dev/null 2>&1;

        sudo yum install xfsprogs -y > /dev/null 2>&1 ;

        sudo xfs_growfs -d $mount_point

        echo "file system has been extended"
 elif
         [ "$typef" != "xfs" ]
 then
        sudo resize2fs $mount_point
        echo "file system has been extended"
fi

