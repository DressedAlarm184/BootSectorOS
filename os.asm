[org 0x7C00]
[bits 16]

; DressedAlarm184 Boot Sector OS
; ------------------------------

; Operating System Sector

xor ax, ax
mov ds, ax
mov es, ax
mov ss, ax
mov sp, 0x7000

mov bx, 0x7E00
mov cl, 2
call read_disk

mov bx, 0x1000
mov cl, 3
call read_disk

mov bx, 0x1400
mov cl, 4
call read_disk

call cls
mov si, 0x1000
call puts

shell:
	mov si, prompt
	call puts
	call gets
	call cmd
	jmp shell


cmd:
	mov si, 0x8000
	mov di, halt
	call streq
	jc cmd_halt
	mov di, clear
	call streq
	jc cmd_clear
	mov di, run
	call streq
	jc cmd_run
	mov di, view
	call streq
	jc cmd_view
	mov di, help
	call streq
	jc cmd_help
	mov di, exec
	call streq
	jc cmd_exec
	mov si, notfound
	call puts
	ret


read_disk:
	xor ch, ch
	mov dx, 0x0080
	mov ax, 0x0201
	int 0x13

write_disk:
	xor ch, ch
	mov dx, 0x0080
	mov ax, 0x0301
	int 0x13	


streq:
	push si
.loop:
    cmpsb
    jne .not_equal
    cmp byte [si-1], 0
    jnz .loop
.equal:
	stc
    jmp .done
.not_equal:
    clc
.done:
	pop si
    ret


cls:
	mov ax, 0x0003
	int 0x10
	ret


puts:
	mov ah, 0x0E
.loop:
	lodsb
	test al, al
	jz .done 
	int 0x10
	jmp .loop
.done:
	ret


gets:
	mov bx, 0x8000
.start:
	xor ah, ah
	int 0x16
	cmp al, 13
	je .done
	cmp al, 8
	je .bksp
	cmp bx, 0x8040
	je .start
	mov [bx], al
	inc bx
	mov ah, 0x0E
	int 0x10
	jmp .start
.done:
	mov byte [bx], 0
	mov si, newline
	call puts
	ret
.bksp:
	cmp bx, 0x8000
	jbe .start
	mov si, bksp
	call puts
	dec bx
	mov byte [bx], 0
	jmp .start


cmd_halt:
    mov dx, 0x604
    mov ax, 0x2000
    out dx, ax
    cli
    hlt


cmd_clear:
	call cls
	jmp shell

	
cmd_view:
	mov si, 0x7E00
	call puts
	jmp shell

	
cmd_run:
    mov di, 0x8100
    push di
    mov ch, 0x3A
    xor ax, ax
    rep stosw
    pop di
    mov si, 0x7E00
.fetch:
    lodsb
    test al, al
    jz shell
    cmp al, '+'
    jne .chk_minus
    inc byte [di]
    jmp .fetch
.chk_minus:
    cmp al, '-'
    jne .chk_right
    dec byte [di]
    jmp .fetch
.chk_right:
    cmp al, '>'
    jne .chk_left
    inc di
    jmp .fetch
.chk_left:
    cmp al, '<'
    jne .chk_dot
    dec di
    jmp .fetch
.chk_dot:
    cmp al, '.'
    jne .chk_comma
    mov al, [di]
.print:
    mov ah, 0x0E
    int 0x10
    jmp .fetch
.chk_comma:
    cmp al, ','
    jne .chk_open
    xor ah, ah
    int 0x16            
    mov [di], al
    jmp .print
.chk_open:
    cmp al, '['
    jne .chk_close
    cmp byte [di], 0
    jnz .fetch
    mov cx, 1
.scan_fwd:
    lodsb
    cmp al, '['
    jne .f1
    inc cx
.f1:
    cmp al, ']'
    jne .scan_fwd
    loop .scan_fwd
    jmp .fetch
.chk_close:
    cmp al, ']'
    jne .fetch
    cmp byte [di], 0
    jz .fetch
    mov cx, 1
    dec si
    dec si
.scan_back:
    dec si
    mov al, [si]
    cmp al, ']'
    jne .b1
    inc cx
.b1:
    cmp al, '['
    jne .scan_back
    loop .scan_back 
    inc si
    jmp .fetch


cmd_help:
	mov cx, 6
	mov si, halt
.loop:
	call puts
	push si
	mov si, spacer
	call puts
	pop si
	loop .loop
.done:
	jmp shell


cmd_exec:
	call 0x1400
	jmp shell


getchar:
	xor ax, ax
	int 0x16
	ret

putchar:
	mov ah, 0x0E
	xor bx, bx
	int 0x10
	ret

sleep:
	mov ah, 0x86
	int 0x15
	ret


prompt:   db 13, 10, "> ", 0
bksp:     db 8, 32, 8, 0
notfound: db "?", 0
newline:  db 13, 10, 0
halt:     db "halt", 0
clear:    db "clear", 0
run:      db "run", 0
view:     db "view", 0
help:     db "help", 0
exec:     db "exec", 0
spacer:   db "  ", 0

times 510-($-$$)-20 db 0
dw puts
dw gets
dw cls
dw read_disk
dw streq
dw write_disk
dw shell
dw getchar
dw putchar
dw sleep

dw 0xAA55
; BF Program Sector

db "++++++++[>++++++++<-]>+.+.+."

times 1024-($-$$) db 0
; Welcome Message Sector

db "Welcome to DressedAlarm184's boot sector operating system!", 13, 10
db "Every bit of code for the OS is contained within the first sector.", 13, 10
db "Use the 'help' command to view a list of all commands.", 13, 10, 0

times 4096-($-$$) db 0
; Pad Image To 4 KiB
; DressedAlarm184 Boot Sector OS End
