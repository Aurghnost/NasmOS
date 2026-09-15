%ifndef _PROCESS_INC_INCLUDED
%define _PROCESS_INC_INCLUDED

%define MAX_PROCESS 10

; screen.inc
EXTERN screen__print_str, screen__print_uint, screen__scroll_up, screen__update_cursor, screen__endl

;string.inc
EXTERN string__memcpy

;memorymapping.inc
EXTERN memorymapping__create_task_memory_space

EXTERN default_tss

;fn load_task: void* prgm_physical_addr , unsigned int prgm_len -> void*
;Alloue des pages physiques et les maps virtuellement pour le programme puis
;copie le programme de 'prgm_len' octets situé à l'adresse "physique prgm_physical_addr"
;dans l'espace physique alloué
;@return CR3 de mapping virtuel
GLOBAL process__load_task

STRUC Registers
	; même ordre que pushad
	.eax: resd 1
	.ecx: resd 1
	.edx: resd 1
	.ebx: resd 1
	.esp: resd 1
	.ebp: resd 1
	.esi: resd 1
	.edi: resd 1
	;;;;;;;;;;;;;;;;;;;;;;;
	.eip: resd 1
	.eflags: resd 1 ; statut des registres
	.cs: resw 1
	.ss: resw 1
	.ds: resw 1
	.es: resw 1
	.fs: resw 1
	.gs: resw 1
	.cr3: resd 1 ; pointeur vers le répertoire de page

	.sizeof:
ENDSTRUC

STRUC KStack
  .ss0: resw 1
  .esp0: resd 1

  .sizeof:
ENDSTRUC

; Processus du système
STRUC Process
	.pid: resd 1 ; identifiant du processus

	.regs: resb Registers.sizeof ; sauvegarde des registres suite à une commutation de contexte

	.kstack: resb KStack.sizeof ; caractérisation de la pile noyau

	.sizeof:
ENDSTRUC

; Pour l'instant, structurellement un tableau (et pas une liste)
; les processus sont enregistrés dans .tab et indicés par leur PID
STRUC ProcessList
	.length: resw 1
	.tab: resb (Process.sizeof * MAX_PROCESS)
	.sizeof:
ENDSTRUC

%endif 
