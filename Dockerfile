FROM ubuntu:20.04


# To make it easier for build and release pipelines to run apt-get,
# configure apt to not require confirmation (assume the -y argument by default)
ENV DEBIAN_FRONTEND=noninteractive
RUN echo "APT::Get::Assume-Yes \"true\";" > /etc/apt/apt.conf.d/90assumeyes

RUN apt-get update && apt-get install -y --no-install-recommends \
    apt-transport-https \
    apt-utils \
    ca-certificates \
    curl \
    git \
    iputils-ping \
    jq \
    lsb-release \
    software-properties-common \
  && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get -y upgrade

RUN curl -LsS https://aka.ms/InstallAzureCLIDeb | bash \
  && rm -rf /var/lib/apt/lists/*

RUN az extension add --name azure-devops

# Can be 'linux-x64', 'linux-arm64', 'linux-arm', 'rhel.6-x64'.
ENV TARGETARCH=linux-x64

WORKDIR /azp

RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    unzip \
    apt-transport-https \
    software-properties-common

#install yq
RUN wget https://github.com/mikefarah/yq/releases/download/v4.30.8/yq_linux_amd64 \
    && mv ./yq_linux_amd64 /usr/bin/yq \
    && chmod +x /usr/bin/yq

#install helm
RUN curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

#install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && mv ./kubectl /usr/bin/kubectl \
    && chmod +x /usr/bin/kubectl

#install powershell core
RUN wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb" \
    && dpkg -i packages-microsoft-prod.deb
RUN apt-get update \
    && apt-get install -y powershell

#install docker cli
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
RUN echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
RUN apt-get update \
    && apt-get install -y docker-ce-cli

RUN apt-get update && apt-get -y upgrade

COPY ./start.sh .
RUN chmod +x start.sh
RUN curl -LsS https://vstsagentpackage.azureedge.net/agent/3.220.5/vsts-agent-linux-x64-3.220.5.tar.gz | tar -xz

# Create and swith to non-root user
RUN groupadd -g "10000" azuredevops
RUN useradd --create-home --no-log-init -u "10000" -g "10000" azuredevops
RUN apt-get update \
    && apt-get install -y sudo \
    && echo azuredevops ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/azuredevops \
    && chmod 0440 /etc/sudoers.d/azuredevops
RUN sudo chown -R azuredevops /azp
RUN sudo chown -R azuredevops /home/azuredevops

USER azuredevops

ENTRYPOINT ["./start.sh"]