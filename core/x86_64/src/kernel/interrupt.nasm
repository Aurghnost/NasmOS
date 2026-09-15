%include "kernel/interrupt.inc"

[BITS 32]

; L'instruction int empile avant de manière automatique :
; push ss
; push esp
; push eflags
; push cs
; push eip
; et les pops lors de iret
%macro SAVE_REGS 0
pushad
push ds
push es
push fs
push gs
; avant que la pagination existe :
; push ebx
; mov bx, 0x10
; mov ds, bx
; pop ebx
%endmacro
%macro RESTORE_REGS 0
pop gs
pop fs
pop es
pop ds
popad
%endmacro

isr__default:
SAVE_REGS
mov al, 0x20
out 0x20, al ; "End of Interrupt" (EOI) envoyé au PIC
RESTORE_REGS
iret
.default: db "Default interruption", 10, 0

clock_int:
	push ebp
	mov ebp, esp
		mov al, byte[.tic]
		inc al
		cmp al, 25 ; va afficher "clock" toutes les 25 interruptions d'horloge
		jnz .end
			mov eax, [.sec]
			inc eax
			mov [.sec], eax
			xor al, al
			mov eax, '.'
			push eax
			call screen__putc
			pop eax
			xor al, al
		.end:
		mov byte[.tic], al
		call scheduler__shortschedule
	mov esp, ebp
	pop ebp
ret
.tic db 0 
.sec dd 0 ; pas exactement une seconde avec l'émulateur QEMU

isr__clock_int:
SAVE_REGS
	call clock_int
mov al, 0x20
out 0x20, al ; "End of Interrupt" (EOI) envoyé au PIC
RESTORE_REGS
iret


keyboard_int:
push eax
push ebp
mov ebp, esp
push ebx

	xor eax, eax
	.wdo:
	in al, 0x64
	.while:
	and al, 0x01 ; tant que rien n'a ete detecte dans le buffer clavier (le temps que l'info arrive quoi)
	cmp al, 0
	jz .wdo
	in al, 0x60 ; le scan code du clavier : AL < 0x80 => touche pressée, AL >= 0x80 => touche relâchée
	dec al
	mov bl, 1
	xor bh, bh
	cmp al, 0x80
	jae .released
	.pressed:
		.p29:
		cmp al, 0x29
		jnz .p35
			mov [.lshift_enabled], bl
		jmp .end
		.p35:
		cmp al, 0x35
		jnz .p1C
			mov [.rshift_enabled], bl
		jmp .end
		.p1C:
		cmp al, 0x1C
		jnz .p37
			mov [.ctrl_enabled], bl
		jmp .end
		.p37:
		cmp al, 0x37
		jnz .pdefault
			mov [.alt_enabled], bl
		jmp .end
		.pdefault:
			mov ebx, 4
			mul ebx
			xor ebx, ebx
			mov bl, byte[.lshift_enabled]
			or bl, byte[.rshift_enabled]
			add eax, ebx
			xor ebx, ebx
			mov bl, byte[KEYBOARDMAP_QWERTY + eax]
			cmp bl, 0xFF
			jz .end
			push ebx
			call screen__putc
	jmp .end
	.released:
		sub al, 0x80
		.r29:
		cmp al, 0x29
		jnz .r35
			mov [.lshift_enabled], bh
		jmp .end
		.r35:
		cmp al, 0x35
		jnz .r1C
			mov [.rshift_enabled], bh
		jmp .end
		.r1C:
		cmp al, 0x1C
		jnz .r37
			mov [.ctrl_enabled], bh
		jmp .end
		.r37:
		cmp al, 0x37
		jnz .end
			mov [.alt_enabled], bh
	.end:

	call screen__update_cursor

pop ebx
mov esp, ebp
pop ebp
pop eax
ret
.lshift_enabled db 0
.rshift_enabled db 0
.alt_enabled db 0
.ctrl_enabled db 0

isr__keyboard_int:
SAVE_REGS
	call keyboard_int
mov al, 0x20
out 0x20, al ; "End of Interrupt" (EOI) envoyé au PIC
RESTORE_REGS
iret

isr__syscalls_int:
SAVE_REGS
push eax
	call syscalls__exec
pop eax
mov al, 0x20
out 0x20, al ; "End of Interrupt" (EOI) envoyé au PIC
RESTORE_REGS
iret

page_fault_int:
push eax
push ebp
mov ebp, esp
	push .segfault
	call screen__print_str
	mov eax, cr2
	push eax
	call screen__print_uint
	push .segfault2
	call screen__print_str
	hlt
mov esp, ebp
pop ebp
pop eax
ret
	.segfault db "Page Fault : Page of real address ", 0
	.segfault2 db " is not attributed in virtual memory", 10, 0

isr__pagefault_int:
SAVE_REGS
	call page_fault_int
RESTORE_REGS
iret
