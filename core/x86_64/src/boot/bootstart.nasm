[BITS 32]

EXTERN _kmain

GLOBAL _start

section .text
_start: ; d'après le linker + gdb, _start == 0x100020
	mov dword[0xB8000], 0x2f4b2f4f
	call _kmain

	cli
	hlt
