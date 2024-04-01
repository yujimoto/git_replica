#!/bin/dash

commit_ver=$(echo "$1" | cut -c1-1)
# echo $commit_ver
# below is to get the file name after the :
filename=$(echo "$1" | cut -d ':' -f2)
# echo "$filename"

if ! echo "$1" | grep -q ':'; then
    echo "pushy-show: error: invalid object $1"
    exit 1
fi

if [ "$commit_ver" = ":" ]; then

    if  [ ! -f .pushy/index/"$filename" ]; then 
        echo "pushy-show: error: '$filename' not found in index"
        exit 1
    fi

    cat .pushy/index/"$filename"
else 
    if [ ! -d .pushy/commits/commit_files_"$commit_ver" ]; then 
        echo "pushy-show: error: unknown commit '$commit_ver'"
        exit 1
    fi
    if  [ ! -f .pushy/commits/commit_files_"$commit_ver"/"$filename" ]; then 
        echo "pushy-show: error: '$filename' not found in commit $commit_ver"
        exit 1
    fi

    cat .pushy/commits/commit_files_"$commit_ver"/"$filename"
fi
