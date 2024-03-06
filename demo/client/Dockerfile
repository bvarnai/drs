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
   ca-certificates \
   rsync \
   uuid-runtime \
   jq \
   openssh-client \
   git \
   nano \
   && rm -rf /var/lib/apt/lists/*

# drs user specific configuration
USER ${USER}
WORKDIR /home/${USER}

RUN mkdir ~/.ssh
COPY --chown=${USER}:${GROUP} ../id_rsa .ssh/id_rsa
COPY --chown=${USER}:${GROUP} ../client/config .ssh/config
COPY --chown=${USER}:${GROUP} ../client/known_hosts .ssh/known_hosts
RUN chmod 700 ~/.ssh && chmod 600 ~/.ssh/id_rsa
RUN ssh-keyscan github.com >> ~/.ssh/known_hosts

# get drs sources
RUN git clone git@github.com:bvarnai/drs.git
RUN echo "export DRS_HOME=~/drs/src" >> ~/.bashrc

# sample git setup (to ensure no Git error messages)
RUN git config --global user.email "you@example.com" && git config --global user.name "Your Name"
