#!/bin/sh
#
# For work of this script needed unoconv utility 
#(unoconv is a command line utility that can convert 
#any file format that LibreOffice can import, to any file 
#format that LibreOffice is capable of exporting)


DIR=`zenity --file-selection --directory --title="Select a File"`
	if ! [ -z ${DIR} ]; then
	cd ${DIR}

	echo "Beginning..."; 
	for f in *.html; 
	do
	echo "Convert $f"; 
	unoconv "$f";    
	echo "$f is done!"; 
	done;
	mkdir OUT;
	find -type f -name '*.pdf' -exec mv -vn -t OUT {} \+ 
	zenity --info --title="OK!" --text="All files successfully converted!"
fi 
