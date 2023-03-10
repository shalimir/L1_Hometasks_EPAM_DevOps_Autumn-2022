#!/bin/bash

#1. When starting without parameters, it will display a list of possible  keys and their description.

arpGrep () {
  echo "$(arp $1 | tail -n 1 | awk '{print $1}')"
}

showSubnetIPnmap () {
  if [[ `/usr/bin/which nmap` ]]
  then 
    subnetip="$(sudo nmap -sP -n $(ip -o address | awk '/scope global/ 
{print $4}' | \
     head -n 1) | awk '/Nmap scan/ {print $5}')"
    for ip in $subnetip
    do
      echo "$ip [$(arpGrep $ip)]"
    done
  else
    echo "To run this script you have to install \"nmap\""
  fi
}

showSubnetIP () {
  ip=`ip -o address | awk '/scope global/ {print $4}' | head -1 | cut 
-d"/" -f1`
  cidr=`ip -o address | awk '/scope global/ {print $4}' | head -1 | cut 
-d"/" -f2`
  hosts=$((2**(32-$cidr)-2))
  netmask=$(ifconfig | grep $ip | awk '{print $4}')
  #M=$(( 0xffffffff ^ ((1 << (32-cidr)) -1) ))
  #netmask="$(( (M>>24) & 0xff )).$(( (M>>16) & 0xff )).$(( (M>>8) & 
0xff )).$(( M & 0xff ))"
  
  echo "ip = $ip"
  echo "cidr = $cidr"
  echo "hosts number = $hosts"
  echo "netmask = $netmask"

}

showPorts () {
  if [[ `/usr/bin/which netstat` ]]
  then
    echo "$(sudo netstat -tlpn | grep LISTEN | awk '{print $1,$4}')"
  else
    echo -e "To run this script you have to install \"netstat\"\n\
In order to do it run on Ubuntu \"sudo apt install net-tools\"\n\
or \"sudo yum install net-tools\" on Centos"
  fi
}


main () {

  MESSAGE="You have to use one parameter:\n
--all - to display IP addresses and symbolic names of all hosts in the 
current subnet\n
--target  - to display a list of open system TCP ports"

  if [[ $# -ne 1 ]]
  then
    echo -e $MESSAGE
  elif [[ $1 == "--all" ]]
  then
    showSubnetIPnmap
  elif [[ $1 == "--target" ]]
  then
    showPorts
  else
    echo -e $MESSAGE
  fi

}


main $1
