#!/bin/bash
dir=$(dirname $(readlink -f ${0}))
# Derive repo name from directory.  Override if the repo of this git
# directory isn't the same as the directory's base name.
. ${dir}/scripts/configure
repo=${dir##*/}
host=k8s-git-repo

# .ssh/config entry to enable simple access

# Change port to 22 and comment hostname if using k8s yaml definition.
# and adding the master [ or host like k8s-master-01 ] to /etc/hosts
# If accessing remotely via a docker host, maybe mapping -p 2222:22
# . . .

# You probably want to have either DNS access or /etc/hosts configured
# for your host and jump host name. In this example k8s-master-01 acts
# as the jump host to the DNS enabled k8s cluster

<<MSG
# prefix from scripts/configure
host {prefix}-k8s-jump
  User                  git
#  Port                  2222
# the name I have the k8s service. . .
#  Hostname             alternate-name
  IdentitiesOnly        yes
  TCPKeepAlive          yes
  IdentityFile          ~/.ssh/id_ed25519
# If connecting from non local work laptop for example . . .
  ProxyCommand       ssh -XC -A k8s-master-01 -W '%h:%p'
MSG

# ssh ${host} 'echo ${HOSTNAME}'

ssh ${host}<<INIT
mkdir ${repo}.git
cd ${repo}.git
git init --bare
INIT

cat <<EOF
git remote add ${repo} git@${host}:${repo}.git
git push --set-upstream ${repo} master
git remote add ${prefix}-${repo} git@${prefix}-${host}:${repo}.git
git push ${prefix}-${repo} master
EOF
git remote add ${repo} git@${host}:${repo}.git
git push --set-upstream ${repo} master
git remote add ${prefix}-${repo} git@${prefix}-${host}:${repo}.git
git push ${prefix}-${repo} master

git remote add ${repo} git@github.com:davidwalter0/${repo}.git

# alternatively 
# git remote add origin git@${host}:${repo}.git
# git push --set-upstream origin master