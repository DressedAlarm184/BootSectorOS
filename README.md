# BootSectorOS
This is a fully functional x86 real mode operating system that fits into a 512-byte boot sector.

## Features
* Basic shell
* Basic program loader
* 6 commands
* 10 system calls
* BF interpreter

## Build & Run
To build the OS, run `make`.  
To boot the OS using QEMU (`qemu-system-i386`) use `make run`.

## Commands
There are six commands.

They are:
* `help`: Show a list of every command
* `exec`: Execute the user program stored on the fourth sector of the disk
* `halt`: Shutdown via QEMU ACPI shutdown port
* `run`: Run the BF program stored in the 2nd sector
* `clear`: Clear and erase the screen
* `view`: View the contents of the BF program

## System Calls

For NASM, use this macro to make calling the kernel easier:
```asm
%macro kcall 1
call [0x7DEA + (%1 * 2) - 2]
%endmacro
```

There are exactly 10 system calls.  
They are:
1. `puts`: Takes a null terminated string in `si` and prints it.
2. `gets`: No arguments. Reads a 64-byte string from the user into `0x8000`.
3. `cls`: Clear screen. Does not take any arguments.
4. `read_disk`: Read the sector in `cl` (Can address 1 to 63 sectors) into the buffer at `bx`.
5. `streq`: Set the carry flag if the strings at `si` and `di` are equal.
6. `write_disk`: Write to the sector in `cl` the contents of the buffer at `bx`.
7. `shell`: Do not call this. Specifically `jmp` to it. Meant to be used instead of `ret` when needed.
8. `getchar`: Wait for a single key and return scancode in `ah` and ASCII in `al`.
9. `putchar`: Put a single character to the screen in `al`.
10. `sleep`: Sleep for the microsecond count with high word in `cx` and low word in `dx`.

## Memory Map
* `0x7C00`: Kernel entry point
* `0x7DEA`: System call jump table
* `0x7E00`: Active BF program tape buffer
* `0x1000`: Welcome message location
* `0x1400`: User program location (ensure programs contain `[org 0x1400]`)
* `0x8000`: Buffer that `gets` uses

## User Program Example
```asm
[org 0x1400]
[bits 16]

%macro kcall 1
call [0x7DEA + (%1 * 2) - 2]
%endmacro

mov si, hello
kcall 1 ; string ouput
ret

hello db "Hello, World!", 0
```
