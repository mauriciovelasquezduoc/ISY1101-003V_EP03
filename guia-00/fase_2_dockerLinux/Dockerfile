FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
      curl \
      git \
      unzip \
      jq \
      less \
      groff \
      ca-certificates \
      procps \
      iputils-ping \
      net-tools \
      vim \
      nano && \
    \
    # -----------------------------------------------------
    # AWS CLI v2
    # -----------------------------------------------------
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" \
      -o "/tmp/awscliv2.zip" && \
    unzip /tmp/awscliv2.zip -d /tmp && \
    /tmp/aws/install && \
    \
    # -----------------------------------------------------
    # AWS Session Manager Plugin
    # -----------------------------------------------------
    curl -L "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" \
      -o "/tmp/session-manager-plugin.deb" && \
    dpkg -i /tmp/session-manager-plugin.deb && \
    \
    # -----------------------------------------------------
    # kubectl
    # -----------------------------------------------------
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
    rm kubectl && \
    \
    # -----------------------------------------------------
    # Limpieza
    # -----------------------------------------------------
    rm -rf /var/lib/apt/lists/* /tmp/*

# =========================================================
# Configuración Git
# =========================================================

RUN git config --global init.defaultBranch main && \
    git config --global color.ui auto && \
    git config --global user.email "you@example.com" && \
    git config --global user.name "Your Name"

# =========================================================
# Prompt Git Bash
# =========================================================

RUN echo 'parse_git_branch() {' >> /root/.bashrc && \
    echo '  git branch 2> /dev/null | sed -e "/^[^*]/d" -e "s/* \(.*\)/(\1)/"' >> /root/.bashrc && \
    echo '}' >> /root/.bashrc && \
    echo 'export PS1="\u@\h:\w\[\033[32m\]\$(parse_git_branch)\[\033[00m\] $ "' >> /root/.bashrc

# =========================================================
# Validaciones opcionales
# =========================================================

RUN aws --version && \
    kubectl version --client

CMD ["/bin/bash"]