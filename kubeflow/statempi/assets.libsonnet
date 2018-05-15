{
  all(params):: [
    $.configMap(params),
  ],

  name(params):: "%s-assets" % params.name,

  configMap(params):: {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
      name: $.name(params),
      namespace: params.namespace,
      labels: {
        app: params.name,
      },
    },
    data: {
      "init.sh": $.genInitfile(params),
      "hostnames": $.genHostfile(params),
      "ssh_config": importstr "assets/ssh_config",
      "sshd_config": importstr "assets/sshd_config",
    },
  },

  genHostfile(params)::
    std.lines(
      std.map(
        function(index) "%(name)s-%(index)d.%(service)s slots=%(slots)d" % {
          index: index,
          name: "tfmpi",
          service: params.name,
          slots: params.slots,
        },
        std.range(0, params.workers - 1)
      )
    ),

  genInitfile(params)::
    std.lines([
      '#! /bin/bash',
      'cp /root/ssh_config /root/.ssh/config',
      'chmod 700 /root/.ssh',
      '/usr/sbin/sshd -f /root/sshd_config',
      'if [ "$HOSTNAME" = tfmpi-0 ]; then',
      'pass=1',
      'while [ $pass != 0 ]; do',
      "    for line in `cat /root/hostnames | cut -d' ' -f 1`; do",
      '        if [ "$line" != ' + '"tfmpi-0.' + params.name + '" ]; then',
      '            ssh -q $line exit',
      '            if [ "$?" -ne "0" ]; then',
      '                echo "$line not ready"',
      '                pass=1',
      '                break',
      '             else',
      '                echo "$line ready"',
      '                pass=0',
      '             fi',
      '         fi',
      '     done',
      '     sleep 1',
      'done',
      params.exec,
      "for line in `cat /root/hostnames | cut -d' ' -f 1`; do",
      '    if [ "$line" != ' + '"tfmpi-0.' + params.name + '" ]; then',
      '        echo "job done"',
      '        echo "1" > /share/term.sig',
      '    fi',
      'done',
      'else',
      '    until [ -f /share/term.sig ]; do',
      '        echo "job not ready"',
      '        sleep 2',
      '    done',
      '        echo "job ready"',
      'fi',
        ],
    ),
}
