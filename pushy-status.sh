#!/bin/dash
# 19/3/2024 5:18pm i need to change my format/order of code to match the order of output 
last_commit_number=$(find .pushy/commits -type d -name 'commit_*' | wc -l)
last_commit_dir=".pushy/commits/commit_files_$((last_commit_number - 1))"
called_check_changes=0
check_for_changes() {
    # check if file is delted using just rm 
    while IFS=' ' read -r index_file_name index_file_hash; do
        if [ ! -f "$index_file_name" ] && [ -f  "$last_commit_dir/$index_file_name" ] ; then
            # File does not exist in the working directory, but is tracked
            echo "$index_file_name - file deleted"
        fi
    done < .pushy/index_info
    # checking if file id deleted from index as well as wd
    for index_bin_file in .pushy/index_bin/*; do
        # echo "$index_bin_file"
        # if the file indside the index_bin doesnt exist in the current working direcotry then echo
        if [ ! -f "$(basename "$index_bin_file")" ] && [ "$index_bin_file" != ".pushy/index_bin/*" ]; then
            echo ""$(basename "$index_bin_file")" - file deleted, deleted from index"
        fi
    done
}
for file in *; do 

# First check if only deleted from index??
if [ ! -f ".pushy/index/$file" ] && [ -f "$file" ]; then
    if [ -f ".pushy/index_bin/$file" ] && [ -f "$last_commit_dir/$file" ]; then
        echo ""$file" - deleted from index"
    fi
    # check if file is not tracked. i.e not in the repo/last commit and not in index nor index bin 
    if [ ! -f "$last_commit_dir/$file" ]; then
        if [ "$called_check_changes" -ne 1 ]; then
                    check_for_changes
                    called_check_changes=1
        fi 
        echo ""$file" - untracked"
    fi
   
elif [ -f "$file" ] && [ -f ".pushy/index/$file" ]; then
    hash=$(sha256sum "$file" | cut -d ' ' -f1)
    if [ -f  "$last_commit_dir/$file" ]; then 
        commit_hash=$(sha256sum "$last_commit_dir/$file" | cut -d ' ' -f1)
        while IFS=' ' read -r index_file_name index_file_hash; do
        if [ "$index_file_name" = "$file" ]; then
            if [ "$hash" != "$index_file_hash" ] && [ "$index_file_hash" != "$commit_hash" ]; then
                echo ""$file" - file changed, different changes staged for commit"
            elif [ "$hash" != "$index_file_hash" ]; then
                echo ""$file" - file changed, changes not staged for commit"
            elif [ "$hash" = "$index_file_hash" ] && [ "$hash" != "$commit_hash" ]; then
                echo  ""$file" - file changed, changes staged for commit " 
            elif [ "$index_file_hash" = "$commit_hash" ]; then
                if [ "$called_check_changes" -ne 1 ]; then
                    check_for_changes
                    called_check_changes=1
                fi
                echo  ""$file" - same as repo"
            fi
        fi
        done < .pushy/index_info
    elif [ ! -f  "$last_commit_dir/$file" ]; then 
        if [ "$called_check_changes" -ne 1 ]; then
                    check_for_changes
                    called_check_changes=1
        fi
        hash=$(sha256sum "$file" | cut -d ' ' -f1)
        while IFS=' ' read -r index_file_name index_file_hash; do
            if [ "$index_file_name" = "$file" ]; then
                if [ "$hash" != "$index_file_hash" ]; then
                    echo ""$file" - added to index, file changed"
                else 
                 echo ""$file" - added to index"
                fi
            elif [ ! -f "$index_file_name" ] && [ ! -f  "$last_commit_dir/$index_file_name" ]; then
                # File does not exist in the working directory, but is tracked
                echo "$index_file_name - added to index, file deleted"     
            fi
        done < .pushy/index_info
        # echo ""$file" - added to index"
    fi
    
fi
done
if [ "$called_check_changes" -ne 1 ]; then
    check_for_changes
    called_check_changes=1
fi



