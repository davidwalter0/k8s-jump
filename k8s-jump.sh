#!/bin/bash
debug=0
dir=$(dirname $(readlink -f ${0}))
. ${dir}/.cfg/functions

# set -o errexit
set -o nounset
set -o pipefail

function make-yaml
{
  sed -r -e "s,namespace:.*k8s-jump.*,namespace: ${prefix}-k8s-jump,g"                          \
         -e "s,app:.*k8s-jump.*,app: ${prefix}-k8s-jump,g"                                      \
         -e "s,name:.*k8s-jump.*,name: ${prefix}-k8s-jump,g"                                    \
         -e "s,authorized-keys:.*,authorized-keys: $(base64 -w 0 ~/.ssh/id_${key_type}.pub),g"  \
         -e "s,id-:.*,id-${key_type}: $(base64 -w 0 ~/.ssh/id_${key_type}),g"                   \
         -e "s,id-.pub:.*,id-${key_type}.pub: $(base64 -w 0 ~/.ssh/id_${key_type}.pub),g") ${inyaml}
}

main ${@}

# local variables:
# comment-start: "# "
# mode: shell-script
# end:
