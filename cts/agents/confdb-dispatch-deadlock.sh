#!/bin/bash

export TIMEOUT=600
export PID=$$
up_to=200

rec_plist() {
    if [ "$2" == "" ];then
	pl="`ps ax -o pid= -o ppid= -o comm=`"
    else
	pl=$2
    fi

    list=`echo "$pl" | egrep "^ *[0-9]+ +$1" | awk '{ print $1 }'`
    tmplist=$list
    for i in $tmplist;do
	[ "$i" != "$1" ] && [ "$i" != "$$" ] && list="$list "`rec_plist $i "$pl"`
    done

    echo $list
}

rec_pkill() {
    kill -9 `rec_plist "$1"` 2> /dev/null
}

exit_timeout() {
    echo "ERR: Timeout. Test failed $PID"
    rec_pkill "$$"
    exit 1
}

corosync-objctl -c test.abd || exit 2

trap exit_timeout SIGUSR1
(sleep $TIMEOUT ; kill -SIGUSR1 $PID) &

wait_list=""

for e in {1..40};do
    (for a in `seq 1 $up_to`;do corosync-objctl -w test.abd=$a ; done) &
    wait_list="$wait_list $!"
done

notify_list=""

for i in {1..2};do
    sleep 600000 | corosync-objctl -t test > /dev/null &
    notify_list="$notify_list $!"
done

wait $wait_list

rec_pkill "$$"

echo "OK"
exit 0
