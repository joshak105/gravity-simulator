A simple physics simulator written directly in NASM x64 assembly. The simulator models rocks falling/settling in a space and counts how many rocks are present, printing the result out via the terminal.

# How It Works


* Written entirely in x64 assembly (ja105.asm) using NASM syntax

* Reads simulation data from file

* Counts and outputs the number of rocks present

# What I Learned


* Writing and structuring a program directly in x64 assembly

* Reading file contents from within assembly code

* Inspecting program output and file contents via the terminal to debug behaviour

Building and Running

Requires NASM and a linker (this was built and tested on Windows).

# Assemble

nasm -f win64 ja105.asm -o ja105.obj
