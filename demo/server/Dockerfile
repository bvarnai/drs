FROM ubuntu:latest

# setup drs group/user
ARG GID=1000
ARG GROUP=drs
ARG UID=1000
ARG USER=drs

RUN addgroup --gid ${GID} ${GROUP} && \
    adduser --disabled-password --gecos '' --uid ${UID} --gid ${GID} ${USER}

# install tools
RUN apt-get update && \
   apt-get install -y --no-install-recommends \
   sudo \
   rsync \
   openssh-server \
   git \
   && rm -rf /var/lib/apt/lists/*

# add drs user to sudoers and make it passwordless
RUN adduser ${USER} sudo && \
    echo "${USER} ALL=NOPASSWD: ALL" >> /etc/sudoers

# sshd setup
COPY ../server/ssh_host_* /etc/ssh/
RUN chmod 600 /etc/ssh/ssh_host_*
RUN mkdir /var/run/sshd
CMD ["sudo", "/usr/sbin/sshd", "-D"]

# drs user specific configuration
USER ${USER}
WORKDIR /home/${USER}

RUN mkdir ~/.ssh
COPY --chown=${USER}:${GROUP} ../id_rsa.pub .ssh/authorized_keys
RUN chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys
RUN touch ~/.ssh/known_hosts && ssh-keyscan github.com >> ~/.ssh/known_hosts

# drs bare repository
COPY --chown=${USER}:${GROUP} ../server/drs-demo.git.tar.gz drs-demo.git.tar.gz
RUN tar -zxf drs-demo.git.tar.gz && rm drs-demo.git.tar.gz

# rds home
RUN mkdir -p ~/drs-home/myproject
