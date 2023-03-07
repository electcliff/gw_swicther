Данный скрипт переключает маршруты, взависимости от потерь на этих маршрутах.
Пример использования переключение провайдеров на шлюзе
Установка:

**Как systemd сервис**
```
sudo apt install unzip -y
wget https://github.com/electcliff/gw_swither/archive/refs/heads/main.zip
unsip main.zip
cd gw_swither-main
./install.sh
Вносим нужные изменения в /etc/gw-switcher.conf
systemctl start gw-switcher
systemctl enable gw-switcher
```
**Как скрипт**
```
wget https://github.com/electcliff/gw_swither/blob/16b651f395b32a94a9d864514f11fc0cbc9f59e7/gw_switcher.sh
cp ./gw_switcher.sh /usr/sbin/
вносим измененя в переменные /usr/sbin/gw_switcher.sh
добавляем в крон периодическое выполнение скрипта
sudo echo "*/1 *    * * *   root    gw_switcher" >> /etc/crontab
```