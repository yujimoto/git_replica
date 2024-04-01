#! /usr/bin/env dash

# add the current directory to the PATH so scripts
# can still be executed from it after we cd

PATH="$PATH:$(pwd)"

# Create a temporary directory for the test.
test_dir="$(mktemp -d)"
cd "$test_dir" || exit 1

# Create some files to hold output.

expected_output="$(mktemp)"
actual_output="$(mktemp)"

# Remove the temporary directory when the test is done.

trap 'rm "$expected_output" "$actual_output" -rf "$test_dir"' INT HUP QUIT TERM EXIT

# Create pushy repository

cat > "$expected_output" <<EOF
Initialized empty pushy repository in .pushy
EOF

pushy-init > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test"
    exit 1
fi

# Try to intialise a pushy dir again

cat > "$expected_output" <<EOF
pushy-init: error: .pushy already exists
EOF

pushy-init > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test"
    exit 1
fi

# Create a simple file.

echo "line 1" > a

# add the file to the index

cat > "$expected_output" <<EOF
EOF

pushy-add a > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test"
    exit 1
fi

# add a non-existent file to the index 

cat > "$expected_output" <<EOF
pushy-add: error: can not open 'b'
EOF

pushy-add b > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test"
    exit 1
fi

# commit the file to the repository history

cat > "$expected_output" <<EOF
Committed as commit 0
EOF


pushy-commit -m 'first commit' > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test"
    exit 1
fi

# Update the file.

echo "line 2" >> a

# update the file in the repository staging area

cat > "$expected_output" <<EOF
EOF


pushy-add a > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test"
    exit 1
fi

# Update the file.

echo "line 3" >> a

# Check that the file that has been commited hasn't been updated

cat > "$expected_output" <<EOF
line 1
EOF

pushy-show 0:a > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test"
    exit 1
fi

# Check that the file that is in the staging area hasn't been updated

cat > "$expected_output" <<EOF
line 1
line 2
EOF

pushy-show :a > "$actual_output" 2>&1

if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test"
    exit 1
fi

echo "Passed test"
exit 0