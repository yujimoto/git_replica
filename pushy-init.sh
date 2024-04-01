#!/bin/dash
if [ -d .pushy ]; then
    echo 'pushy-init: error: .pushy already exists'
    exit 1
fi
mkdir .pushy
mkdir .pushy/index
touch .pushy/index_info
mkdir .pushy/commits
touch .pushy/commit_log
mkdir .pushy/index_bin
mkdir .pushy/branches
# mkdir .pushy/repo or repo can just be the latest commit file



echo 'Initialized empty pushy repository in .pushy'