%define MULTIBOOT_HEADER_MAGIC 0xE85250D6
%define MULTIBOOT_HEADER_FLAGS 0x00000000 ; 0 pour i386, 4 pour MIPS
%define CHECKSUM 0x100000000-(MULTIBOOT_HEADER_MAGIC + MULTIBOOT_HEADER_FLAGS + )

section .multiboot_header
multiboot_header_start:
	dd MULTIBOOT_HEADER_MAGIC
	dd MULTIBOOT_HEADER_FLAGS ; protected mode i386
	dd multiboot_header_end - multiboot_header_start ; header length
	dd 0x100000000 - (MULTIBOOT_HEADER_MAGIC + MULTIBOOT_HEADER_FLAGS + (multiboot_header_end - multiboot_header_start))
	; END TAG :
	dw 0 ; type
	dw 0 ; flags
	dd 8 ; size
multiboot_header_end:
