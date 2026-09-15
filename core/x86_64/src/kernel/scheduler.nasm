%include "kernel/scheduler.inc"

[BITS 32]

current_active_process: dd 0

;fn shortschedule : void -> void
scheduler__shortschedule: ; 0x103ec4
push eax
push ebp
mov ebp, esp
	mov eax, dword[current_active_process]
	cmp eax, 0
	jnz .else
	; if current_active_process == 0
		mov eax, dword[process__list + ProcessList.length]
		cmp eax, 0
		jz .else
		; if process__list.length != 0

			mov eax, process__list
			add eax, ProcessList.tab ; le premier processus
			mov [current_active_process], eax ; current_active_process contient l'adresse du premier processus

			mov edi, [current_active_process]
			jmp .commut

	.else:
	cmp dword[process__list + ProcessList.length], 1
	jle .end
	; ici, on a au moins deux processus, on sauvegarde donc le contexte puis
	; on modifie le pointeur vers current_active_process et appel à la fonction de switch
	; le contexte est déjà en partie sauvegardé par SAVE_REGS appelé à l'interruption d'horloge
		mov edi, [current_active_process] ; adresse du processus courant

		mov eax, [esp + 20]
		mov word[edi + Process.regs + Registers.gs], ax

		mov eax, [esp + 24]
		mov word[edi + Process.regs + Registers.fs], ax
		
		mov eax, [esp + 28]
		mov word[edi + Process.regs + Registers.es], ax

		mov eax, [esp + 32]
		mov word[edi + Process.regs + Registers.ds], ax

		mov eax, [esp + 36]
		mov dword[edi + Process.regs + Registers.edi], eax
		
		mov eax, [esp + 40]
		mov dword[edi + Process.regs + Registers.esi], eax

		mov eax, [esp + 44]
		mov dword[edi + Process.regs + Registers.ebp], eax

		; esp + 48 est l'ESP noyau ?
		
		mov eax, [esp + 52]
		mov dword[edi + Process.regs + Registers.ebx], eax
		
		mov eax, [esp + 56]
		mov dword[edi + Process.regs + Registers.edx], eax

		mov eax, [esp + 60]
		mov dword[edi + Process.regs + Registers.ecx], eax

		mov eax, [esp + 64]
		mov dword[edi + Process.regs + Registers.eax], eax

		mov eax, [esp + 68]
		mov dword[edi + Process.regs + Registers.eip], eax

		mov eax, [esp + 72]
		mov word[edi + Process.regs + Registers.cs], ax

		mov eax, [esp + 76]
		mov dword[edi + Process.regs + Registers.eflags], eax

		mov eax, [esp + 80]
		mov dword[edi + Process.regs + Registers.esp], eax
		
		mov eax, [esp + 84]
		mov word[edi + Process.regs + Registers.ss], ax

		mov eax, esp
		add eax, 88
		mov [default_tss + TSS.esp0], eax

		mov ebx, [current_active_process]
		mov eax, [ebx + Process.pid]
		inc eax
		
		cmp word[process__list + ProcessList.length], ax
		jle .else2
			; if ax < process__list.length
			mov edx, Process.sizeof
			mul edx 
			add eax, process__list
			add eax, ProcessList.tab
			mov [current_active_process], eax
		jmp .tocommut
		.else2:
			; if ax >= process__list.length
			mov eax, process__list
			add eax, ProcessList.tab ; le premier processus
			mov [current_active_process], eax

		.tocommut:
			mov edi, [current_active_process]

	.commut:
	jmp scheduler__commut

.end:
mov esp, ebp
pop ebp
pop eax
ret
.scheduler: db "Calling scheduler", 10, 0
.msg: db "Euh ok ?", 10, 0
.first: db "first call to scheduler", 10, 0
.save_context: db "save context of task ", 0
.next_proc: db "next process in the list :", 10, 0

scheduler__commut:
  mov esp, [default_tss + TSS.esp0] ; réinitialise la pile pour avoir un truc propre

  mov eax, dword[edi + Process.regs + Registers.cr3]
  mov cr3, eax
  ; Pour préparer le iret de commutation : push ss, esp, eflags, cs, eip
  ; iret va depop tout ça
  xor eax, eax
  mov ax, word[edi + Process.regs + Registers.ss]
  push eax
  mov eax, [edi + Process.regs + Registers.esp]
  push eax
  mov eax, [edi + Process.regs + Registers.eflags]
  or eax, 0x200 ; réactive le Interrupt Enabled Flag
  and eax, 0xFFFFBFFF ; ? Voir Nested Task Flag jsp
  push eax
  xor eax, eax
  mov ax, word[edi + Process.regs + Registers.cs]
  push eax
  mov eax, [edi + Process.regs + Registers.eip]
  push eax
  push dword[edi + Process.regs + Registers.eax]
  push dword[edi + Process.regs + Registers.ecx]
  push dword[edi + Process.regs + Registers.edx]
  push dword[edi + Process.regs + Registers.ebx]
  push dword[edi + Process.regs + Registers.ebp]
  push dword[edi + Process.regs + Registers.esi]
  push dword[edi + Process.regs + Registers.edi]
  xor edx, edx
  mov dx, word[edi + Process.regs + Registers.ds]
  push edx
  mov dx, word[edi + Process.regs + Registers.es]
  push edx
  mov dx, word[edi + Process.regs + Registers.fs]
  push edx
  mov dx, word[edi + Process.regs + Registers.gs]
  push edx

  mov al, 0x20
  out 0x20, al ; "End of Interrupt" (EOI) envoyé au PIC

  pop gs
  pop fs
  pop es
  pop ds
  pop edi
  pop esi
  pop ebp
  pop ebx
  pop edx
  pop ecx
  pop eax
iret
.succeed: db "Context switch succeed", 10, 0
