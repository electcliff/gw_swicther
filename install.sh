sudo cp ./gw-switcher /usr/bin/gw-switcher
sudo cp ./gw-switcher.config.sample /etc/gw-switcher.config
sudo cat << EOF > /etc/systemd/system/gw-switcher.cervice
[Unit]
Description=Check channels and get better
After=network.target

[Service]
ExecStart=/usr/bin/gw-switcher
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
sudo cat << EOF > /etc/logrotate.d/gw_switcher
/var/log/gw_switcher.log  {
    size 20000k
    missingok
    rotate 24
    compress
    create
}
EOF
sudo systemctl daemon-reload