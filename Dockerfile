FROM amazonlinux:2@sha256:1928c652007d27f087f43e3d652b51415b6751a10d522593166946f110a3be39

ARG RUBY_VERSION
ARG NODEJS_VERSION=10

LABEL org.opencontainers.image.source https://github.com/rewindio/docker-amazonlinux2-ruby
LABEL maintainer "Rewind DevOps <devops@rewind.io>"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN curl -sL https://rpm.nodesource.com/setup_"${NODEJS_VERSION}".x | bash - && \
    curl -sL https://dl.yarnpkg.com/rpm/yarn.repo | tee /etc/yum.repos.d/yarn.repo && \
    yum install -y \
      bzip2-1.0.* \
      gcc-7.3.* \
      gcc-6 \
      gcc-c++-7.3.* \
      gdbm-devel-1.13* \
      git-2.32.* \
      libffi-devel-3.0.* \
      libyaml-devel-0.1.4.* \
      make-3.82* \
      ncurses-devel-6.0.* \
      nodejs-10.* \
      openssl-devel-1.0.2k-* \
      postgresql-devel-9.2.* \
      readline-devel-6.2* \
      tar-1.26* \
      which-20* \
      yarn-22* \
      zip-3.0* \
      zlib-devel-1.2.* && \
    yum clean all && \
    # rbenv
    git clone https://github.com/rbenv/rbenv.git ~/.rbenv && \
    git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build

ENV PATH=/root/.rbenv/bin:/root/.rbenv/plugins/ruby-build/bin:$PATH

RUN rbenv install ${RUBY_VERSION} && \
    rbenv global ${RUBY_VERSION} && \
    rbenv rehash && \
    echo "eval $(rbenv init -)" >> ~/.bashrc && \
    echo "eval $(rbenv init -)" >> ~/.profile

# Setting shim path due to non-interactive bash sessions not running rbenv init
ENV PATH=/root/.rbenv/shims:$PATH

RUN gem install bundler --version=2.1.4

# Blacklist DST Root CA X3
# https://blog.devgenius.io/rhel-centos-7-fix-for-lets-encrypt-change-8af2de587fe4
# https://github.com/mperham/sidekiq/issues/5008
RUN trust dump --filter "pkcs11:id=%C4%A7%B1%A4%7B%2C%71%FA%DB%E1%4B%90%75%FF%C4%15%60%85%89%10;type=cert" \
    > /etc/pki/ca-trust/source/blacklist/dst-root.p11-kit && \
    update-ca-trust extract
