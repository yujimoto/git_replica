#!/bin/dash

check_for_changes() {
    change_detected=0
    last_commit_dir=".pushy/commits/commit_files_$((last_commit_number - 1))"

    # Check for modified files or files missing in the index compared to the last commit
    for commit_file in "$last_commit_dir"/*; do
        if [ "$(basename "$commit_file")" != "commit_info" ]; then
            commit_file_name=$(basename "$commit_file")
            commit_file_hash=$(sha256sum "$commit_file" | cut -d ' ' -f1)

            # Check if this file from the last commit has been modified or is missing in the index
            if ! grep -q "^$commit_file_name $commit_file_hash$" .pushy/index_info; then
                change_detected=1
                break  # No need to check further
            fi
        fi
    done

    # If no changes detected yet, check for new files in the index not present in the last commit
    if [ "$change_detected" -eq 0 ]; then
       while IFS=' ' read -r index_file_name index_file_hash; do
            if [ ! -f "$last_commit_dir/$index_file_name" ]; then
                # This is a new file in the index that was not in the last commit
                change_detected=1
                break
            fi
        done < .pushy/index_info
    fi

    # Additionally, check if any files were in the last commit but are now missing from the index
    if [ "$change_detected" -eq 0 ]; then
        while IFS=' ' read -r index_file_name index_file_hash; do
            if [ ! -f "$last_commit_dir/$index_file_name" ] && [ ! grep -q "^$index_file_name " .pushy/index_info ]; then
                # A file from the last commit is missing in the index
                change_detected=1
                break
            fi
        done < .pushy/index_info
    fi

    if [ "$change_detected" -eq 0 ]; then
        echo "nothing to commit"
        exit 1
    fi
}


last_commit_number=$(find .pushy/commits -type d -name 'commit_*' | wc -l) 

if [ "$1" = '-a' ]; then 
    number_index_files=$(find .pushy/index -type f | wc -l)
    if [ "$number_index_files" -eq 0  ]; then
        echo "nothing to commit"
        exit 1
    fi
    for index_files in .pushy/index/*
    do
        file_name=$(basename "$index_files")
        pushy-add "$file_name"
    done
    if [ "$last_commit_number" -gt 0 ];  then
    check_for_changes
    fi
    commit_desc=$3

else 
    commit_desc=$2
    if [ "$last_commit_number" -gt 0 ];  then
    check_for_changes
    # adding this part 23/3/2024
    else
        number_index_files=$(find .pushy/index -type f | wc -l)
        if [ "$number_index_files" -eq 0  ]; then
            echo "nothing to commit"
            exit 1
        fi
    fi

fi

for bin_files in .pushy/index_bin/*; do 
    if [ -f "$bin_files" ]; then 
        rm ".pushy/index_bin/$(basename "$bin_files")"
    fi
done

commit_dir="./.pushy/commits/commit_files_$last_commit_number"
    mkdir "$commit_dir"
    touch "$commit_dir/commit_info"


    for file_path in .pushy/index/*; do
        file_name=$(basename "$file_path")
        if [ -f ".pushy/index/$file_name" ]; then
            cp "$file_path" "$commit_dir/"
        fi
    done
    echo "$last_commit_number $commit_desc" >> .pushy/commit_log
    echo Committed as commit "$last_commit_number"
    echo "$commit_desc" >> ./.pushy/commits/commit_files_"$last_commit_number"/commit_info