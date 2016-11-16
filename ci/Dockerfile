# This file is maintained via modulesync.

# Docker file we use for puppet module ci builds.

FROM gitlab-registry.cern.ch/linuxsupport/cc7-base

# Docker really has no HERE doc?

RUN mkdir -p ~/.ssh && echo -e "Host *\n\tStrictHostKeyChecking no\n\n" > ~/.ssh/config
RUN yum -y install git
RUN git clone https://gitlab.cern.ch/ai/it-puppet-module-ci_images.git && echo "Change Date: 2016-08-26:08"

RUN yum clean all && yum -y update &&\
    yum -y install rubygem-bundler git ruby-devel gcc-c++ make augeas-devel openssh-clients git libxslt-devel rubygem-nokogiri openldap-devel  &&\
    yum install --nogpgcheck -y http://linuxsoft.cern.ch/internal/repos/ai7-stable/x86_64/os/Packages/rubygem-yaml-lint-0.0.4-2.ai7.noarch.rpm


RUN cd /it-puppet-module-ci_images/code && rm -f ../ci/Gemfile.lock ; BUNDLE_GEMFILE=../ci/Gemfile PUPPET_VERSION='~> 3.0' bundle install
RUN cd /it-puppet-module-ci_images/code && rm -f ../ci/Gemfile.lock ; BUNDLE_GEMFILE=../ci/Gemfile PUPPET_VERSION='~> 4.0' bundle install
RUN rm -f /it/puppet-module-ci_images/ci/Gemfile.lock 



