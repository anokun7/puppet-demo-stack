#!/bin/bash

# this script deploys using the tar.gz found in environments folder
#
# If there is no such file, then it writes a message to this effect to stdout.
# It then drops any firewall rules on the master vagrant box (this is
# typically handled by the seteam demo code).
#
# (This results in a stock PE environment with no demo code or modules.)

# Get the name of the demo tarball, if it exists
ENV_VERSION=$(find /vagrant -name seteam-production*.tar.gz)

if [ -z ${ENV_VERSION} ]
then
  # No SETeam demo tarball. Initialize a vanilla PE Master
  echo "The seteam demo tarball was not found."
  echo "Removing firewall rules to allow agents to communicate with the master."

  # Include some helper functions that we need for initialization
  SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
  source ${SCRIPT_DIR}/lib/no_tarball_support_functions.sh

  # GMS: I know, I know. I'm a little ashamed, too.
  #
  #      But since this is specifically the case where we're setting up a vanilla PE master
  #      with no additional modules, I'm just using bash to remove the firewall rules on 
  #      the puppetlabs/centos-6.5-64-nocm vagrant box.
  iptables -F
  /sbin/service iptables save

  # Use the puppet-classify gem to classify the master with the necessary pe_repo::platform classes
  /opt/puppet/bin/gem install puppetclassify
  /opt/puppet/bin/ruby /vagrant/scripts/classify_pe_master_group.rb

  # Wait for the initial puppet run to complete on the master before proceeding.
  # This will ensure that the support classes are evaluated before we try
  # to create any agent VMs.
  wait_for_initial_puppet_run
else
  tar xzf $ENV_VERSION -C /etc/puppetlabs/puppet/environments/production/ --strip 1

  #we are staging the agent files before we do anything else
  /bin/bash /vagrant/scripts/stage_agents.sh

  /bin/bash /etc/puppetlabs/puppet/environments/production/scripts/deploy.sh
fi
