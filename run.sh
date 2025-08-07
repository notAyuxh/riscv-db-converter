#!/bin/bash
#
# This script runs the whole show for the YAML-to-C-to-YAML challenge.
# It automates the two-round conversion and checks if the output is stable.
#

# This is a good safety measure: if any command fails, the script will stop.
set -e

# --- Configuration ---
LOCAL_YAML_FILE="add.yaml" # The starting point for our journey.
PYTHON_SCRIPT="./yaml_to_c.py"
C_SOURCE="./c_to_yaml.c"

# --- Generated File Names ---
HEADER_FILE="riscv_inst.h"
C_EXECUTABLE="c_to_yaml_converter"
YAML_OUTPUT_1="generated_1.yml"
YAML_OUTPUT_2="generated_2.yml"

# A little helper to make the output look nice and sectioned.
log() {
    echo ""
    echo "=================================================="
    echo "$1"
    echo "=================================================="
}

# This function runs automatically when the script exits, to clean up our mess.
cleanup() {
    log "All done! Cleaning up the temporary files."
    rm -f "$HEADER_FILE" "$C_EXECUTABLE" "$YAML_OUTPUT_1" "$YAML_OUTPUT_2"
    echo "Cleanup complete. Have a great day!"
}

# This 'trap' command ensures the cleanup function is called when the script exits.
# To see the generated files, just comment out this line!
trap cleanup EXIT

# =================================================================
# ROUND 1: Let's convert the original YAML file.
# =================================================================

log "ROUND 1: Starting with the local file: $LOCAL_YAML_FILE"

# Make sure the input file actually exists first.
if [ ! -f "$LOCAL_YAML_FILE" ]; then
    echo "❌ Whoops! The input file '$LOCAL_YAML_FILE' is missing."
    echo "Please make sure it's in the same directory as this script."
    exit 1
fi

# Step 1: Use Python to read the YAML and spit out a C header.
echo "Running Python script to create the C header..."
python3 "$PYTHON_SCRIPT" --file "$LOCAL_YAML_FILE" --output "$HEADER_FILE"

# Step 2: Compile the C program. The C code will include the header we just made.
echo "Compiling the C program..."
gcc "$C_SOURCE" -o "$C_EXECUTABLE"

# Step 3: Run our newly compiled program and save its output to a new YAML file.
echo "Running the C program to create our first YAML file..."
./"$C_EXECUTABLE" > "$YAML_OUTPUT_1"

echo "Round 1 is complete. '$YAML_OUTPUT_1' has been created."


# =================================================================
# ROUND 2: Now, let's see if we can do it again with the generated file.
# =================================================================

log "ROUND 2: Using our own generated YAML as input."

# Step 4: Run the Python script again, but this time on our generated file.
echo "Running Python script on '$YAML_OUTPUT_1'..."
python3 "$PYTHON_SCRIPT" --file "$YAML_OUTPUT_1" --output "$HEADER_FILE"

# Step 5: This is a crucial step! We need to re-compile the C program.
# The instruction data is baked into the executable at compile time,
# so we need to build it again with the new header.
echo "Re-compiling the C program with the new data..."
gcc "$C_SOURCE" -o "$C_EXECUTABLE"

# Step 6: Run the C program one last time to get our final YAML file.
echo "Running the C program to create the final YAML file..."
./"$C_EXECUTABLE" > "$YAML_OUTPUT_2"

echo "Round 2 is complete. '$YAML_OUTPUT_2' has been created."


# =================================================================
# THE MOMENT OF TRUTH: Let's verify the results.
# =================================================================

log "VERIFICATION: Are the two generated files identical?"

# The 'diff' command is perfect for this. The '-q' (quiet) flag tells it
# to just report if files are different, not show the actual differences.
# It will exit with a non-zero status if they don't match, which our 'set -e'
# at the top would catch as an error.
if diff -q "$YAML_OUTPUT_1" "$YAML_OUTPUT_2"; then
    echo ""
    echo "✅ SUCCESS! The files are identical."
    echo "The round-trip was a success. Our data conversion is stable!"
else
    echo ""
    echo "❌ FAILURE! The files are different."
    echo "Something went wrong in the conversion. You can run 'diff $YAML_OUTPUT_1 $YAML_OUTPUT_2' to see the problem."
    exit 1
fi
