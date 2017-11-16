#!/bin/bash  
echo "Press 1. You want to Install LEMP"
echo "Press 2. Add vhost"
read a
if [ "$a" = 1 ]
then 
./lempsetup.sh
fi
if [ "$a" = 2 ]
then
./add-vhost-phpmyadmin.sh
fi
