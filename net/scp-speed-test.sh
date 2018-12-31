#!/bin/bash
# scp-speed-test.sh
# Author: Alec Jacobson alecjacobson AT gmail DOT com
# Changes and fixes by marcocipriani01
#
# Test ssh connection speed by uploading and then downloading a 10000kB file
# Usage:
#  ./scp-speed-test.sh user@hostname [test file size in kBs]

ssh_server="$1"
if [[ -z "$1" ]]; then
    echo "Please add parameter \"user@host\""
fi
test_file="scp-test-file"

test_size="$2"
if [[ -z "$test_size" ]]; then
  test_size="10000"
fi

# Generate a test_size kB file
echo "Generating $test_size kB test file..."
fallocate -l "${test_size}kB" "$test_file"

# Upload test
echo "Testing upload to ${ssh_server}..."
up_speed="$(scp -v $test_file ${ssh_server}:${test_file} 2>&1 | grep "Bytes per second" | sed "s/^[^0-9]*\([0-9.]*\)[^0-9]*\([0-9.]*\).*$/\1/g")"
up_speed="$(echo "(${up_speed}*0.0009765625*100.0+0.5)/1*0.01" | bc)"

# Download test
echo "Testing download from ${ssh_server}..."
down_speed="$(scp -v $s{sh_server}:${test_file} $test_file 2>&1 | grep "Bytes per second" | sed "s/^[^0-9]*\([0-9.]*\)[^0-9]*\([0-9.]*\).*$/\2/g")"
down_speed="$(echo "(${down_speed}*0.0009765625*100.0+0.5)/1*0.01" | bc)"

# Clean up
echo "Removing test file on ${ssh_server}..."
ssh $ssh_server "rm $test_file"
echo "Removing test file locally..."
rm $test_file

# Print result
echo "Upload speed:   $up_speed kB/s"
echo "Download speed: $down_speed kB/s"
