#!/bin/bash
#
# This script will create a snapshot of the working directory (including
# checked out modules) and place it in pkg/. The resulting artifact can be
# uploaded to a file hosting service and fetched on target nodes.

# Require that the 
if [ "$#" -ne 1 ]; then
  echo 'one argument required:' 1>&2
  echo '  seteam-puppet-environment version to embed (e.g. 1.0.4)' 1>&2
  exit 1
fi

working_dir=$(basename $(cd $(dirname $0) && pwd))
containing_dir=$(cd $(dirname $0)/.. && pwd)
basename="${containing_dir}/${working_dir}"

mkdir -p "${basename}/environments"
curl https://s3.amazonaws.com/saleseng/environments/seteam-production-${1}.tar.gz \
  > "${basename}/environments/seteam-production-${1}.tar.gz"

version=$(egrep "[0-9]+.[0-9]+.[0-9]+-*" "${basename}/VERSION.md" | head -n 1)
versioned_name="seteam-vagrant-${version}"
mkdir -p "${basename}/pkg"
tar \
  --disable-copyfile \
  -C "${containing_dir}" \
  --exclude ".git" \
  --exclude ".gitignore" \
  --exclude ".gitkeep" \
  --exclude ".pe_build" \
  --exclude ".vagrant" \
  --exclude ".files" \
  --exclude "${working_dir}/.librarian" \
  --exclude "${working_dir}/.tmp" \
  --exclude "${working_dir}/.gitignore" \
  --exclude "${working_dir}/pkg" \
  --exclude "${working_dir}/pkg/*" \
  --exclude "${working_dir}/package.sh" \
  -s "/${working_dir}/${versioned_name}/" \
  -cvzf "${containing_dir}/${versioned_name}.tar.gz" \
  "${working_dir}"
mv "${containing_dir}/${versioned_name}.tar.gz" "${basename}/pkg"
