#!/bin/bash

if ! git branch | grep -qw tmp; then
	git branch tmp
fi

git remote update
git reset --hard
git checkout tmp
git branch -D master
git branch master origin/master
git checkout master
