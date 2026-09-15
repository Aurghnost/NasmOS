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
