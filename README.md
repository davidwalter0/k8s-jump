# k8s-jump

k8s-jump is a utility jump server container and k8s service +
replication controller definition for ssh access into a kubernetes
cluster.

The default user is 'jump' and enables a jump box definition for an
ssh service into a k8s cluster.

This is a beta version for testing.

---

## Options
- [x] ssh keys auto insertion to kubernetes/secrets
- [x] hostname setup with auto prefix from scripts/configure variable
- [x] credentials only stored in ignored file .cfg/.{hostname}.cfg

---

```
# test repo container name k8s-jump
# For a docker based test . . .
# .bashrc function for docker ip
function docker-ip
{
    if [[ -n ${1} ]]; then
        docker inspect --format='{{ .NetworkSettings.IPAddress }}' ${1}
    else
        echo usage: docker-ip cid
    fi
}
# example test run
sudo docker run --name k8s-jump -itd k8s-jump
ssh $(docker-ip k8s-jump)
docker stop k8s-jump
docker rm -v k8s-jump

```



The formula in this assume that script/credentials has two environment
variables set: user + password. that file is sourced by script/functions

```
${KUBECTL} config --kubeconfig=${KUBECONFIG}    \
                  set-credentials               \
                  cluster-admin                 \
                      --username=${user}        \
                      --password=${password}
```

If you want to override the interactive call in the configure
script/credentials file set mode to 600. Using standard shell env
variable syntax or source environment variables with the values for
the kubernetes kubectl access.

```
## script/credentials
user=name
password=password
```

chmod 600 script/credentials

Currently the script generates a .cfg/{cluster-name} file with
kubernetes configuration.

---
## script/configure

validates the presence of prefix and key_type.

A function validate evaluates that the required variables are set.

---
## .ssh/config

A sample ssh per use config option might look like the following, to
enable key only access. Ensure that the key type matches the key type
used in the identity file and script/configure key_type, notice that
this 'jumps' via a k8s-master-01.

```
host *k8s-jump
  User                  jump
  Port                  22
  IdentitiesOnly        yes
  TCPKeepAlive          yes
  #                            id_{key_type}
  IdentityFile          ~/.ssh/id_rsa
  ProxyCommand          ssh -XCA k8s-master-01 -W '%h:%p'
```

---

Next steps:

