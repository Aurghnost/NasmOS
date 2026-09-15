%ifndef GDT_INC_INCLUDE
%define GDT_INC_INCLUDE

%define GDTBASE 0x0 ; Adresse physique où se situe la GDT
%define GDTSIZE 0xFF ; Nombre maximale de descripteurs dans la GDT

; string.inc
EXTERN string__memcpy

;fn init : void -> void
;Initialise la GDT pour le kernel
GLOBAL gdt__init 

; Descripteur de segment
STRUC GDTDescriptor
	.limite0_15: resw 1
	.base0_15: resw 1
	.base16_23: resb 1
	.acces: resb 1
	.limite16_19: resb 1
	.base24_31: resb 1
	.sizeof:
ENDSTRUC

; Pointeur vers une table de descripteurs
STRUC Gdtptr
	.limite :resw 1
	.base: resd 1
ENDSTRUC

STRUC TSS ; 27 * 4 = 108 octets
	.previous_task: resw 1
	.__previous_task_reserved: resw 1
	.esp0: resd 1
	.ss0: resw 1
	.__ss0_reserved: resw 1
	.esp1: resd 1
	.ss1: resw 1
	.__ss1_reserved: resw 1
	.esp2: resd 1
	.ss2: resw 1
	.__ss2_reserved: resw 1
	.cr3: resd 1
	.eip: resd 1
	.eflags: resd 1
	.eax: resd 1
	.ecx: resd 1
	.edx: resd 1
	.ebx: resd 1
	.esp: resd 1
	.ebp: resd 1
	.esi: resd 1
	.edi: resd 1
	.es: resw 1
	.__es_reserved: resw 1
	.cs: resw 1
	.__cs_reserved: resw 1
	.ss: resw 1
	.__ss_reserved: resw 1
	.ds: resw 1
	.__ds_reserved: resw 1
	.fs: resw 1
	.__fs_reserved: resw 1
	.gs: resw 1
	.__gs_reserved: resw 1
	.ldt_selector: resw 1
	.__ldt_selector_reserved: resw 1
	.debug_flag: resw 1
	.io_map: resw 1
	.sizeof:
ENDSTRUC

%endif
