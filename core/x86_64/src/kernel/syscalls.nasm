%include "kernel/syscalls.inc"

[BITS 32]

;fn exec : *args -> int status
syscalls__exec:
push eax
push ebp
mov ebp, esp
	mov eax, [ebp + 12] ; sys_num

	xor ebx, ebx
	mov ah, al
	.switch:
	cmp ah, 1
	jg .casedefault
	mov edx, .switchtable
	mov bl, ah
	mov ebx, [edx + 4*ebx]
	jmp ebx
	.case0:
	.casedefault:
	push .unknown_syscall
	call screen__print_str
	jmp .switchend
	.case1: ; sys_write
		mov ebx, [ebp + 48] ; voir notes_noyau.txt : ebx avant l'appel à l'interruption
		push ebx
		call screen__print_str
		add esp, 4

	.switchend:
mov esp, ebp
pop ebp
pop eax
ret
.switchtable:
	dd .case0 ; sys_read
	dd .case1 ; sys_write
	dd .casedefault
.unknown_syscall db "CaS1", 10, 0
