# MPI with statefulset (This has a lot of copied stuff from uber openmpi

Prototypes for running Open MPI statefulset with Kubernetes.

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Quickstart](#quickstart)
- [Running Horovod](#running-horovod)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Quickstart

You need to have Kubernetes cluster setup working with dns

1. Run the following commands to generate and deploy the openmpi component.

```
# Secret name for ssh keys
SECRET=openmpi-secret
# Which branch of Kubeflow to use.
VERSION=mpi
# Image you are going to use
IMAGE=10.237.72.148:5000/horovod/test

# Generate one-time ssh keys used by Open MPI.
ssh-keygen -b 2048 -t rsa -f id_rsa -q -N ""
cp id_rsa.pub authorized_keys
kubectl delete secret ${SECRET}
kubectl create secret generic ${SECRET} ssh-secret --from-file=id_rsa --from-file=id_rsa.pub --from-file=authorized_keys

# Initialize a ksonnet app
ks init test
cd test
ks registry add kubeflow github.com/juimonen/kubeflow/kubeflow/tree/${VERSION}/kubeflow
ks pkg install kubeflow/statempi
ks generate statempi jaska --image=${IMAGE} --workers=2 --slots=40 --secret=${SECRET} --exec="cd /share/examples && mpirun -np 80 -mca orte_keep_fqdn_hostnames t -hostfile /root/hostnames python tensorflow_mnist.py"
ks show default

# Apply to cluster.
ks apply default
