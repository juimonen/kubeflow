#! /bin/bash
chmod 700 /root/.ssh
if [ "$HOSTNAME" = tfmpi-0 ]; then
/usr/sbin/sshd
pass=1
while [ $pass != 0 ]; do
    for line in `cat /root/hostnames`; do
        if [ "$line" != "tfmpi-0.tfuber" ]; then
            ssh -q $line exit
            if [ "$?" -ne "0" ]; then
                echo = "$line no ready"
                pass=1
                break
            else
                echo "$line ready"
                pass=0
            fi
        fi
    done
    sleep 1
done
else
/usr/sbin/sshd -D
fi
