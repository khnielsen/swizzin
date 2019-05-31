#!/bin/bash
#
# [Quick Box :: Install Jackett package]
#
# GITHUB REPOS
# GitHub _ packages  :   https://github.com/QuickBox/quickbox_packages
# LOCAL REPOS
# Local _ packages   :   /etc/QuickBox/packages
# Author             :   QuickBox.IO | d2dyno
# URL                :   https://quickbox.io
#
# QuickBox Copyright (C) 2017 QuickBox.io
# Licensed under GNU General Public License v3.0 GPL-3 (in short)
#
#   You may copy, distribute and modify the software as long as you track
#   changes/dates in source files. Any modifications to our software
#   including (via compiler) GPL-licensed code must also be made available
#   under the GPL along with build & install instructions.

if [[ -f /tmp/.install.lock ]]; then
  OUTTO="/root/logs/install.log"
elif [[ -f /install/.panel.lock ]]; then
  OUTTO="/srv/panel/db/output.log"
else
  OUTTO="/dev/null"
fi
distribution=$(lsb_release -is)
version=$(lsb_release -cs)
username=$(cat /root/.master.info | cut -d: -f1)
jackettver=$(wget -q https://github.com/Jackett/Jackett/releases/latest -O - | grep -E \/tag\/ | grep -v repository | awk -F "[><]" '{print $3}')
echo >>"${OUTTO}" 2>&1;
echo "Installing Jackett ... " >>"${OUTTO}" 2>&1;

cd /home/$username
wget -q https://github.com/Jackett/Jackett/releases/download/$jackettver/Jackett.Binaries.LinuxAMDx64.tar.gz
tar -xvzf Jackett.Binaries.LinuxAMDx64.tar.gz > /dev/null 2>&1
rm -f Jackett.Binaries.LinuxAMDx64.tar.gz
chown ${username}.${username} -R Jackett

cat > /etc/systemd/system/jackett@.service <<JAK
[Unit]
Description=jackett
After=network.target

[Service]
Type=simple
User=%I
WorkingDirectory=/home/%I/Jackett
ExecStart=/home/%I/Jackett/jackett --NoRestart
Restart=always
RestartSec=2
[Install]
WantedBy=multi-user.target
JAK

systemctl enable jackett@${username} >/dev/null 2>&1
systemctl start jackett@${username}

if [[ -f /install/.nginx.lock ]]; then
  while [ ! -f /home/${username}/.config/Jackett/ServerConfig.json ]
  do
    sleep 2
  done
  bash /usr/local/bin/swizzin/nginx/jackett.sh
  service nginx reload
fi

touch /install/.jackett.lock

echo >>"${OUTTO}" 2>&1;
echo >>"${OUTTO}" 2>&1;
echo "Jackett Install Complete!" >>"${OUTTO}" 2>&1;

echo "Close this dialog box to refresh your browser" >>"${OUTTO}" 2>&1;
