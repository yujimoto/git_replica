#!/bin/dash

if [ ! -d ".pushy" ]
then
echo 'pushy-add: error: pushy repository directory .pushy not found'
exit 1
fi

for file_name in "$@"; do
    if [ -f "$file_name" ]; then
        # Generate a hash of the file's content
        hash=$(sha256sum "$file_name" | cut -d ' ' -f1)
        cp "$file_name" .pushy/index
        # Check if the file is already tracked and update or append as necessary
        # Check if the file is already in index_info
        if grep -q -s "^$file_name " .pushy/index_info; then
            # File is in index_info, update its hash using sed
            sed -i "s/^$file_name .*/$file_name $hash/" .pushy/index_info
        else
            # File not in index_info, append it
            echo "$file_name $hash" >> .pushy/index_info
        fi
        # echo "$file_name $hash" >> .pushy/index_info
    else 
    # Check if deleted file is in the last commit or the current index then update the index by deleting the file from index?
    # Then i can commit with the file deleted
    last_commit_number=$(find .pushy/commits -type d -name 'commit_*' | wc -l)
    if [ "$last_commit_number" -gt 0 ]; then
            commit_file=".pushy/commits/commit_files_$((last_commit_number - 1))/$file_name"  
            if [ -f "$commit_file" ]; then
                rm  ".pushy/index/$file_name"
                if  grep -q -s "^$file_name " .pushy/index_info; then
                    sed -i "/^$file_name /d" .pushy/index_info # Use sed to delete the hash from index_info?
                fi
            else 
                echo "pushy-add: error: can not open '$@'"
                exit 1
            fi
        
    else 
        echo "pushy-add: error: can not open '$@'"
        exit 1
    fi
    fi
    
done
