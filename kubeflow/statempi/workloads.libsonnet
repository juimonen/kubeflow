local assets = import "kubeflow/statempi/assets.libsonnet";
local service = import "kubeflow/statempi/service.libsonnet";

{
  all(params)::
    [$.pod(params)],

  pod(params):: {
    apiVersion: "apps/v1",
    kind: "StatefulSet",
    metadata: {
      name: "tfmpi",
    },
    spec: {
      serviceName: params.name,
      replicas: params.workers,
      podManagementPolicy: "Parallel",
      selector: {
        matchLabels: {
          app: params.name,
        },
      },
      template: {
        metadata: {
          labels: {
            app: params.name,
          },
        },
        spec: {
          volumes: $.volumes(params),
          containers: $.containers(params),
        },
      },
    },
  },

  volumes(params):: [
    {
      name: "share",
      hostPath: {
        path: "/nfsfiles",
      },
    },
    {
      name: "ssh-config",
      secret: {
        secretName: params.secret,
        defaultMode: 384,  // 0600
        items: [
          {
            key: "id_rsa",
            path: "id_rsa",
          },
          {
            key: "id_rsa.pub",
            path: "id_rsa.pub",
          },
          {
            key: "authorized_keys",
            path: "authorized_keys",
          },
        ],
      },
    },
    {
      name: assets.name(params),
      configMap: {
        name: assets.name(params),
      },
    },
  ],
  
  containers(params):: [
  {
      name: "horovod",
      image: params.image,
      workingDir: "/root",
      command: [
        "/bin/bash",
        params.init,
      ],
      ports: [
        {
          containerPort: 2022,
        },
      ],
      volumeMounts: [
        {
          mountPath: "/share",
          name: "share",
        },
        {
          mountPath: "/root/.ssh",
          name: "ssh-config",
        },
        {
          mountPath: "/root",
          name: assets.name(params),
        },
      ],
    },
  ],
}
