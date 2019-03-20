FROM launcher.gcr.io/google/ubuntu16_04

RUN apt-get -y update && \
    apt-get -y install  gcc make unzip gettext-base python2.7 python-dev python-setuptools python-software-properties curl ca-certificates software-properties-common apt-transport-https && \
    curl -fsSL "https://download.docker.com/linux/ubuntu/gpg" | apt-key add - && \
    apt-key fingerprint 0EBFCD88 && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial edge" && \
    add-apt-repository ppa:git-core/ppa && \
    apt-get -y update && \
    apt-get -y install git docker-ce=5:18.09.1~3-0~ubuntu-xenial && \
    mkdir -p /builder && \
    curl -L https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz | tar zxv -C /builder && \
    CLOUDSDK_PYTHON="python2.7" /builder/google-cloud-sdk/install.sh --usage-reporting=false --bash-completion=false --disable-installation-options && \
    easy_install -U pip && \
    pip install -U crcmod && \
    /builder/google-cloud-sdk/bin/gcloud --quiet components install kubectl && \
    curl -sSL -o /usr/local/bin/kustomize "https://github.com/kubernetes-sigs/kustomize/releases/download/v2.0.3/kustomize_2.0.3_linux_amd64" && \
    chmod +x /usr/local/bin/kustomize && \
    curl -sSL -o terraform.zip "https://releases.hashicorp.com/terraform/0.11.13/terraform_0.11.13_linux_amd64.zip" && \
    unzip terraform.zip -d /usr/local/share/terraform && rm -f terraform.zip && \
    apt-get -y remove --purge gcc make python-dev python-setuptools unzip && \
    apt-get --purge -y autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf ~/.config/gcloud

ENV PATH=/builder/google-cloud-sdk/bin/:/usr/local/share/terraform:${PATH}
