FROM ghcr.io/opentofu/opentofu:minimal AS opentofu

FROM semaphoreui/semaphore:v2.15.0 

#switching to root to install things 
USER root
RUN apt-get update && apt-get install -y curl unzip wget ca-certificates python3-pip && rm -rf /var/lib/apt/lists/*

# copying opentofu binary from minimal image
COPY --from=opentofu /usr/local/bin/tofu /usr/local/bin/tofu
 # install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && chmod +x kubectl && mv kubectl /usr/local/bin/kubectl

# Install Ansible
RUN pip3 install --no-cache-dir ansible kubernetes PyMySQL boto3

#creating dir fro requirments.txt
RUN mkdir -p /etc/semaphore

#verify installs
RUN tofu version && kubectl version --client && ansible --version

USER semaphore

#setting up working dir
WORKDIR /tmp/semaphore

#Exposing ports
EXPOSE 3000
ENTRYPOINt ["/usr/local/bin/semaphore"]
CMD ["server", "--config","/etc/semaphore/config.json"]
