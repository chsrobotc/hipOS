 ;; about.asm - tells the basic about information
%define textcolor 0x09

%macro print 1			; parameter is the start of the string to print
	pusha
	mov bp, sp
	
	mov si, %1
	%%loop:
		mov al, [si]
		inc si
	
		or al, al	; see if were done
		jz %%exit

		mov ah, 0x0E
		mov bh, 0x0
		mov bl, textcolor

		int 0x10
		jmp %%loop

	%%exit:
	mov sp, bp
	popa

%endmacro

main:
	mov ax,cs
	mov ds,ax
	mov es,ax

	print about
	
	jmp 0x1000:0000

about db '           hipOS ver 0.04            |     created by Alex Jones', 10, 13, '     running in 16 bit real mode     |    using the NASM assembler', 10, 13, '   liscenced under the MIT license   |             enjoy!', 0
