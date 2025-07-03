
FROM semaphoreui/semaphore:v2.15.0 

#switching to root to install things 
USER root
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

RUN curl -LO "https://github.com/opentofu/opentofu/releases/latest/download/tofu_linux_amd64.zip" && unzip tofu_linux_amd64.zip && mv tofu /usr/local/bin/tofu && chmod +x /usr/local/bin/tofu && rm tofu_linux_amd64.zip

RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && chmod +x kubectl && mv kubectl /usr/local/bin/kubectl

USER semaphore
