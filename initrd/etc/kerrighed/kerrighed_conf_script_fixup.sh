#!/bin/sh

for f in kerrighed kerrighed-host ; do
  sed -i 's/\. \/lib\/lsb\/init-functions//g' /etc/init.d/${f}
  for i in log_daemon_msg log_end_msg log_failure_msg log_progress_msg log_success_msg ; do
    sed -i s/${i}/echo/g /etc/init.d/${f}
  done
done

sed -i s/^BOOT_ID=.*/BOOT_ID=$(cat /sys/kerrighed/node_id)/g /etc/default/kerrighed-host
sed -i 's#/usr/sbin/sshd -D#/usr/sbin/dropbear -B -R -F -E#g' /etc/kerrighed/krginit_helper.conf
