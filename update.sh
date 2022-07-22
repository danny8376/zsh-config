#!/bin/sh
cd $( dirname -- "$0"; )
git pull
./copy-files.sh
