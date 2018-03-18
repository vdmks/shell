#!/bin/bash

DIR=`zenity --file-selection --multiple --title="Select a File"`
	if ! [ -z ${DIR} ]; then
	cd ${DIR};
	convmv -rf utf8 -t iso-8859-1 --notest *; 
	zenity --info --title="OK!" --text="All files successfully converted!";
	fi 
