%ifndef _SCREEN_INC_INCLUDED
%define _SCREEN_INC_INCLUDED

%define RAMSCREEN 0xB8000
%define SCREENSIZE 0xFA0 ; = 4000 : 25 lignes de 80 caractères (un octet pour le code ASCII, un octet pour l'attribut donc on a 160 octets par ligne)
%define RAMSCREENLIMIT 0xB8FA0

;fn print_str : const char *string -> void
;Affiche une chaine de caracteres sur l'ecran
;@param[in] string chaine à afficher
GLOBAL screen__print_str ; char *string -> void

;fn scroll_up : int n -> void
;Défile le contenu de l'écran vers le haut
;@param n nombre de lignes à défiler
GLOBAL screen__scroll_up ; int n -> void

;fn putc : char c -> void
;Affiche un unique caractère à la position du curseur sur l'écran et met à jour la position du curseur en conséquence
;@param c caractère ASCII
GLOBAL screen__putc ; char c -> void

;fn update_cursor : void -> void 
;Met à jour la position du curseur sur l'écran  
GLOBAL screen__update_cursor ; void -> void

;fn print_uint : int n -> void
;Affiche un nombre sur l'écran
;@param n nombre à afficher
GLOBAL screen__print_uint ; int n -> void

;Chaîne de caractère "\n"
GLOBAL screen__endl

%endif
