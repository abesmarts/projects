FROM semaphoreui/semaphore:v2.15.0

#Setting env variables
ENV OPENTOFU_VERSION=1.10.1
ENV OPENTOFU_ARCH=linux_amd64

RUN apt-get update && apt-get install -y \
curl \
unzip \
wget \
ca-certificates \
&& rm -rf /var/lib/apt/lists/*

#download and install opent
RUN curl -LO "https://github.com/opentofu/opentofu/releases/download/v${OPENTOFU_VERSION}/tofu_${OPENTOFU_VERSION}_${OPENTOFU_ARCH}.zip" && unzip "tofu_${OPENTOFU_VERSION}_${OPENTOFU_ARCH}.zip" && mv tofu /usr/local/bin/tofu && chmod +x /usr/local/bin/tofu && rm "tofu_${OPENTOFU_VERSION}_${OPENTOFU_ARCH}.zip"

# install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && chmod +x kubectl && mv kubectl /usr/local/bin/kubectl

# Install Ansible
RUN apt-get update && apt-get install -y python3-pip python3-dev && pip3 install ansible && rm -rf /var/lib/apt/lists/*

#verify installs
RUN tofu version && kubectl version --client && ansible --version

#setting up working dir
WORKDIR /tmp/semaphore

#Exposing ports
EXPOSE 3000

ENTRYPOINT ["/usr/local/bin/semaphore"] 
CMD ["server","--config","/etc/semaphore/config.json"]



