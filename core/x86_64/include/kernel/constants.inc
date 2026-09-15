%ifndef _CONSTANTS_INC_INCLUDED
%define _CONSTANTS_INC_INCLUDED

%define PAGING_FLAG 0x80000001

%define PAGE_SIZE 0x1000

%define MIO 0x100000

; Directory Page noyau :
%define PD0_ADDR 0x9F000 ; contient PT0_ADDR
%define PD1_ADDR 0x9F004 ; contient PT1_ADDR
%define PD255_ADDR 0x9F3FC ; contient PT255_ADDR

%define PT0_ADDR 0x200000 ; adresse de la première Page Table
%define PT1_ADDR 0x201000 ; adresse de la deuxième Page Table
%define PT255_ADDR 0x2FF000 ; adresse de la 255e Page Table

%define USERMODE_ADDR 0x3FC00000 ; adresse de l'adresse virtuelle par défaut de l'espace d'adressage utilisateur

%endif
