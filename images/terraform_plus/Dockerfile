FROM ubuntu:focal-20211006

ENV TERRAFORM_VER 1.0.9
ENV KUSTOMIZE_VER 4.3.0
ENV KUBECTL_VER 1.22.2
ENV AWS_CLI_VER 2.2.44
ENV J2_CLI_VER 0.3.10
ENV GITHUB_CLI_VER 2.2.0
ENV KUBESEAL_VER 0.16.0
ENV YQ_VER 4.14.1
ENV HELM_VER 3.7.1
ENV SOPS_VER 3.7.1
ENV KSOPS_VER 3.0.1

ENV XDG_CONFIG_HOME $HOME/.config

# install some essentials
RUN apt-get update \
  && apt-get upgrade \
  && apt-get install git curl unzip wget -y

# install aws cli v2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWS_CLI_VER}.zip" -o "awscliv2.zip" \
 && unzip awscliv2.zip \
 && ./aws/install

# install terraform
RUN wget https://releases.hashicorp.com/terraform/${TERRAFORM_VER}/terraform_${TERRAFORM_VER}_linux_amd64.zip --quiet \
 && unzip terraform_${TERRAFORM_VER}_linux_amd64.zip \
 && mv terraform /usr/local/bin/ \
 && chmod +x /usr/local/bin/terraform

 # install kustomize
RUN wget https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv${KUSTOMIZE_VER}/kustomize_v${KUSTOMIZE_VER}_linux_amd64.tar.gz  --quiet \
 && tar xzf kustomize_v${KUSTOMIZE_VER}_linux_amd64.tar.gz \
 && mv kustomize /usr/local/bin/ \
 && chmod +x /usr/local/bin/kustomize

# install GitHub cli
RUN wget https://github.com/cli/cli/releases/download/v${GITHUB_CLI_VER}/gh_${GITHUB_CLI_VER}_linux_amd64.tar.gz  --quiet \
 && tar xzf gh_${GITHUB_CLI_VER}_linux_amd64.tar.gz \
 && mv gh_${GITHUB_CLI_VER}_linux_amd64/bin/gh /usr/local/bin/ \
 && chmod +x /usr/local/bin/gh

# install python-pip
RUN apt-get -qq install -y python3-pip 

# install j2cli
RUN  pip install -qqq j2cli[yaml]==${J2_CLI_VER}

# install kubectl
RUN wget https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VER}/bin/linux/amd64/kubectl --quiet \
 && chmod +x ./kubectl \
 && mv kubectl /usr/local/bin/

# install kubeseal
RUN wget https://github.com/bitnami-labs/sealed-secrets/releases/download/v${KUBESEAL_VER}/kubeseal-linux-amd64 --quiet \
 && chmod +x ./kubeseal-linux-amd64 \
 && mv kubeseal-linux-amd64 /usr/local/bin/kubeseal

# install yq
RUN wget https://github.com/mikefarah/yq/releases/download/v${YQ_VER}/yq_linux_amd64 --quiet \
 && chmod +x ./yq_linux_amd64 \
 && mv yq_linux_amd64 /usr/local/bin/yq

# install Helm
RUN wget https://get.helm.sh/helm-v${HELM_VER}-linux-amd64.tar.gz --quiet \
 && tar xzf helm-v${HELM_VER}-linux-amd64.tar.gz \
 && chmod +x linux-amd64/helm \
 && mv linux-amd64/helm /usr/local/bin/

# install SOPS
RUN wget https://github.com/mozilla/sops/releases/download/v${SOPS_VER}/sops-v${SOPS_VER}.linux --quiet \
 && chmod +x sops-v${SOPS_VER}.linux \
 && mv sops-v${SOPS_VER}.linux /usr/local/bin/sops

# install KSOPS
RUN wget https://github.com/viaduct-ai/kustomize-sops/releases/download/v${KSOPS_VER}/ksops_${KSOPS_VER}_Linux_x86_64.tar.gz --quiet \
 && tar xzf ksops_${KSOPS_VER}_Linux_x86_64.tar.gz \
 && chmod +x ksops \
 && mkdir -p $XDG_CONFIG_HOME/kustomize/plugin/viaduct.ai/v1/ksops/ \
 && mv ksops $XDG_CONFIG_HOME/kustomize/plugin/viaduct.ai/v1/ksops/

# add KSOPS plugin path to 
RUN echo "export XDG_CONFIG_HOME=\${XDG_CONFIG_HOME}" >> $HOME/.bashrc

# check versions
RUN aws --version
RUN terraform --version
RUN kustomize version
RUN kubectl version --client
RUN pip --version
RUN gh --version
RUN j2 --version
RUN kubeseal --version
RUN yq --version
RUN helm version
RUN sops --version
 