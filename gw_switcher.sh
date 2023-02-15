#!/usr/bin/env bash
# Адреса шлюзов
gw1=172.20.64.1
gw2=172.20.64.2
# Приоритизация шлюзов
fixedgw=''            
#fixedgw='gw1'        # если хотим работать только через этого провайдера deffault: fixedgw='' 
primarygw=gw1         # работает через оба провайдера, но указанный в приоритете
# До каких ip будем проверять связь (нужно 2 разных ip)
checkip1=8.8.8.8
checkip2=8.8.4.4
# За какой период времени в секундах смотреть потери
ping_time=30

### Functions
# check packet loss
check_loss() {
ip route replace $2 via $1
packet_loss=$(ping $2 -w $3 | grep loss | awk '{print $(NF-4)}' | cut -d"%" -f1)
echo $(date +"%d.%m.%Y %H:%M |") $1 has $packet_loss '% packet loss' >> /var/log/gw_switcher.log
echo $packet_loss > /tmp/$1.tmp
}
# set default gateway
set_gw() { 
    default_route=$(ip route |grep default |awk '{print $3}')
    if [[ "$default_route" == "$1" ]]; then
        echo $(date +"%d.%m.%Y %H:%M |") current deffaut route $1, do not change >> /tmp/gw_switcher.log
    else
        ip route replace default via $1 
        echo $(date +"%d.%m.%Y %H:%M |") CHANGE DEFAULT ROUTE TO $1 >> /tmp/gw_switcher.log
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
        set_gw $gw2 
    elif [[ $difference -le -5 ]]; then
        set_gw $gw1
    else
        # выставляем приоритетный шлюз
        set_gw ${!primarygw}
    fi
else
    # фиксированный шлюз
    set_gw ${!fixedgw}
fi