#!/usr/bin/env bash
# Адреса шлюзов
gw1=172.20.48.2
gw2=172.20.48.1   
# Приоритизация шлюзов
fixedgw=''            
#fixedgw='gw1'        # если хотим работать только через этого провайдера deffault: fixedgw='' 
primarygw=gw2         # работает через оба провайдера, но указанный в приоритете
# До каких ip будем проверять связь (нужно 2 разных ip)
checkip1=77.88.8.8
checkip2=77.88.8.1
# За какой период времени в секундах смотреть потери
ping_time=20
# меняем маршруты для 
target="1.1.1.1 2.2.2.2"
#target="deffault"              # если нужно менять маршрут по умолчанию
#target="1.1.1.0./24 2.2.2.2"   # если нужно менять маршруты до нескольких хостов\подсетей 
logfile=/var/log/gw_switcher.log 

### Functions
# check packet loss
check_loss() {
ip route replace $2 via $1
packet_loss=$(ping $2 -w $3 | grep loss | awk '{print $(NF-4)}' | cut -d"%" -f1)
echo $(date +"%d.%m.%Y %H:%M |") $1 has $packet_loss '% packet loss' >> $logfile
echo $packet_loss > /tmp/$1.tmp
}
# set default gateway
set_gw() { 
    default_route=$(ip route |grep $2 |awk '{print $3}')
    if [[ "$default_route" == "$1" ]]; then
        echo $(date +"%d.%m.%Y %H:%M |") current route to $2 via $1, do not change >> $logfile
    else
        ip route replace $2 via $1 >> $logfile
        echo $(date +"%d.%m.%Y %H:%M |") CHANGE ROUTE TO $2 via $1 >> $logfile
    fi
}

# выполняем параллельные пинги через разных провайдеров
check_loss $gw1 $checkip1 $ping_time &
check_loss $gw2 $checkip2 $ping_time &
wait
read </tmp/$gw1.tmp loss1
read </tmp/$gw2.tmp loss2
# cравниваем потери через разных провайдеров
difference=$(($loss1-$loss2))

if [ -z $fixedgw ]; then
    if [[ $difference -ge 5 ]]; then
        for i in $target; do
            set_gw $gw2 $i
            done
    elif [[ $difference -le -5 ]]; then
        for i in $target; do
            set_gw $gw1 $i
            done
    else
        # выставляем приоритетный шлюз
        for i in $target; do
            set_gw ${!primarygw} $i
            done
    fi
else
    # фиксированный шлюз
    for i in $target; do
        set_gw ${!fixedgw} $i
        done
fi