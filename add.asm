  ;; add.asm - adds two integers
%define textcolor 0x09
%define params 0x200

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

%macro mkchar 1
	pusha
	mov bp, sp

	mov al, %1
	mov ah, 0x0E
	mov bh, 0x0
	mov bl, textcolor
	int 0x10

	mov sp, bp
	popa
%endmacro

%macro tonum 1
	sub %1, 48
%endmacro

%macro tochar 1
	add %1, 48
%endmacro

main:
	mov ax,cs
	mov ds,ax
	mov es,ax
	
	mov si, params
	
	.getend:
		inc si
		cmp [si], 0
		jne .getend
		
	dec si
	
	;; now si is at the end of our text get the last number
	mov al, 0
	mov ax, 0
	mov bx, 0
	
	.lastnum:
		mov ah, [si]
		tonum ah
		inc al
		dec si
		call raise
		add ax, dx
		
		cmp [si], ' '
		jne .lastnum
	mov al, 0
	
	.firstnum:
		mov ah, [si]
		tonum ah
		inc al
		dec si
		call raise
		add bx, dx
		
		cmp si, params
		jne .firstnum
		
	add ax, bx
	
	call mknum

	jmp 0x1000:0000
	
	
raise:
	mov cx, ah
	mov bh, al
	dec bh
	.loop:
		shl cx, 1
		mov dx, cx
		shl cx, 1
		shl cx, 1
		add dx, cx
		
		cmp bh, 0
		jne .loop
	ret
	
mknum:
	mov bx, ax
	mod bx, 10
	tochar bx
	mkchar bl
	ret
