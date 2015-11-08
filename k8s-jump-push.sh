#!/bin/bash
dir=$(dirname $(readlink -f ${0}))
image=${dir##*/}
docker save ${image} > ${image}.tar
for host in k8s-dw-node-0{1..2}; do
    ssh ${host} mkdir -p work
    rsync -rlaz --progress --partial ${dir}/${image}.tar ${host}:work/
    ssh -tt ${host} 'for file in work/${image}.tar; do sudo docker load -i ${file}; done'
done
