[BITS 32]

%include "kernel/constants.inc"
%include "kernel/kernel.inc"

GLOBAL _kmain

_kmain: ; _kmain = 0x103bd0
	; Affichage d'un message par écriture dans la RAM vidéo

	push dword 25
	call screen__scroll_up
	add esp, 4

	push msg
	call screen__print_str
	push msg2
	call screen__print_str
	add esp, 8
	call idt__init

	push msg3
	call screen__print_str
	add esp, 4
	call pic__init

	push msg1
	call screen__print_str
	add esp, 4
	call gdt__init

	; Réinitialisation des descripteurs de segment pour qu'ils pointent vers la nouvelle GDT
	mov ax, 0x10 ; adresse dans la GDT du descripteur de données
	mov ds, ax
	mov fs, ax
	mov gs, ax
	mov es, ax
	mov ax, 0x18 ; adresse dans la GDT du descripteur de pile
	mov ss, ax
	mov esp, 0x20000
	jmp 0x8:.next ; 0x8 = adresse dans la GDT du descripteur de code
	.next:

	push msg5
	call screen__print_str
	add esp, 4

	mov ax, 0x38 ; car le Task Register est dans la GDT à l'indice 7 : 0x38 = 7 * 8
	ltr ax

	push msg9
	call screen__print_str
	add esp, 4
	call memorymapping__init 

	call memorymapping__bma_init ; initialisation de l'allocateur de pages physiques
	mov eax, 11 ; 2**11 * 4Ko = 8Mo
	push eax
	call memorymapping__bma_reserve_pages
	add esp, 4

	call screen__update_cursor ; ptit update graphique, parce-que le cursor est n'importe où (aléatoire puis placé par BIOS)

	push PAGE_SIZE
	push user_task1
	call process__load_task 
	add esp, 8
 
 	push eax

	push PAGE_SIZE
	push user_task2
	call process__load_task
	add esp, 8
	
	push PAGE_SIZE
	push user_task3
	call process__load_task 
	add esp, 8

	pop eax
	mov cr3, eax

	push 0x33 ; ss
	; l'adresse dans la gdt le sélecteur de pile de la tache utilisateur est en 0x30
	; mais les trois premiers bits du sélecteur correspondent :
	; premier et deuxième : RPL (niveau de privilège)
	; troisième : 0 = GDT, 1 = LDT
	push (USERMODE_ADDR + PAGE_SIZE) ; esp pour la tâche

	pushf
	pop eax ; récupère le registre de drapeaux

	or eax, 0x200 ; Active le Interrupt Flag (IF)
	and eax, 0xffffbfff ; Désactive le Nested Task (NT)
	push eax ; eflags
	push 0x23 ; cs; le sélecteur de code de la tache utilisateur est en 0x20, mais 0x23 pour même raison que précédemment

	push USERMODE_ADDR ; eip
	mov ax, 0x2B ; = 0x28 + 3 voir précédemment
	mov ds, ax
	iret

	push msg7
	call screen__print_str
	add esp, 4 

.end:
	jmp .end

msg db "kernel : NasmOS loaded", 10, 0
msg1 db "kernel : mise a jour de la GDT", 10, 0
msg2 db "kernel : mise a jour de l'IDT", 10, 0
msg3 db "kernel : initialisation du PIC", 10, 0
msg4 db "kernel : autorisation des interruptions", 10, 0
msg5 db "kernal : chargement du Task Register", 10, 0

msg7 db "kernel : erreur de commutation vers la tâche 0", 10, 0

msg9 db "kernel : initialisation de la pagination noyau", 10, 0

user_task1:
push ebp
mov ebp, esp
	mov esi, 647
	mov edi, 648
	mov edx, 87654321 ; ID de usertask 1 pour les tests
	mov ebx, 80
	.while:
		mov eax, 0x1
		mov ebx, .msg
		int 0x80
		mov ecx, 0x10000000
		.for:
			dec ecx
			cmp ecx, 0
		jnz .for
	jmp .while
mov esp, ebp
pop ebp
ret
.msg db "Tache 1", 10, 0

user_task2:
push ebp
mov ebp, esp
	mov esi, 647
	mov edi, 648
	mov edx, 12345678 ; ID de usertask 2 pour les tests
	.while:
		mov eax, 0x1
		mov ebx, .msg
		int 0x80
		mov ecx, 0x10000000
		.for:
			dec ecx
			cmp ecx, 0
		jnz .for
	jmp .while
mov esp, ebp
pop ebp
ret
.msg db "Tache 2", 10, 0

user_task3:
push ebp
mov ebp, esp
	mov edx, 12345678 ; ID de usertask 2 pour les tests
	.while:
		mov eax, 0x1
		mov ebx, .msg
		int 0x80
		mov ecx, 0x10000000
		.for:
			dec ecx
			cmp ecx, 0
		jnz .for
	jmp .while
mov esp, ebp
pop ebp
ret
.msg db "Tache 3", 10, 0
