TERRAFORM_VER=1.0.9 #manually set this to the same version specified in the dockerfile

# log into ECR
aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws/i7s5v1d3

# pull current latest
docker pull public.ecr.aws/i7s5v1d3/terraform-plus:${TERRAFORM_VER}
docker pull public.ecr.aws/i7s5v1d3/terraform-plus:latest

# build image
docker build -t terraform-plus .

# tag and push "latest"
docker tag terraform-plus:latest public.ecr.aws/i7s5v1d3/terraform-plus:latest
docker push public.ecr.aws/i7s5v1d3/terraform-plus:latest

# tag and push "${TERRAFORM_VER}"
docker tag terraform-plus:latest public.ecr.aws/i7s5v1d3/terraform-plus:${TERRAFORM_VER}
docker push public.ecr.aws/i7s5v1d3/terraform-plus:${TERRAFORM_VER}







