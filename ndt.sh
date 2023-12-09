#!/bin/bash
# ===================================================================
#
#  NDT / Nat Direct Tools is a simple bash script
#  designed to automatically manage the NAT system in Proxmox & Virtualizor.
#  This script facilitates the addition of port forwarding and IP limitations
#  for VMs and Containers.
#
#  This Project licensed under MIT
#  URL: https://github.com/wildy3128/ndt/blob/main/LICENSE
#
# -------------------------------------------------------------------
#
#  Author  : Wildy3128 <hai@wildy.one>
#  Version : 1.0.0
#  Date    : 30-10-2023
#  Release : Stable
#
# ===================================================================

function add_nat() {
    echo "1). Single Port"
    echo "2). Range Port"
    read -p "Select [1-2]: " chs
    if [[ $chs == "1" ]]; then
        clear

        read -p "Port to assign    : " aports
        if ! [[ $aports =~ ^[0-9]+$ ]] || [[ $aports -lt 1 ]] || [[ $aports -gt 65535 ]]; then
            echo "Invalid port. Please enter a valid port number between 1 and 65535."
            exit 1
        fi

        read -p "Destination       : " dsts
        if ! [[ $dsts =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+(:[0-9]+)?$ ]]; then
            echo "Invalid destination. Please enter a valid destination in the format 'ip:port' or 'ip'."
            exit 1
        fi

        read -p "IP Public         : " publics
        if ! [[ $publics =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            echo "Invalid public IP. Please enter a valid public IP address."
            exit 1
        fi

        read -p "Interfaces        : " intfs
        if ! [[ $intfs ]]; then
            echo "Invalid Interfaces. Please enter a valid interfaces"
            exit 1
        fi

        read -p "Protocol t/u/tu   : " tupros
        if [[ $tupros == "t" ]]; then
            proc="tcp"
        elif [[ $tupros == "u" ]]; then
            proc="udp"
        elif [[ $tupros == "tu" ]]; then
            proc="tcp,udp"
        else
            echo "Invalid Protocol, please input tcp[t], udp[u], both[tu]"
            exit 1
        fi
    
        if [[ $proc == "tcp,udp" ]]; then
            echo -e $"\n\nExec: iptables -t nat -A PREROUTING -p tcp -d $publics --dport $aports -i $intfs -j DNAT --to-destination $dsts"
            echo -e $"\n\nExec: iptables -t nat -A PREROUTING -p udp -d $publics --dport $aports -i $intfs -j DNAT --to-destination $dsts"
            iptables -t nat -A PREROUTING -p tcp -d $publics --dport $aports -i $intfs -j DNAT --to-destination $dsts
            iptables -t nat -A PREROUTING -p udp -d $publics --dport $aports -i $intfs -j DNAT --to-destination $dsts
            echo "Done iptables created !"
        else
            echo -e $"\n\nExec: iptables -t nat -A PREROUTING -p $proc -d $publics --dport $aports -i $intfs -j DNAT --to-destination $dsts"
            iptables -t nat -A PREROUTING -p $proc -d $publics --dport $aports -i $intfs -j DNAT --to-destination $dsts
            echo "Done iptables created !"
        fi

        echo -e $"\nPress [ENTER] to back"
        read && main

    elif [[ $chs == "2" ]]; then
        clear

        read -p "Port start        : " sports
        if ! [[ $sports =~ ^[0-9]+$ ]] || [[ $sports -lt 1 ]] || [[ $sports -gt 65535 ]]; then
            echo "Invalid port. Please enter a valid port number between 1 and 65535."
            exit 1
        fi

        read -p "Port End          : " eports
        if ! [[ $eports =~ ^[0-9]+$ ]] || [[ $eports -lt 1 ]] || [[ $eports -gt 65535 ]]; then
            echo "Invalid port. Please enter a valid port number between 1 and 65535."
            exit 1
        fi

        read -p "Destination       : " dsts
        if ! [[ $dsts =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+(:[0-9]+)?$ ]]; then
            echo "Invalid destination. Please enter a valid destination in the format 'ip:port' or 'ip'."
            exit 1
        fi

        read -p "IP Public         : " publics
        if ! [[ $publics =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            echo "Invalid public IP. Please enter a valid public IP address."
            exit 1
        fi

        read -p "Interfaces        : " intfs
        if ! [[ $intfs ]]; then
            echo "Invalid Interfaces. Please enter a valid interfaces"
            exit 1
        fi

        read -p "Protocol t/u/tu   : " tupros
        if [[ $tupros == "t" ]]; then
            proc="tcp"
        elif [[ $tupros == "u" ]]; then
            proc="udp"
        elif [[ $tupros == "tu" ]]; then
            proc="tcp,udp"
        else
            echo "Invalid Protocol, please input tcp[t], udp[u], both[tu]"
            exit 1
        fi

        if [[ $proc == "tcp,udp" ]]; then
            echo -e $"\n\nExec: iptables -t nat -A PREROUTING -p tcp -d $publics --dport $sports:$eports -i $intfs -j DNAT --to-destination $dsts"
            echo -e $"\n\nExec: iptables -t nat -A PREROUTING -p udp -d $publics --dport $sports:$eports -i $intfs -j DNAT --to-destination $dsts"
            iptables -t nat -A PREROUTING -p tcp -d $publics --dport $sports:$eports -i $intfs -j DNAT --to-destination $dsts
            iptables -t nat -A PREROUTING -p udp -d $publics --dport $sports:$eports -i $intfs -j DNAT --to-destination $dsts
            echo "Done iptables created !"
        else
            echo -e $"\n\nExec: iptables -t nat -A PREROUTING -p $proc -d $publics --dport $sports:$eports -i $intfs -j DNAT --to-destination $dsts"
            iptables -t nat -A PREROUTING -p $proc -d $publics --dport $sports:$eports -i $intfs -j DNAT --to-destination $dsts
            echo "Done iptables created !"
        fi

        echo -e $"\nPress [ENTER] to back"
        read && main
    else
        echo "Invalid options"
        sleep 2 && main
    fi
}

function del_nat() {
    totalline=$(iptables -t nat -L PREROUTING | tail -n +3 | wc -l)
    echo "No   Protocol   Port         Destination"

    for ((i=1; i <= $totalline; i++)); do
        exected=$(iptables -t nat -L PREROUTING | tail -n +3 | sed -n ${i}p)
        protocol=$(echo $exected | awk '{print $2}')
        port=$(echo $exected | awk '{print $7}' | sed 's/dpt://g' | sed 's/dpts://g')
        dest=$(echo $exected | awk '{print $8}' | sed 's/to://g')

        printf "%-4s %-10s %-12s %-25s\n" "$i" "$protocol" "$port" "$dest"
    done

    read -p "Which line [1-$totalline] want to delete ? " whichline
    if [[ $whichline == "" ]]; then
	echo "Please choose an options and try again."
        exit 1
    fi

    iptables -t nat -D PREROUTING $whichline > /dev/null 2>&1
    echo "Lines $whichline has been deleted"
    
    echo -e $"\nPress [ENTER] to back"
    read && main
}

function list_nat() {
    clear
    totalline=$(iptables -t nat -L PREROUTING | tail -n +3 | wc -l)
    echo "No   Protocol   Port         Destination"

    for ((i=1; i <= $totalline; i++)); do
        exected=$(iptables -t nat -L PREROUTING | tail -n +3 | sed -n ${i}p)
        protocol=$(echo $exected | awk '{print $2}')
        port=$(echo $exected | awk '{print $7}' | sed 's/dpt://g' | sed 's/dpts://g')
        dest=$(echo $exected | awk '{print $8}' | sed 's/to://g')

        printf "%-4s %-10s %-12s %-25s\n" "$i" "$protocol" "$port" "$dest"
    done
    echo -e $"\nPress [ENTER] to back"
    read && main
}

function add_limit() {
    echo "1). IPv4"
    echo "2). IPv6"
    read -p "Select [1-2]: " slc
    if [[ $slc == "1" ]]; then
        clear
        read -p "MAC Address   : " macs
        if ! [[ $macs ]]; then
            echo "Input value for mac address and try again !"
            exit 1
        fi

        read -p "Source IP     : " srcip
        if ! [[ $srcip ]]; then
            echo "Input value for sourceip and try again !"
            exit 1
        fi

        echo "Exec: ebtables -A INPUT -s $macs -p IPv4 --ip-src ! $srcip -j DROP"
        ebtables -A INPUT -s $macs -p IPv4 --ip-src ! $srcip -j DROP
        echo "new ebtables rules created" && sleep 2

    elif [[ $slc == "2" ]]; then
        clear
        read -p "MAC Address   : " mac
        if ! [[ $macs ]]; then
            echo "Input value for mac address and try again !"
            exit 1
        fi

        read -p "Source IP     : " srcip
        if ! [[ $srcip ]]; then
            echo "Input value for sourceip and try again !"
            exit 1
        fi

        echo "Exec: ebtables -A INPUT -s $macs -p IPv6 --ip6-src ! $srcip -j DROP"
        ebtables -A INPUT -s $macs -p IPv6 --ip6-src ! $srcip -j DROP
        echo "new ebtables rules created" && sleep 2

    else
        echo "Invalid options !"
        sleep 2 && main
    fi

    echo -e $"\nPress [ENTER] to back"
    read && main
}

function list_nat() {
    clear
    totalline=$(iptables -t nat -L PREROUTING | tail -n +3 | wc -l)
    echo "No   Protocol   Port         Destination"

    for ((i=1; i <= $totalline; i++)); do
        exected=$(iptables -t nat -L PREROUTING | tail -n +3 | sed -n ${i}p)
        protocol=$(echo $exected | awk '{print $2}')
        port=$(echo $exected | awk '{print $7}' | sed 's/dpt://g' | sed 's/dpts://g')
        dest=$(echo $exected | awk '{print $8}' | sed 's/to://g')

        printf "%-4s %-10s %-12s %-25s\n" "$i" "$protocol" "$port" "$dest"
    done
    echo -e $"\nPress [ENTER] to back"
    read && main
}

function list_limit() {
    clear
    totalline=$(ebtables -t filter -L INPUT | tail -n +4 | wc -l)
    echo "No   Type       Mac                  Source IP"

    for ((i=1; i <= $totalline; i++)); do
        exected=$(ebtables -L INPUT | tail -n +4 | sed -n ${i}p)
        type=$(echo $exected | awk '{print $2}')
        mac=$(echo $exected | awk '{print $4}')
        srcip=$(echo $exected | awk '{print $7}')

        printf "%-4s %-10s %-20s %-25s\n" "$i" "$type" "$mac" "$srcip"
    done

    echo -e $"\nPress [ENTER] to back"
    read && main
}

function del_limit() {
    totalline=$(ebtables -t filter -L INPUT | tail -n +4 | wc -l)
    echo "No   Type       Mac                  Source IP"

    for ((i=1; i <= $totalline; i++)); do
        exected=$(ebtables -L INPUT | tail -n +4 | sed -n ${i}p)
        type=$(echo $exected | awk '{print $2}')
        mac=$(echo $exected | awk '{print $4}')
        srcip=$(echo $exected | awk '{print $7}')

        printf "%-4s %-10s %-20s %-25s\n" "$i" "$type" "$mac" "$srcip"
    done

    read -p "Which line [1-$totalline] want to delete ? " whichline
    if [[ $whichline == "" ]]; then
	echo "Please choose an options and try again."
        exit 1
    fi

    ebtables -D INPUT $whichline > /dev/null 2>&1
    echo "Lines $whichline has been deleted"
    
    echo -e $"\nPress [ENTER] to back"
    read && main
}

function main() {
    clear
    echo "===================================================================="
    echo " NDT / Nat Direct Tools is a simple bash script"
    echo " designed to automatically manage the NAT system in Proxmox & Virtualizor."
    echo " With this script, you can add port forwarding and IP limitations"
    echo " for VMs and Containers."
    echo "===================================================================="
    echo " Author  : Wildy3128 <hai@wildy.one>"
    echo " Date    : 30-10-2023"
    echo " Version : 1.0.0"
    echo " Release : Stable"
    echo " License : https://github.com/wildy3128/ndt/blob/main/LICENSE"
    echo "===================================================================="
    echo ""
    echo " 1). Add new nat rules"
    echo " 2). Delete exist nat rules"
    echo " 3). List exists nat rules"
    echo " 4). Add limitation ebtables rules"
    echo " 5). List limiation ebtables rules"
    echo " 6). Delete limitation ebtables rules"
    echo " 7). Exit"
    echo ""
    echo "===================================================================="
    echo ""
    read -p "Select [1-7]: " select
    if [[ $select == "1" ]]; then
        clear && add_nat
    elif [[ $select == "2" ]]; then
        clear && del_nat
    elif [[ $select == "3" ]]; then
        clear && list_nat
    elif [[ $select == "4" ]]; then
        clear && add_limit
    elif [[ $select == "5" ]]; then
        clear && list_limit
    elif [[ $select == "6" ]]; then
        clear && del_limit
    else
        echo "Existed." && exit
    fi
}

main
