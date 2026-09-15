%ifndef _SCHEDULER_INC_INCLUDED
%define _SCHEDULER_INC_INCLUDED

%include "kernel/process.inc"
%include "kernel/gdt.inc"

; screen.inc
EXTERN screen__print_str, screen__print_uint, screen__endl
EXTERN default_tss

; process.inc
EXTERN process__list

GLOBAL scheduler__detector_debug
GLOBAL scheduler__shortschedule, current_active_process

%endif
