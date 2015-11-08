#!/bin/bash
dir=$(dirname $(readlink -f ${0}))
name=private # ${dir##*/}
yaml=${dir}/k8s-jump.yaml
inyaml=k8s-jump-rc+svc.yaml

# set -o errexit
set -o nounset
set -o pipefail

# For a secure tunnel to an kubernetes master you might do:
# kubemaster=10.14.140.19 ssh -f -nNT -L 8080:127.0.0.1:8080 core@${kubemaster}

# but this script is using credentials sourced from script/credentials
# [user prompted cluster user and pass]

export KUBE_HOST_OS_USER=centos
export KUBE_MASTER=k8s-dw-master-01
export KUBECTL=${dir}/bin/kubectl
export KUBECONFIG=${dir}/.cfg/.k8s-dw-master-01.cfg
. ${dir}/scripts/configure
. ${dir}/scripts/functions
# rm -f ${yaml}
KUBECTL="${KUBECTL} --kubeconfig=${KUBECONFIG}"
function make-yaml
{
    cat <<EOF                                                                 
$(cat ${inyaml}|                                                                                \
  sed -r -e "s,namespace:.*k8s-jump.*,namespace: ${prefix}-k8s-jump,g"                          \
         -e "s,app:.*k8s-jump.*,app: ${prefix}-k8s-jump,g"                                      \
         -e "s,name:.*k8s-jump.*,name: ${prefix}-k8s-jump,g"                                    \
         -e "s,authorized-keys:.*,authorized-keys: $(base64 -w 0 ~/.ssh/id_${key_type}.pub),g"  \
         -e "s,id-:.*,id-${key_type}: $(base64 -w 0 ~/.ssh/id_${key_type}),g"                   \
         -e "s,id-.pub:.*,id-${key_type}.pub: $(base64 -w 0 ~/.ssh/id_${key_type}.pub),g")
EOF
}

# if [[ ! -e ${yaml} ]]; then
#     make-yaml > ${yaml}
# fi

chmod 700 . ${yaml}
chmod 600 ${yaml}

if ! [[ ${KUBECTL-} ]]; then
    echo Fix the location of the kubectl command
    exit 1
fi

function start
{
#    ${KUBECTL} create -f ${dir}/${name}.yaml
    ${KUBECTL} create -f- <<EOF
$(make-yaml)
EOF
}

function stop
{
#    ${KUBECTL} delete -f ${dir}/${name}.yaml
    ${KUBECTL} delete -f- <<EOF
$(make-yaml)
EOF
}

function status
{
    ${KUBECTL} get --output=wide node
    ${KUBECTL} get --all-namespaces --output=wide rc,pods,svc,ep
}

function usage
{
    cat <<EOF

${0##*/} [--start|--stop|--status]

Run a private jump ssh login in kubernetes with k8s secret from ssh keys
injected at create time from the user's '~/.ssh/id_*{,.pub}' files.

EOF
    exit 3
}

function main
{
    if (( $# )) ; then
        for arg in ${@}; do
            case ${arg} in
                --start)
                    start
                    ;;
                --stop)
                    stop
                    ;;
                --status)
                    status
                    ;;
                *)
                    usage
            esac
        done
    else
        usage
    fi
    exit
}

main ${@}

# local variables:
# comment-start: "# "
# mode: shell-script
# end:
