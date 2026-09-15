%ifndef _KERNEL_INC_INCLUDED
%define _KERNEL_INC_INCLUDED

; string.inc
EXTERN string__memcpy

; screen.inc
EXTERN screen__print_str, screen__print_uint, screen__scroll_up, screen__update_cursor, screen__endl

; gdt.inc
EXTERN gdt__init, default_tss

; idt.inc
EXTERN idt__init

; pic.inc
EXTERN pic__init

; memorymapping.inc
EXTERN memorymapping__init, memorymapping__bma_init, memorymapping__bma_reserve_pages, memorymapping__create_task_memory_space

; process.inc
EXTERN process__load_task, process__list

EXTERN scheduler__detector_debug

STRUC MbPartialInfo
	.flags: resb 8
	.low_mem: resb 8
	.high_mem: resb 8
	.boot_device: resb 8
	.cmd_line: resb 8
ENDSTRUC

%endif
