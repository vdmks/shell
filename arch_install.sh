#!/bin/bash

ischroot=0

if [ $ischroot -eq 0 ]
then
	loadkeys ru
	(echo o; echo n; echo p; echo 1; echo 200; echo w) | fdisk /dev/sdc
	(echo o; echo n; echo 4000; echo w) | fdisk /dev/sdc
	(echo o; echo n; echo 3000; echo w) | fdisk /dev/sdc
	echo "Done"
fi