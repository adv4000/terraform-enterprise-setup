#!/bin/bash
dnf -y update
dnf -y install nginx

HOSTNAME=$(hostname)

cat <<EOF > /usr/share/nginx/html/index.html
<html>
<body bgcolor="black">
<h2><font color="silver">Environment: <font color="magenta">${environment}</font></h2>
<h2><font color="gold">Build with Power of <font color="red">Terraform and AWS!</font></h2><br>
<font color="white">Server Hostname: <font color="aqua">$HOSTNAME<br><br>
<font color="yellow">
<b>Version 1.0</b>
</body>
</html>
EOF

systemctl start nginx
systemctl enable nginx
