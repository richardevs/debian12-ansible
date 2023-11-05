# Ref: https://gist.github.com/pabloab/6c1622fb87042b548a11319a78129f30

echo -e
echo -e "-----------"
echo -e
echo -e "`uptime`" | sed 's/^ //g'
echo -e
echo -e "Unattended Upgrades"
echo -e "Logs: /var/log/dpkg.log, or the files in /var/log/unattended-upgrades/"
echo -e
echo -e "Available memorry: `cat /proc/meminfo | grep MemAvailable | awk {'print int($2/1000)'}` MB   Total memory: `cat /proc/meminfo | grep MemTotal | awk {'print int($2/1000)'}` MB"
echo -e "`df -h | grep -E "/$|Filesystem"`"
echo -e
echo -e "-----------"
echo -e