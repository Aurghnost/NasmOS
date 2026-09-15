%include "kernel/screen.inc"

[BITS 32]

print_attr: db 0x07
screen_cursor: db 0, 0
buffer: times 4096 db 0

screen__endl: db 10, 0

screen__scroll_up:
push eax
push ebp
mov ebp, esp
push ebx
push ecx
push edx
	mov eax, [ebp + 12]
	mov edx, 160 ; Nombre d'octets par ligne = 2 * 80
	imul edx, eax ; EDX = nombre d'octets à défiler
	mov ecx, RAMSCREEN
	.while:
	cmp ecx, RAMSCREENLIMIT
	jz .whileend
		mov eax, ecx
		add eax, edx
		.if:
		cmp eax, RAMSCREENLIMIT
		jl .else
			mov byte[ecx], 0
			inc ecx
			mov byte[ecx], 0x07
			inc ecx
		jmp .ifend
		.else:
			mov bl, byte[eax]
			mov byte[ecx], bl
			inc eax
			inc ecx
			mov bl, byte[eax]
			mov byte[ecx], bl
			inc ecx
		.ifend:
	jmp .while
	.whileend:
pop edx
pop ecx
pop ebx
mov esp, ebp
pop ebp
pop eax ; ajoute 4 à esp
ret

screen__putc:
push eax
push ebp
mov ebp, esp
push ebx
push edx
	mov eax, [ebp + 12]
	xor ebx, ebx
	mov ah, al
	.switch:
	sub ah, 8
	cmp ah, 6
	jge .casedefault
	mov edx, .switchtable
	mov bl, ah
	mov ebx, [edx + 4*ebx]
	jmp ebx
	.case11:
	.case12:
	.casedefault: ; Affichage d'un caractère ASCII
		xor ebx, ebx
		mov edx, RAMSCREEN
		mov bl, byte[screen_cursor]
		imul ebx, 2
		add edx, ebx
		mov bl, byte[screen_cursor + 1]
		imul ebx, 160
		add edx, ebx
		mov byte[edx], al
		mov ah, [print_attr]
		mov byte[edx + 1], ah
		mov ah, byte[screen_cursor]
		inc ah
		cmp ah, 80 ; si supérieur à 80, on passe à la ligne suivante (ASCII = 10)
		jge .case10
		mov byte[screen_cursor], ah ; sinon on met à jour le curseur
	jmp .switchend
	.case8:
		xor ebx, ebx
		mov edx, RAMSCREEN
		mov bl, byte[screen_cursor]
		dec bl
		cmp bl, 0
		jl .switchend
		mov byte[screen_cursor], bl
		imul ebx, 2
		add edx, ebx
		mov bl, byte[screen_cursor + 1]
		imul ebx, 160
		add edx, ebx
		mov byte[edx], ' '
		mov ah, [print_attr]
		mov byte[edx + 1], ah
	jmp .switchend
	.case9: ; HT (Horizontal Tab)
	jmp .switchend
	.case10: ; LF (Line Feed)
		mov byte[screen_cursor], 0
		mov ah, byte[screen_cursor + 1]
		inc ah
		mov byte[screen_cursor + 1], ah
	jmp .switchend
	.case13: ; CR (Carriage Return)
		mov byte[screen_cursor], 0
	.switchend:
	xor eax, eax
	mov al, byte[screen_cursor + 1]
	.if:
	cmp al, 25
	jl .ifend
		push dword 1
		call screen__scroll_up
		dec al
		mov byte[screen_cursor + 1], al
	.ifend:
pop edx
pop ebx
mov esp, ebp
pop ebp
pop eax ; ajoute 4 à esp
ret
.switchtable:
	dd .case8
	dd .case9
	dd .case10
	dd .case11
	dd .case12
	dd .case13
	dd .casedefault

screen__print_str:
push eax ; Pour laisser de la place à la valeur de retour
push ebp
mov ebp, esp
push esi ; la fonction ne modifie pas le pointeur passé en argument
	mov esi, [ebp + 12]
	.while:
	mov al, byte [esi]
	cmp al, 0
	jz .whileend
		push eax
		call screen__putc
		inc esi
	jmp .while
	.whileend:
pop esi
mov esp, ebp
pop ebp
pop eax
ret

screen__print_uint:
push eax
push ebp
mov ebp, esp
push ecx
push edx
push edi
	mov eax, [ebp + 12]
	.if:
	cmp eax, 0
	jnz .ifend
	mov eax, '0'
	push eax
	call screen__putc
	pop edx
	jmp .end
	.ifend:

	mov edi, 10
	xor ecx, ecx
	xor edx, edx

	.while:
	cmp eax, 0
	jz .whileend
		xor dl, dl
		div edi
		add dl, 0x30
		mov byte[buffer + ecx], dl
		inc ecx
	jmp .while
	.whileend:
	.while2:
	cmp ecx, 0
	jz .whileend2
		dec ecx
		mov al, byte[buffer + ecx]
		push eax
		call screen__putc
		pop edx
	jmp .while2
	.whileend2:
	.end:
pop edi
pop edx
pop ecx
mov esp, ebp
pop ebp
pop eax
ret

; fn move_cursor : uint8_t x, uint8_t y -> void
; Déplace le curseur à la position (x, y)
move_cursor:
push eax
push ebp
mov ebp, esp
push ebx
	mov ebx, [ebp + 16] ; y
	imul ebx, 80
	mov eax, [ebp + 12] ; x
	add ebx, eax

	mov al, 0x0f
	mov dx, 0x03d4
	out dx, al
	
	mov al, bl
	inc dl
	out dx, al

	mov al, 0x0e
	dec dl
	out dx, al
	
	mov al, bh
	inc dl
	out dx, al
pop ebx
mov esp, ebp
pop ebp
mov eax, [esp + 4]
mov [esp + 8], eax
pop eax
add esp, 4
ret

screen__update_cursor:
push eax
push ebp
mov ebp, esp
	xor eax, eax
	mov al, byte [screen_cursor + 1]
	push eax
	mov al, byte [screen_cursor]
	push eax
	call move_cursor
mov esp, ebp
pop ebp
pop eax
ret
