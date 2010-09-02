#!/usr/bin/zsh
for file in app/locales/**/*.php
do
    git update-index --assume-unchanged $file
done

for file in config/locales/**/*.php
do
    git update-index --assume-unchanged $file
done
