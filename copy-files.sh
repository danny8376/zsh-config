#!/bin/sh
cd $( dirname -- "$0"; )
list=".zshrc .oh-my-zsh"
for i in $list; do
    rsync -auK $i "$(readlink -f ~/$i)"
done
