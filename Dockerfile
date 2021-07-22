ARG RUBY_VERSION=2.7
ARG NODEJS_VERSION=10

FROM amazonlinux:2

LABEL org.opencontainers.image.source https://github.com/rewindio/docker-amazonlinux2-ruby
LABEL maintainer "Rewind DevOps <devops@rewind.io>"

RUN yum update -y -q && yum install -y -q git which zip tar gcc-6 bzip2 openssl-devel libyaml-devel libffi-devel readline-devel zlib-devel gdbm-devel ncurses-devel gcc-c++ gcc make postgresql-devel

RUN git clone https://github.com/rbenv/rbenv.git ~/.rbenv

RUN git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build

SHELL ["/bin/bash", "-l", "-c"]

ENV PATH=/root/.rbenv/bin:/root/.rbenv/plugins/ruby-build/bin:$PATH

ARG RUBY_VERSION
RUN rbenv install ${RUBY_VERSION}
RUN rbenv global ${RUBY_VERSION} && rbenv rehash

RUN echo 'eval "$(rbenv init -)"' >> ~/.bashrc
RUN echo 'eval "$(rbenv init -)"' >> ~/.profile

# Setting shim path due to non-interactive bash sessions not running rbenv init
ENV PATH=/root/.rbenv/shims:$PATH

RUN gem install bundler --version=2.1.4

# add the node repo
ARG NODEJS_VERSION
RUN curl -sL https://rpm.nodesource.com/setup_${NODEJS_VERSION}.x | bash -
# add the yarn repo
RUN curl -sL https://dl.yarnpkg.com/rpm/yarn.repo | tee /etc/yum.repos.d/yarn.repo

#install node10 and yarn
RUN yum install -y -q nodejs yarn
