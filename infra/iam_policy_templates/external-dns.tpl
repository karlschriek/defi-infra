{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": "route53:GetChange",
            "Resource": "arn:aws:route53:::change/*"
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "route53:ListResourceRecordSets",
                "route53:ChangeResourceRecordSets"
            ],
            "Resource": "${hosted_zone_arn}"
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "route53:ListHostedZonesByName",
                "route53:ListHostedZones"
            ],
            "Resource": "*"
        }
    ]
}
