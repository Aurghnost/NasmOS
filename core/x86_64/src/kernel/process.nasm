[BITS 32]
%include "kernel/constants.inc"
%include "kernel/process.inc"

GLOBAL process__list
process__list:
ISTRUC ProcessList
	at ProcessList.length, dw 0
	at ProcessList.tab, db (Process.sizeof * MAX_PROCESS) dup 0 
IEND

process__load_task:
push eax
push ebp
mov ebp, esp
push edi
	xor ecx,ecx
	mov cx, [process__list + ProcessList.length]
	mov eax, ecx
	mov edx, Process.sizeof
	mul edx
	mov ecx, eax

	push dword[ebp + 16]
	call memorymapping__create_task_memory_space
	add esp, 4

	mov [process__list + ProcessList.tab + ecx + Process.regs + Registers.cr3], eax ; EAX de la création de tâche
	; Pile noyau
	add ebx, PAGE_SIZE
	mov word[process__list + ProcessList.tab + ecx + Process.kstack + KStack.ss0], 0x18
	mov [process__list + ProcessList.tab + ecx + Process.kstack + KStack.esp0], ebx

	mov ebx, cr3
	mov cr3, eax

	mov eax, [ebp + 16] ; prgm_len
	push eax
	mov eax, [ebp + 12] ; physical_addr valide car map identity sur le noyau
	push eax
	mov edx, 0x3FC00000 ; destination_addr
	push edx
	call string__memcpy

	mov cr3, ebx

	; Initialisation nécessaire :
	pushf
	pop edx ; récupère le registre de drapeaux
	
	or edx, 0x200 ; Active le Interrupt Flag (IF)
	and edx, 0xffffbfff ; Désactive le Nested Task (NT)
	mov dword[process__list + ProcessList.tab + ecx + Process.regs + Registers.eflags], edx

	mov word[process__list + ProcessList.tab + ecx + Process.regs + Registers.ss], 0x33
	mov edx, 0x3FC00000
	mov [process__list + ProcessList.tab + ecx + Process.regs + Registers.eip], edx
	add edx, PAGE_SIZE ; pour avoir esp

	mov [process__list + ProcessList.tab + ecx + Process.regs + Registers.esp], edx
	mov word[process__list + ProcessList.tab + ecx + Process.regs + Registers.cs], 0x23
	mov word[process__list + ProcessList.tab + ecx + Process.regs + Registers.ds], 0x2B
	mov word[process__list + ProcessList.tab + ecx + Process.regs + Registers.es], 0x2B
	mov word[process__list + ProcessList.tab + ecx + Process.regs + Registers.fs], 0x2B
	mov word[process__list + ProcessList.tab + ecx + Process.regs + Registers.gs], 0x2B

	; Initialisation du processus initialisé à son lancement 
	mov dword[process__list + ProcessList.tab + ecx + Process.regs + Registers.eax], 0
	mov dword[process__list + ProcessList.tab + ecx + Process.regs + Registers.ebx], 0
	mov dword[process__list + ProcessList.tab + ecx + Process.regs + Registers.ecx], 0
	mov dword[process__list + ProcessList.tab + ecx + Process.regs + Registers.edx], 0
	mov dword[process__list + ProcessList.tab + ecx + Process.regs + Registers.ebp], 0
	mov dword[process__list + ProcessList.tab + ecx + Process.regs + Registers.esi], 0
	mov dword[process__list + ProcessList.tab + ecx + Process.regs + Registers.edi], 0

	xor eax,eax
	mov ax, [process__list + ProcessList.length]
	mov [process__list + ProcessList.tab + ecx + Process.pid], ax
	inc ax
	mov [process__list + ProcessList.length], ax

  mov eax, [process__list + ProcessList.tab + ecx + Process.regs + Registers.cr3]
  pop edi
mov [ebp + 4], eax
mov esp, ebp
pop ebp
pop eax
ret
.pid: db "PID : ", 0
