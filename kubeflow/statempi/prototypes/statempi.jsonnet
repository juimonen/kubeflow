// @apiVersion 0.1
// @name io.ksonnet.pkg.kubeflow-statempi
// @description Prototypes for running openmpi jobs with statefulset.
// @shortDescription Prototypes for running openmpi jobs with statefulset.
// @param name string Name to give to each of the components.
// @param image string Docker image with openmpi.
// @param secret string Name of secret containing ssh keys.
// @optionalParam namespace string null Namespace to use for the components. It is automatically inherited from the environment if not set.
// @optionalParam workers number 4 Number of workers.
// @optionalParam slots number 4 Number of slota.
// @optionalParam init string null Command to bootstrap the containers. Defaults to init.sh.
// @optionalParam exec string null Command to execute in master after bootstrap is done. It sleeps indefinitely if not set.
// @optionalParam gpus number 0 Number of GPUs per worker.

local k = import "k.libsonnet";
local statempi = import "kubeflow/statempi/all.libsonnet";

std.prune(k.core.v1.list.new(statempi.all(params, env)))
