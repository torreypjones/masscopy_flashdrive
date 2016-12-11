#!/bin/bash

#set -x

export SOURCEDIR=""
export DESTDEVICE=""

while getopts ":s:d:" opt; do
  case $opt in
    s)
      echo "-s was triggered, Parameter: $OPTARG" >&2
      export SOURCEDIR=$OPTARG
      echo "set SOURCEDIR=${SOURCEDIR}"
      ;;
    d)
      echo "-d was triggered, Parameter: $OPTARG" >&2
      if [[ "$OPTARG" == "\/*" ]] ; then
	echo "please proide values such as sda or sda or sdc; we do not need the /dev" >&2
	exit 1
      fi
      export DESTDEVICE=$OPTARG
      echo "set DESTDEVICE=${DESTDEVICE}"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

if [ "$SOURCEDIR" = "" ] ; then
	echo "-s is required" >&2
	exit 1
fi

if [ "$DESTDEVICE" = "" ] ; then
	echo "-s is required" >&2
	exit 1
fi


export counter=0
while (true) ; do
	let counter+=1
	export counter
	echo 
	echo
	echo
	echo =========================================================
	echo `date` working on USB device $counter
	echo =========================================================
	echo
	echo
	echo

	#unmount device
	umount $DESTDEVICE > /dev/null 2>&1

	#[root@boiw-cent68 disk]# ll by-uuid/
	#total 0
	#lrwxrwxrwx. 1 root root 10 Dec 11 13:32 39af888a-3086-430e-bb3c-4518620ddfba -> ../../dm-1
	#lrwxrwxrwx. 1 root root  9 Dec 11 13:53 5808-5743 -> ../../sdc
	#lrwxrwxrwx. 1 root root 10 Dec 11 13:32 9ca5c019-5be6-45d3-82d1-b8f6042d31e8 -> ../../dm-0

	tempvariable=$(ls -l /dev/disk/by-uuid | grep $DESTDEVICE)
	label=$(echo $tempvariable | awk '{print $9}')

	mountdir=/mnt/${label}

	if [ ! -e $mountdir ]
	then
		mkdir $mountdir
	fi


	echo mounting $DESTDEVICE under $mountdir
	mount /dev/$DESTDEVICE ${mountdir}


	for i in $SOURCEDIR/* ; do
		echo `date` working on $i
		if [ -e $mountdir/$i ] ; then
			echo     file already exists
		else 
			echo     file does not exist yet, copying...
			#echo "scp -v $SOURCEDIR/$i $mountdir/$i"
			#scp -v $SOURCEDIR/$i $mountdir/$i
			echo "rsync --progress $SOURCEDIR/$i $mountdir/$i"
			rsync --progress $SOURCEDIR/$i $mountdir/$i
		fi
	done

	umount $mountdir
	rmdir $mountdir

	echo 
	echo
	echo
	echo =========================================================
	echo `date` finished with USB device $counter
	echo 
	echo we\'ll wait for you to change drives...
	for i in 1 2 3 4 5 6 7 8 9 10 ; do
		sleep 1
		echo -n .
	done
	echo
	echo when you\'re ready to move on to the next drive, press ENTER
	echo if you\'re finished press CTRL-C
	echo =========================================================
	echo
	echo
	echo
	
	read garbage
done
