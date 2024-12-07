ARG ARG_UBUNTU_BASE_IMAGE_TAG="20.04"

FROM ubuntu:${ARG_UBUNTU_BASE_IMAGE_TAG}
WORKDIR /azp
ENV TARGETARCH=linux-x64
ENV VSTS_AGENT_VERSION=3.248.0


# To make it easier for build and release pipelines to run apt-get,
# configure apt to not require confirmation (assume the -y argument by default)
ENV DEBIAN_FRONTEND=noninteractive
RUN echo "APT::Get::Assume-Yes \"true\";" > /etc/apt/apt.conf.d/90assumeyes


# Install required tools
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



# Download and extract the Azure DevOps Agent
RUN printenv \
    && echo "Downloading Azure DevOps Agent version ${VSTS_AGENT_VERSION} for ${TARGETARCH}"
RUN curl -LsS https://vstsagentpackage.azureedge.net/agent/${VSTS_AGENT_VERSION}/vsts-agent-${TARGETARCH}-${VSTS_AGENT_VERSION}.tar.gz | tar -xz



# Install Azure CLI & Azure DevOps extension
RUN curl -LsS https://aka.ms/InstallAzureCLIDeb | bash \
    && rm -rf /var/lib/apt/lists/*
RUN az extension add --name azure-devops



# Install required tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    unzip



# Install yq
RUN wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 \
    && mv ./yq_linux_amd64 /usr/bin/yq \
    && chmod +x /usr/bin/yq



# Install Helm
RUN curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash



# Install Kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && mv ./kubectl /usr/bin/kubectl \
    && chmod +x /usr/bin/kubectl



# Install Powershell Core
RUN wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb" \
    && dpkg -i packages-microsoft-prod.deb
RUN apt-get update \
    && apt-get install -y powershell



# Install Docker CLI
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
RUN echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
RUN apt-get update \
    && apt-get install -y docker-ce-cli



# do apt-get upgrade
RUN apt-get update && apt-get -y upgrade



# Copy start script
COPY ./start.sh .
RUN chmod +x start.sh



# Create non-root user under docker group
RUN useradd -m -s /bin/bash -u "1000" azdouser
RUN groupadd docker && usermod -aG docker azdouser
RUN echo "azdouser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
WORKDIR /home/azdouser
RUN chown -R azdouser /home/azdouser
RUN chown -R azdouser /azp
USER azdouser



# cd to /azp and run start.sh
WORKDIR /azp
ENTRYPOINT ["./start.sh"]