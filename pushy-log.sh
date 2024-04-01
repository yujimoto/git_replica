#!/bin/dash
   
tac .pushy/commit_log | while IFS= read -r commit_log_line; do  
    echo "$commit_log_line"
done
    
