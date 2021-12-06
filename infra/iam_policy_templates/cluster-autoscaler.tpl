{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "clusterAutoscalerAll",
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeLaunchTemplateVersions",
                "autoscaling:DescribeTags",
                "autoscaling:DescribeLaunchConfigurations",
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:DescribeAutoScalingGroups"
            ],
            "Resource": "*"
        },
        {
            "Sid": "clusterAutoscalerOwn",
            "Effect": "Allow",
            "Action": [
                "autoscaling:UpdateAutoScalingGroup",
                "autoscaling:TerminateInstanceInAutoScalingGroup",
                "autoscaling:SetDesiredCapacity"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/enabled": [
                        "true"
                    ],
                    "autoscaling:ResourceTag/kubernetes.io/cluster/${cluster_name}": [
                        "owned"
                    ]
                }
            }
        }
    ]
}
