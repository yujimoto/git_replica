#!/bin/dash


# 18/3/2024 4:17pm i need to do the --force

if [ "$1" = '--cached' ]; then 
    shift  # Remove the flag from the arguments list
    last_commit_number=$(find .pushy/commits -type d -name 'commit_*' | wc -l)
    last_commit_dir=".pushy/commits/commit_files_$((last_commit_number - 1))"
    # Ensure .pushy/index_bin exists
    for file_name in "$@"; do
        if [ ! -f ".pushy/index/$file_name" ]; then 
            echo "pushy-rm: error: '"$file_name"' is not in the pushy repository"
            exit 1
        fi
        change_detected_repo=0
        change_detected_working_dir=0
        # get the file from the last commit folder
        if [ "$last_commit_number" -gt 0 ]; then
            commit_file=".pushy/commits/commit_files_$((last_commit_number - 1))/$file_name"
            if [ -f "$commit_file" ]; then
                commit_file_hash=$(sha256sum "$commit_file" | cut -d ' ' -f1)
            fi
        fi
        # calculate the hash value of the file from the current working dir
        if [ -f "$file_name" ]; then
            working_dir_file_hash=$(sha256sum "$file_name" | cut -d ' ' -f1)
        fi

        while IFS=' ' read -r index_file_name index_file_hash; do  
            if [ "$file_name" = "$index_file_name" ]; then
                if [ ! -z "$commit_file_hash" ] && [ "$index_file_hash" != "$commit_file_hash" ]; then
                    change_detected_repo=1
                fi
                if [ ! -z "$working_dir_file_hash" ] && [ "$index_file_hash" != "$working_dir_file_hash" ]; then
                    change_detected_working_dir=1
                fi
            fi
        done < .pushy/index_info

        if [ "$change_detected_repo" -eq 1 ] && [ "$change_detected_working_dir" -eq 1 ]; then
            echo "pushy-rm: error: '$file_name' in index is different to both the working file and the repository"
            exit 1
        else
            if  grep -q -s "^$file_name " .pushy/index_info; then
                    sed -i "/^$file_name /d" .pushy/index_info # Use sed to delete the hash from index_info?
            fi
            rm .pushy/index/"$file_name"
            cp "$file_name" .pushy/index_bin/
        fi 
    done
elif [  "$1" = '--force' ] && [ "$2" = '--cached' ]; then
shift 
shift 
    for file_name in "$@"; do
        if  grep -q -s "^$file_name " .pushy/index_info; then
                sed -i "/^$file_name /d" .pushy/index_info # Use sed to delete the hash from index_info?
        fi
        rm .pushy/index/"$file_name"
        cp "$file_name" .pushy/index_bin/
    done
elif [ "$1" = '--force' ]; then
shift 
for file_name in "$@"; do
    if [ ! -f "$last_commit_dir/$file_name" ]; then 
        if [ ! -f ".pushy/index/$file_name" ]; then
            echo "pushy-rm: error: '"$file_name"' is not in the pushy repository"
            exit 1
        fi
    fi
    if  grep -q -s "^$file_name " .pushy/index_info; then
        sed -i "/^$file_name /d" .pushy/index_info # Use sed to delete the hash from index_info?
        fi
        # cp "$file_name" .pushy/index_bin/
        rm "$file_name"
        rm .pushy/index/"$file_name"
    done
else 
    last_commit_number=$(find .pushy/commits -type d -name 'commit_*' | wc -l) 
    last_commit_dir=".pushy/commits/commit_files_$((last_commit_number - 1))"
    for file_name in "$@"; do
        # Check if this file from the last commit has been modified or is missing in the index
        if [ ! -f "$last_commit_dir/$file_name" ]; then 
            if [ -f ".pushy/index/$file_name" ]; then
                echo "pushy-rm: error: '"$file_name"' has staged changes in the index"
                exit 1 
            else
                echo "pushy-rm: error: '"$file_name"' is not in the pushy repository"
                exit 1
            fi
        elif [ -f "$last_commit_dir/$file_name" ]; then 

                #calcualte the hash of files in repo, wd and index
                commit_file_hash=$(sha256sum "$last_commit_dir/$file_name" | cut -d ' ' -f1)
                working_dir_file_hash=$(sha256sum "$file_name" | cut -d ' ' -f1)
                index_file_hash=$(sha256sum ".pushy/index/$file_name" | cut -d ' ' -f1)

                if [ "$index_file_hash" !=  "$commit_file_hash" ] && [ "$index_file_hash" = "$working_dir_file_hash" ]; then
                    echo "pushy-rm: error: '"$file_name"' has staged changes in the index"
                    exit 1 
                elif [ "$index_file_hash" !=  "$working_dir_file_hash" ] && [ "$commit_file_hash" !=  "$index_file_hash" ] ; then
                    echo "pushy-rm: error: '"$file_name"' in index is different to both the working file and the repository"
                    exit 1 
                elif [ "$commit_file_hash" !=  "$working_dir_file_hash" ]; then
                    echo "pushy-rm: error: '"$file_name"' in the repository is different to the working file"
                    exit 1
                else

                    if  grep -q -s "^$file_name " .pushy/index_info; then
                        sed -i "/^$file_name /d" .pushy/index_info # Use sed to delete the hash from index_info?
                    fi
                    cp "$file_name" .pushy/index_bin/
                    rm "$file_name"
                    rm .pushy/index/"$file_name"
            # done   
                fi        
        fi
       
    done
  
fi

