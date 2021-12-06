{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": "sts:AssumeRole",
            "Resource": "arn:aws:iam::${aws_account}:role/${cluster_name}_${external_secret_role_name_prefix}*"
        }
    ]
}