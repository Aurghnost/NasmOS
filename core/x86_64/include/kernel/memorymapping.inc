%include "kernel/constants.inc"
;Buddy Memory Allocator :
;Bloc élémentaire : 4096 octets
;
;Nombre de blocs : 1024*1024 = 2**20
;=> il faut 2**18 * 8 - 1 = 2097151 = 0x200000 octets (voir documentation ?)
%define BMA_BITMAP 0x300000 ; on place la bitmap en 0x300000, avec un max de 0x300000 + 0x200000 = 0x500000 

; screen.inc
EXTERN screen__print_uint, screen__endl, screen__print_str

GLOBAL memorymapping__init

;fn  bma_init : void -> void
;Initialise l'allocateur de pages physique
GLOBAL memorymapping__bma_init

;fn bma_reserve_pages : unsigned int n -> void *
;Réserve '2^n' pages physiques consécutives, de taille 4 Ko
;@param n ordre du nombre de pages consécutives à réserver 
;@return adresse de la première page
; TODO : régler le bug qui empêche d'allouer 1 une seule page (n = 0)
GLOBAL memorymapping__bma_reserve_pages

;fn create_task_memory_space : void -> void *
;Crée un répertoire de pages pour la tâche utilisateur et renvoie l'adresse réelle de ce répertoire (pour pouvoir le charger par CR3)
GLOBAL memorymapping__create_task_memory_space

; Écrit le résultat dans EAX
%macro physical_to_index 1
	mov eax, %1
	shr eax, 12
%endmacro

%macro index_to_physical 1
	mov eax, %1
	shl eax, 12
%endmacro

