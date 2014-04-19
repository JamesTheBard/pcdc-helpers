#!/bin/bash

teamname=$1

hostname zeppelin.blue${1}.pcdc
sed "s/blue./blue$teamname/" /etc/postfix/main.cf > /tmp/postfix.cfg
cp -f /tmp/postfix.cfg /etc/postfix/main.cf
rm -f /tmp/postfix.cfg

sed "s/blue./blue$teamname/" /etc/sysconfig/network > /tmp/network.cfg
cp -f /tmp/network.cfg /etc/sysconfig/network
rm -f /tmp/network.cfg
