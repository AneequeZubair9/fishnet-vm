#!/bin/sh

set -euf

echo "init0.sh is launching"

mount -t proc proc /proc -o nosuid,noexec,nodev

# Switch root from read-only ext4 to to read-write overlay
mkdir -p /overlay
/bin/mount -t tmpfs -o noatime,mode=0755 tmpfs /overlay
mkdir -p /overlay/root /overlay/work
/bin/mount -o noatime,lowerdir=/,upperdir=/overlay/root,workdir=/overlay/work -t overlay "overlayfs:/overlay/root" /mnt
mkdir -p /mnt/rom
pivot_root /mnt /mnt/rom

mount --move /rom/proc /proc
mount --move /rom/dev /dev

#echo "Mounts"
#ls /
#ls /dev

mkdir -p /dev/pts
mkdir -p /dev/shm

mount -t sysfs sys /sys -o nosuid,noexec,nodev
mount -t tmpfs run /run -o mode=0755,nosuid,nodev
#mount -t devtmpfs dev /dev -o mode=0755,nosuid
mount -t devpts devpts /dev/pts -o mode=0620,gid=5,nosuid,noexec
mount -t tmpfs shm /dev/shm -omode=1777,nosuid,nodev

# TODO: Move in init1
#ip addr add 172.0.5.2/24 dev eth0
#ip link set eth0 up
#ip route add default via 172.0.5.1 dev eth0
#ip addr

echo "Net up"

#cat /proc/sys/kernel/random/entropy_avail

# TODO: Move in init1
/usr/sbin/sshd -E /var/log/sshd &
echo "SSH UP"

echo "Setup socat"
socat UNIX-LISTEN:/tmp/socat-socket,fork,reuseaddr VSOCK-CONNECT:2:53 &
echo "Socat ready"

# Replace this script with the manager
exec /root/init1.py
