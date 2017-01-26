#!/bin/bash

ischroot=0

if [ $ischroot -eq 0 ]
then
	loadkeys ru
	cfdisk
	echo "Done"
fi
