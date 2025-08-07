# RISC-V YAML to C Round-Trip Converter

This project is a solution to a coding challenge that involves converting RISC-V instruction data from a YAML format to a C header file and back, verifying that the conversion is lossless.

## Project Overview

The process works in two main rounds:

1.  **Round 1:** A Python script (`yaml_to_c.py`) reads an instruction set from a source YAML file (e.g., `add.yaml`) and generates a C header file (`riscv_inst.h`) containing the data in a C struct. A C program (`c_to_yaml.c`) is then compiled with this header and executed to generate a new, standardized YAML file (`generated_1.yml`).

2.  **Round 2:** The process is repeated, but this time the Python script uses `generated_1.yml` as its input. It produces a final YAML file, `generated_2.yml`.

The final step is to verify that `generated_1.yml` and `generated_2.yml` are identical, which proves the data conversion process is stable.

## Files in this Repository

* `yaml_to_c.py`: The Python script responsible for parsing a YAML file and generating the C header.
* `c_to_yaml.c`: The C program that reads the data from the generated header and prints it to standard output in YAML format.
* `run.sh`: An executable shell script that automates the entire two-round process, including compilation and verification.
* `add.yaml`: An example input YAML file from the RISC-V Unified Database.

## Prerequisites

To run this project, you will need the following installed:

* **Python 3**
* **PyYAML** library for Python (`pip install pyyaml`)
* **GCC** (GNU Compiler Collection) or a compatible C compiler 

## How to Run

1.  Clone this repository:
    ```bash
    git clone https://github.com/notAyuxh/riscv-db-converter.git
    cd riscv-db-converter
    ```

2.  Make the execution script runnable:
    ```bash
    chmod +x run.sh
    ```

3.  Execute the script:
    ```bash
    ./run.sh
    ```

The script will perform all the steps and print a `✅ SUCCESS` message if the round-trip conversion was successful.

**Note:** To inspect the intermediate files (`generated_1.yml`, `generated_2.yml`, `riscv_inst.h`) manually, comment out the `trap cleanup EXIT` line in `run.sh` before running it.
