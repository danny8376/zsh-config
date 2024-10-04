#!/bin/sh
cd $( dirname -- "$0"; )
list=".zshrc .oh-my-zsh"
for i in $list; do
    if [ -d $i ]; then
        rsync -auK $i/. "$(readlink -f ~/$i)"
    else
        rsync -auK $i "$(readlink -f ~/$i)"
    fi
done
