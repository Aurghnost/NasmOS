%ifndef _SYSCALLS_INC_INCLUDED
%define _SYSCALLS_INC_INCLUDED

; screen.inc
EXTERN screen__print_str, screen__print_uint, screen__endl

;fn exec : *args -> int status
;Exécute un appel système selon les arguments donnés en registres
;@warning pour l'instant seul 'write' (eax:=1) est écrit et ne correspond pas à la norme
GLOBAL syscalls__exec

%endif
