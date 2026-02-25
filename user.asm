[org 0x1400]
[bits 16]

%macro kcall 1
call [0x7DEA + (%1 * 2) - 2]
%endmacro

mov si, hello
kcall 1 ; string ouput
ret

hello db "Hello, World!", 0
