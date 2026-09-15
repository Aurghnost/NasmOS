[BITS 32]

%include "kernel/gdt.inc"

GLOBAL default_tss

GLOBAL gdt

gdt: times GDTSIZE dd 0, 0
gdt_ptr:
	ISTRUC Gdtptr
		at Gdtptr.limite, dw 0
		at Gdtptr.base, dd 0
	IEND
default_tss: times TSS.sizeof db 0

;fn init_descriptor : unsigned int base, unsigned int limite, unsigned char acces, unsigned char autres, Descriptor *desc -> void
;Initialise un descripteur de segment selon les informations indiquées
;@param base base du descripteur
;@param limite limite du descripteur
;@param acces droits d'accès au segment
;@param autres autres (dans l'octet 7 du descripteur)
;@param desc[in, out] pointeur vers le descripteur proprement dit
init_descriptor:
push eax
push ebp
mov ebp, esp
push ebx
push esi
	mov esi, [ebp + 28] ; desc
	mov eax, [ebp + 12] ; base
	mov [esi + GDTDescriptor.base0_15], ax ; ok
	shr eax, 16
	mov [esi + GDTDescriptor.base16_23], al
	mov [esi + GDTDescriptor.base24_31], ah
	mov eax, [ebp + 16] ; limite
	mov [esi + GDTDescriptor.limite0_15], ax
	shr eax, 16
	and eax, 0xf
	mov ebx, [ebp + 24] ; autres
	shl ebx, 4
	add al, bl
	mov [esi + GDTDescriptor.limite16_19], al
	mov eax, [ebp + 20] ; acces
	mov [esi + GDTDescriptor.acces], al
pop esi
pop ebx
mov esp, ebp
pop ebp
mov eax, [esp + 4]
mov [esp + 20], eax
pop eax
add esp, 16
ret

;fn init : void -> void
;Initialise la GDT pour le kernel
gdt__init:
push eax
push ebp
mov ebp, esp
push ebx

	mov dword[default_tss + TSS.debug_flag], 0x0
	mov dword[default_tss + TSS.esp0], 0x20000
	mov dword[default_tss + TSS.ss0], 0x18

	mov eax, gdt

	; DESCRIPTEURS NOYAU
	add eax, GDTDescriptor.sizeof ; pointe vers le descripteur de code
	push eax
	push 0x0D ; autres
	push 0x9B ; droits
	push 0xFFFFF ; limite
	push 0x0 ; base
	call init_descriptor

	add eax, GDTDescriptor.sizeof ; pointe vers le descripteur de données
	push eax
	push 0x0D ; autres
	push 0x93 ; droits
	push 0xFFFFF ; limite
	push 0x0 ; base
	call init_descriptor

	add eax, GDTDescriptor.sizeof ; pointe vers le descripteur de pile
	push eax
	push 0x0D ; autres
	push 0x97 ; droits
	push 0x0 ; limite
	push 0x0 ; base
	call init_descriptor

	; TACHE UTILISATEUR
	; idéalement, ne devrait pas être dans l'initialisation pour pouvoir créer des tâches plus tard
	add eax, GDTDescriptor.sizeof
	push eax
	push 0x0D
	push 0xFF
	push 0xFFFFF ; adresse toute la mémoire, pour simplifier
	push 0x0
	call init_descriptor

	add eax, GDTDescriptor.sizeof
	push eax
	push 0x0D
	push 0xF3
	push 0xFFFFF ; adresse toute la mémoire, pour simplifier
	push 0x0
	call init_descriptor

	add eax, GDTDescriptor.sizeof
	push eax
	push 0x0D
	push 0xF7
	push 0x00
	push 0x0
	call init_descriptor
	; -----------------

	add eax, GDTDescriptor.sizeof
	push eax
	push 0x0
	push 0xE9
	push 0x67
	push default_tss
	call init_descriptor

	mov eax, GDTSIZE
	xor ebx, ebx
	mov bl, 8
	mul ebx
	mov ebx, GDTBASE
	mov [gdt_ptr + Gdtptr.base], ebx
	mov word[gdt_ptr + Gdtptr.limite], ax

	push eax
	push gdt
	push dword GDTBASE
	call string__memcpy

	lgdt [gdt_ptr] ; Load Global Descriptor Table
pop ebx
mov esp, ebp
pop ebp
pop eax
ret

