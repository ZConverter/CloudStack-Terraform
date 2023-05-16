#! /bin/bash

echo 'root:p@ssw0rd' | chpasswd
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/#PermitRootLogin no/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/PermitRootLogin no/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/$PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl restart sshd

zdm_path="https://www.zconverter.co.kr/zdm/rep_test/install.sh"
wget -P /tmp/ $zdm_path --no-check-certificate >> /tmp/zdm_download.log
iptables -F
bash -C /tmp/install.sh -n -l -d 127.0.0.1 >> /tmp/zdm_install.log
umount /ZConverter
fdisk /dev/vdb <<EOF
n
p




w
EOF
mkfs.ext4 /dev/vdb1
mount /dev/vdb1 /ZConverter
chown zconverter.zconverter /ZConverter
sed -i "s/sServerIPAddress:$(hostname -I | tr -d ' ')/sServerIPAddress:10.40.99.99/g" /ZConverterManager/option.conf
sed -i "s/sZCMIPAddress:/sZCMIPAddress:10.40.99.99/g" /ZConverterManager/option.conf
smbpasswd -a -s zconverter <<EOF
ZConp@ssw0rd
ZConp@ssw0rd
EOF
systemctl restart zcm