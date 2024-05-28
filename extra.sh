location /api/shipping/ { proxy_pass http://shipping.bsebregistration.com:8080/; }
location /api/payment/ { proxy_pass http://payment.bsebregistration.com:8080/; }

aws ec2 run-instances --image-id ami-0f3c7d07486cad139 --instance-type t2.micro
 --security-group-ids sg-03e2563eefcedfe47
 --tag-specifications resourceType=Instance, Tags= [{Key=Name, Value=$i}]


    aws route53 change-resource-record-sets --hosted-zone-id Z0513646AB3WBDGO9A9V --change-batch '
        {
            "Comment": "CREATE/DELETE/UPSERT a record ",
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

aws ec2 run-instances --image-id ami-0f3c7d07486cad139 --instance-type t2.micro --security-group-ids sg-03e2563eefcedfe47  --tag-specifications "ResourceType=instance,Tags= [{Key=Name, Value=Web}]" | jq -r '.Instances[0].PrivateIpAddress'
