You should do it to install gw_switcher
```sudo apt update
sudo apt install git -y
git clone https://github.com/electcliff/gw_swither.git
cp ./gw_swither/gw_switcher.sh /usr/sbin/
chmod +x /usr/sbin/gw_switcher.sh
sudo echo "*/1 *    * * *   root    gw_switcher" >> /etc/crontab
and change script variables