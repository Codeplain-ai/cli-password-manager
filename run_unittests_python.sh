#!/bin/bash

UNRECOVERABLE_ERROR_EXIT_CODE=69

# Check if subfolder name is provided
if [ -z "$1" ]; then
  echo "Error: No subfolder name provided."
  echo "Usage: $0 <subfolder_name>"
  exit $UNRECOVERABLE_ERROR_EXIT_CODE
fi

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

  mkdir $PYTHON_BUILD_SUBFOLDER
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
python3.12 -m venv .venv
source .venv/bin/activate

# Install requirements if requirements.txt exists
if [ -f "requirements.txt" ]; then
    pip install -r requirements.txt
else
    echo "Error: requirements.txt not found. Cannot proceed with setup."
    deactivate
    rm -rf .venv
    exit 4
fi

end_time=$(date +%s.%N)

# Calculate and display the time taken
duration=$(echo "$end_time - $start_time" | bc)
printf "Virtual environment created and activated in %.2f seconds\n\n" "$duration"


# Execute all Python unittests in the subfolder
echo "Running Python unittests in $PYTHON_BUILD_SUBFOLDER..."

output=$(timeout 120s python -m unittest discover -b -v 2>&1)
exit_code=$?

# Check if the command timed out
if [ $exit_code -eq 124 ]; then
    printf "\nError: Unittests timed out after 120 seconds.\n"
    exit $exit_code
fi

# Echo the original output
echo "$output"

# Return the exit code of the unittest command
exit $exit_code

# Note: The 'discover' option automatically identifies and runs all unittests in the current directory and subdirectories
# Ensure that your Python files are named according to the unittest discovery pattern (test*.py by default)
