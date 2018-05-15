local assets = import "kubeflow/statempi/assets.libsonnet";
local service = import "kubeflow/statempi/service.libsonnet";
local workloads = import "kubeflow/statempi/workloads.libsonnet";

{
  all(params, env):: $.parts(params, env).all,

  parts(params, env):: {
    // updatedParams uses the environment namespace if
    // the namespace parameter is not explicitly set
    local updatedParams = params {
      namespace: if params.namespace == "null" then env.namespace else params.namespace,
      init: if params.init == "null" then "/root/init.sh" else params.init,
      exec: if params.exec == "null" then "sleep infinity" else params.exec,
    },

    all::
      assets.all(updatedParams)
      + service.all(updatedParams)
      + workloads.all(updatedParams),
  },
}
