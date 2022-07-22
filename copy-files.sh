#!/bin/sh
cd $( dirname -- "$0"; )
rsync -au .zshrc .oh-my-zsh ~
