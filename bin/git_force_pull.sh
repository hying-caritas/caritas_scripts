#!/bin/sh

if ! git branch | grep -qw tmp; then
	git branch tmp
fi

git_current_branch()
{
	git branch | grep '^\* ' | cut -d ' ' -f 2-
}

current_branch=$(git_current_branch)
git remote update
git reset --hard
git checkout tmp
git branch -D $current_branch
git branch $current_branch origin/master
git checkout $current_branch
