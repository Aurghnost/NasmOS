%include "kernel/pic.inc"

[BITS 32]

pic__init:
push word ax
	mov al, 0x11
	out 0x20, al ; Initialisation de ICW1
	jmp .1 ; Temporisation nécessaire entre chaque initialisation de registre du controleur
	.1:
	out 0xA0, al
	jmp .2
	.2:
	mov al, 0x20
	out 0x21, al ; Initialisation de ICW2
	jmp .3
	.3:
	mov al, 0x70
	out 0xA1, al
	jmp .4
	.4:
	mov al, 0x04
	out 0x21, al ; Initialisation de ICW3
	jmp .5
	.5:
	mov al, 0x02
	out 0xA1, al
	jmp .6
	.6:
	mov al, 0x01
	out 0x21, al ; Initialisation de ICW4
	jmp .7
	.7:
	out 0xA1, al
	jmp .8
	.8:
	mov al, 0x0 ; mise à 0 pour débloquer toutes les IRQs (IRQ 0-7)
	out 0x21, al ; Modification du registre OCW1 du controleur maitre
	jmp .9
	.9:
	out 0xA1, al ; idem pour le registre OCW1 du controleur esclave
pop word ax
ret