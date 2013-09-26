%define osload 0x1000
%define tableload 0x2000
%define modload 0x2400
%define userload 0xA000
%define stackstart 0xF000
%define stackend 0xE000
%define drive 0x80
%define ossect 5
%define tablesect 3
%define textcolor 0x09

[BITS 16]
[ORG 0]
jmp 0x7C0:main

main:

	mov ax,cs
	mov ds,ax
	mov es,ax
	
	call mkblue
	call setpos
	mov si, welcome
	call print

	mov ax, osload		; load some sectors up in here
	mov es, ax
	mov cl, ossect
	mov al, 2		; sectors to load

	call loadsector

	mov ax, tableload	; load some sectors up in here
	mov es, ax
	mov cl, tablesect
	mov al, 2		; sectors to load

	call loadsector
	
	jmp osload:0000		; make the jump to osland, yo

	;; functions 
	
print:
	mov al, [si]		; move the next character into al
	inc si			; look to the next sting position

	or al, al
	jz .exit		; were done here

	mov ah, 0x0E
	mov bh, 0x0
	mov bl, textcolor
	int 0x10
	
	jmp print		; do it again
	
	.exit:
		ret

mkblue:
		
	mov ah, 0x09
	mov al, 0x20
	mov bh, 0x0
	mov bl, textcolor
	mov cx, 2000
	int 0x10		; insert all the blue spaces

	ret			; leave

setpos:

	mov ah, 0x02
	mov bh, 0x00
	mov dh, 0x03
	mov dl, 0x10
	int 0x10

	ret

loadsector:

	mov bx, 0
	mov dl, drive
	mov dh, 0
	mov ch, 0
	mov ah, 2
	int 0x13
	jc .error
	ret

	.error:
		mov si, error
		mov ah, 0x02
		mov bh, 0x00
		mov dh, 0x05
		mov dl, 0x10

		call print

		mov ah, 0
		int 0x16
		int 0x19	; reboot

	;; string data

welcome db 'Loading sectors and starting OS...', 0
error db 'failure loading sectors, any key to reboot', 0
finish db 'ready to go, press any key to load the kernel', 0


	;; the rest

times 510 - ($ - $$) db 0	; fill it in with zeros
dw 0AA55h			; set it to be bootable

	
