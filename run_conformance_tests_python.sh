#!/bin/bash

UNRECOVERABLE_ERROR_EXIT_CODE=69

# Check if build folder name is provided
if [ -z "$1" ]; then
  printf "Error: No build folder name provided.\n"
  printf "Usage: $0 <build_folder_name> <conformance_tests_folder>\n"
  exit $UNRECOVERABLE_ERROR_EXIT_CODE
fi

# Check if conformance tests folder name is provided
if [ -z "$2" ]; then
  printf "Error: No conformance tests folder name provided.\n"
  printf "Usage: $0 <build_folder_name> <conformance_tests_folder>\n"
  exit $UNRECOVERABLE_ERROR_EXIT_CODE
fi

current_dir=$(pwd)
echo "Current directory: $current_dir"
echo "Build folder name: $1"
echo "Conformance tests folder name: $2"
echo "--------------------------------"

PYTHON_BUILD_SUBFOLDER=python_$1

if [ "${VERBOSE:-}" -eq 1 ] 2>/dev/null; then
  printf "Preparing Python build subfolder: $PYTHON_BUILD_SUBFOLDER\n"
fi

# Check if the Python build subfolder exists
if [ -d "$PYTHON_BUILD_SUBFOLDER" ]; then
  # Find and delete all files and folders
  find "$PYTHON_BUILD_SUBFOLDER" -mindepth 1 -exec rm -rf {} +

  if [ "${VERBOSE:-}" -eq 1 ] 2>/dev/null; then
    printf "Cleanup completed.\n"
  fi
else
  if [ "${VERBOSE:-}" -eq 1 ] 2>/dev/null; then
    printf "Subfolder does not exist. Creating it...\n"
  fi

  mkdir -p $PYTHON_BUILD_SUBFOLDER
fi

cp -R $1/* $PYTHON_BUILD_SUBFOLDER

# Move to the subfolder
cd "$PYTHON_BUILD_SUBFOLDER" 2>/dev/null

if [ $? -ne 0 ]; then
  printf "Error: Python build folder '$PYTHON_BUILD_SUBFOLDER' does not exist.\n"
  exit $UNRECOVERABLE_ERROR_EXIT_CODE
fi

printf "Creating and activating virtual environment...\n"

# Time the virtual environment creation and activation
start_time=$(date +%s.%N)

# Install requirements if requirements.txt exists
if [ -f "requirements.txt" ]; then
    pip install -r requirements.txt
else
    echo "Warning: requirements.txt not found. Cannot proceed with setting up requirements. The requirements may also already be installed"
fi

end_time=$(date +%s.%N)

# Calculate and display the time taken
duration=$(echo "$end_time - $start_time" | bc)
printf "Requirements setup completed in %.2f seconds\n\n" "$duration"

# Execute all Python conformance tests in the build folder
printf "Running Python conformance tests in the conformance tests folder...\n\n"

output=$(python -m unittest discover -b -s "$current_dir/$2" 2>&1)
exit_code=$?

# Echo the original output
echo "$output"

# Check if no tests were discovered
if echo "$output" | grep -q "Ran 0 tests in"; then
    printf "\nError: No unittests discovered.\n"
    exit 1
fi

# Echo the original exit code of the unittest command
exit $exit_code