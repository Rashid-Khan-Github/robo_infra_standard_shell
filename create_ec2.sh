#! /bin/bash

NAMES=("mongodb" "catalogue" "redis" "user" "cart" "mysql" "shipping" "rabbitmq" "payment")
INSTANCE_TYPE=""
IMAGE_ID=ami-0f3c7d07486cad139
SECURITY_GROUP_ID=sg-03e2563eefcedfe47
DOMAIN_NAME=bsebregistration.com


for i in "${NAMES[@]}"
do
    if [[ $i == "mongodb" || $i == "mysql" ]]
    then
        INSTANCE_TYPE="t3.medium"
    else
        INSTANCE_TYPE="t3.micro"
    fi

    IP_ADDRESS=$(aws ec2 run-instances --image-id $IMAGE_ID --instance-type $INSTANCE_TYPE --security-group-ids $SECURITY_GROUP_ID  --tag-specifications "ResourceType=instance,Tags= [{Key=Name, Value=$i}]" | jq -r '.Instances[0].PrivateIpAddress')

    echo "Creating Instance -> $i----PrivateIP : $IP_ADDRESS"

    aws route53 change-resource-record-sets --hosted-zone-id Z0513646AB3WBDGO9A9V --change-batch '
        {
            "Changes": [{
            "Action": "CREATE",
                        "ResourceRecordSet": {
                                    "Name": "'$i.$DOMAIN_NAME'",
                                    "Type": "A",
                                    "TTL": 300,
                                 "ResourceRecords": [{ "Value": "'$IP_ADDRESS'"}]
                        }}]
        }
    '

done

# Assignment : Improvement the script

# 1) Check instance is already created or not
# 2) Check Route53 record is created, if yes update the existing record

