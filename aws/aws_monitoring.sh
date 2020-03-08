#global variables to be used in script
SLACK_URL="add your webhook url to send notification"
MAX_CHECK_PERCENT=80
INCREASE_PERCENT=20

function checkForEveryVolume(){
 echo "checking for volume $1"
 instanceid=$2
 instance_name=$3
 dns=$4
 local disc_perc
 disc_perc=$(ssh -i "key.pem" ec2-user@$dns bash -x utilized_space1.sh $1)

 used_space_value="${disc_perc//%}"

 size=$( aws ec2 describe-volumes  --filters Name=volume-id,Values=$1 --query 'Volumes[*].{Size:Size}' --region us-east-2 --output text)

 echo "Total volume size in instance id: $instanceid with instance name:  $instance_name is " $size

 echo "Already utilized space in the instance:  $instance_name is " $disc_perc
# deciding whether to increase space or not. keeping it as 80
 if [ $used_space_value -ge $MAX_CHECK_PERCENT ]
 then
        echo "going to increase the volume by $INCREASE_PERCENT percent of total existing volume automatically"
        val=$(echo 0.2*$size | bc)
        val=`printf %0.f $val`
        echo "rounded value of $INCREASE_PERCENT percent volume is "$val
        total=`echo $size+$val|bc`
        total_size=`printf %0.f $total`

        END=`date -u +"%Y-%m-%d %H:%M:%S"`
        START=$(aws ec2 describe-volumes-modifications --volume-id $vids --query "VolumesModifications[0].{StartTime:StartTime}" --output text)
START1=`echo $START | tr "T" " " | tr "Z" " "`
curr_hour=$(date -d "$END" '+%s')
last_run_hour=$(date -d "$START1" '+%s')

echo $last_run_hour
echo $curr_hour
HRS_GAP=$(($(($curr_hour-$last_run_hour)) / 3600 ))
echo "hours gap" $HRS_GAP

 state=$(aws ec2 describe-volumes-modifications --volume-id $1 --query "VolumesModifications[*].{ModificationState:ModificationState}" --output text)
       

        if [ "$state" == "modifying" ] || [ "$state" == "optimizing" ]
        then
        curl -X POST -H 'Content-type: application/json' --data '{"text":"AUTOMATED_SCRIPT: Cannot modify size of volume (current state is '"$state"'), modification can be performed ONLY on completed state"}' $SLACK_URL
      elif [ "$state" == "completed" ]
        then 
		#if if volume was modified in past days then hours gap may be negative else check for 6 hrs gap
                if [ $HRS_GAP -ge 6 ]
                then
                        date_=$(date)
                        aws ec2 modify-volume --size $total_size --volume-id $1 
                        curl -X POST -H 'Content-type: application/json' --data '{"text":"AUTOMATED_SCRIPT: Volume size of instance id '"$instanceid"'(with current state '"$state"') has been  increased to '$INCREASE_PERCENT' which is '"$total_size"' Gb from existing '"$size"' Gb on '"$date_"'"}' $SLACK_URL          
		       	local status
			status= $(ssh -i "key.pem" ec2-user@$dns bash -x extend.sh $1 )
                        echo $status
                else
                        curl -X POST -H 'Content-type: application/json' --data '{"text":"AUTOMATED_SCRIPT: Cannot modify size of volume (current state is '"$state"'), modification can be ONLY done after 6 hrs of previous changes"}' $SLACK_URL
               fi
        fi

else
        echo "Space utilization in the instance id: $instanceid with instance name: $instance_name is below $MAX_CHECK_PERCENT percent. Therefore, not increasing volume "
fi

}


function monitorInstance(){
 instanceid=$1
 instance_name=$2
 dns=$(aws ec2 describe-instances --instance-ids $instanceid --query 'Reservations[].Instances[].PublicDnsName' --output text)

 echo "inside function, values of instanceID: $instanceid, instance name: $instance_name, dns: $dns"
 IFS=$'\n'
 for vids in $(aws ec2 describe-volumes  --filters Name=attachment.instance-id,Values=$instanceid --query 'Volumes[*].{ID:VolumeId}' --output text)
  do
   checkForEveryVolume $vids $instanceid $instance_name $dns
  done
}


#setting delimiter for reading the instances output 
 IFS=$'\n'
 for ids in $(aws ec2 describe-instances --filters "Name=tag:Type,Values=Sample" --query 'Reservations[*].Instances[*].[InstanceId, Tags[?Key==`Name`].Value | [0]]' --output text)
 do
  IFS=$'\t'
  instance_details=($ids)
  instanceid="${instance_details[0]}"
  instance_name="${instance_details[1]}"
  echo "Going to monitor the instance id: " $instanceid "with the instance name: " $instance_name

  echo "==============================START OF MONITORING . Instance Name: $instance_name ================================"
  monitorInstance $instanceid $instance_name
  echo "================================ END of MONITORING . Instance Name: $instance_name  =============================="
 done











