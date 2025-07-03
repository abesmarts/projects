
FROM semaphoreui/semaphore:v2.15.0 

#switching to root to install things 
USER root
RUN apk add --no-cache curl

RUN curl -LO "https://github.com/opentofu/releases/download/v1.10.2/tofu_1.10.2_linux_amd64.tar.zip" && tar -xzf tofu_1.10.2_linux_amd64.tar.gz && mv tofu /usr/local/bin/tofu && chmod +x /usr/local/bin/tofu && rm tofu_1.10.2_linux_amd64.tar.gz

RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && chmod +x kubectl && mv kubectl /usr/local/bin/kubectl

USER semaphore
