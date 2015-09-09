#!/bin/bash

script=`basename $0`
working_dir=$(basename $(cd $(dirname $0) && pwd))
containing_dir=$(cd $(dirname $0)/.. && pwd)
basename="${containing_dir}/${working_dir}"
repo='https://github.com/puppetlabs/seteam-puppet-environments'
branch='production'
force='false'
env_dir='../environments'

#Help function
function HELP {
  echo -e \\n"Help documentation for ${script}."\\n
  echo -e "Basic usage: $script -r <repo> -b <branch>"\\n
  echo "Command line switches are optional. The following switches are recognized."
  echo "-r  --Git control repo. Default is https://github.com/puppetlabs/seteam-puppet-environments."
  echo "-b  --Git branch. Default is production."
  echo "-f  --Force. If ../environments/production exists remove it."
  echo -e "-h  --Displays this help message."\\n
  echo -e "Example: $script -r https://github.com/dgrstl/seteam-puppet-environments -b mypoc"\\n
  exit 1
}
cd $basename
cd $env_dir

while getopts :r:b::hf FLAG; do
  case $FLAG in
    r)
      repo=$OPTARG
      echo "repo = $repo"
      ;;
    b)
      branch=$OPTARG
      echo "branch = $branch"
      ;;
    f)
      force='true'
      echo "force = $force"
      ;;
    h)
      HELP
      ;;
    \?) #unrecognized option - show help
      echo -e \\n"Unknown option -$OPTARG."
      HELP
      ;;
  esac
done

if [ -x $env_dir ]; then
  if [ $force = 'true' ]; then
    echo "Removinging ../environments/production"
    rm -rf ../environments/production
  else
    echo "$env_dir exists, use -f option or manually remove."
    exit 1
  fi
fi

echo "we are checking out your fork of the seteam env ${1}, branch $branch into the production Puppet environment"
git clone $repo --branch $branch production

echo "we are making sure r10k is up to date"
puppet resource package r10k ensure=latest provider=gem

cd production

#checkout the puppetfile for the environment
echo "Now we run r10k to deploy the puppetfile and populate the modules directory with the rest of the information"
r10k puppetfile install

#this is where we get weird and use vagrant ssh commands to configure your master for you

vagrant ssh /master/ -c 'sudo /opt/puppet/bin/puppet config set environmentpath /vagrant/environments --section main'
vagrant ssh /master/ -c 'sudo /opt/puppet/bin/puppet resource service pe-puppetserver ensure=stopped'
vagrant ssh /master/ -c 'sudo /opt/puppet/bin/puppet resource service pe-puppetserver ensure=running'
vagrant ssh /master/ -c 'sudo /bin/bash `sudo /opt/puppet/bin/puppet config print environmentpath`/production/scripts/deploy.sh'
