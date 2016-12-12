#!/bin/bash

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
