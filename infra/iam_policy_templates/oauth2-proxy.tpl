{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Elasticache",
            "Effect": "Allow",
            "Action": "elasticache:*",
            "Resource": [
                "${elasticache_cluster_arn}"
            ]
        }
    ]
}