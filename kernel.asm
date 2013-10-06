%define textcolor 0x09
%define filetable 0x10000
	
[BITS 16]
[ORG 0]
	;; well, this is my kernel. I think it will be kinda cool if it actually can do something...

	;; what it should be able to do:
	;; - run a simple command line
	;; - load external programs into the ram
	;; - run those programs through a simple terminal
	;; - do it in 16 bit real mode because its so much easier

	;; ------------------------------------ MACROS --------------------------------------- ;;
	
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
	
%macro setline 2		; x and y are put

	mov ah, 0x02
	mov bh, 0x00
	mov dh, %1
	mov dl, %2
	int 0x10

%endmacro

%macro tonum 1
	sub %1, 48
	
%endmacro

%macro tochar 1
	add %1, 48
%endmacro
	
		

	;; ---------------------------------- actual start ------------------------------------- ;;

	
real:
	mov ax, cs		; setup the segment pointers
	mov ds, ax
	mov es, ax
	mov ax, 0x7000
	mov ss, ax
	mov sp, ss
	
	call init

	call input
	
	jmp $			; just keep looping


	;; functions ;;
	
init:
	call clear
	setline 0,0
	print version
	print newline
	print cursor

	ret

input:
	mov ah, 0x00
	int 0x16		; wait for a keypress

	cmp al, 13
	je enter

	cmp al, 08
	je backspace

	cmp al, 0x1B
	je exit

	
	mov si, command
	add si, [chars]
	inc byte [chars]
	
	mov [si], al
	mkchar al

	jmp input

enter:
	print newline
	mov byte [chars], 0

	;; compare to file table here
	inc byte [recurselevel]
	jmp find
	
reset:	call resetcommand
	print newline
	print cursor
	jmp input

backspace:
	mov ah, 0x03
	mov bh, 0x00
	int 0x10 		; get the cursor position

	cmp dl, 2
	jle input

	print back
	dec byte [chars]

	jmp input

exit:
	;mov ax, 0x5307
	;mov bx, 0x0000
	;mov cx, 0x0003
	;int 0x15
	mkchar 0x07
	jmp input
	
clear:
	setline 0,0
	mov ah, 0x09
	mov al, 0x20
	mov bh, 0x0
	mov bl, textcolor
	mov cx, 2000
	int 0x10		; insert all the blue spaces

	ret			; leave

resetcommand:

	mov di, command
	mov ah, 0

	.loop:
		cmp ah, 50
		je .end
		mov byte [di], 0
		inc di
		inc ah
		jmp .loop
	.end:
		mkchar '*'
		print command
		ret

find:				; locate the correct module
	mov ecx, filetable
	mov ebx, command
	
	.nextlabel:

		cmp byte [ecx], '^'
		je .notfound

		cmp byte [ecx], '~'
		je .inclabel
	
		inc ecx
		jmp .nextlabel
	
	.inclabel:
		mov ebx, command
		inc ecx
		jmp .cmplabel

	.cmplabel:
		cmp byte [ecx], ':'
		je .found

		
		mov al, [ebx]
		cmp [ecx], al
		jne .nextlabel

		inc ecx
		inc ebx
		jmp .cmplabel

	.found:
		cmp byte [ebx], 0x00
		je .done

		cmp byte [ebx], 0x20
		je .done

		jmp .nextlabel
	
	.notfound:
		mov ecx, 0
		print notfound
		print command
		jmp reset

	.done:
	;; ok, now we found the module from the table, i need to:
	;; A: read the sector vector (lol) and load
	;; B: read the dependancies one by one
	;; C: recuse through all of them
	;; D: jump to correct place
		jmp getsectors

getdeps:
	
	inc ecx
	
	mov di, command
	.move:
		cmp byte [ecx], ','	; this is the end of the text, bring this through
		je .recurse

		cmp byte [ecx], ':'
		je .uncurse	; load the module itself

		mov al, [ecx]
		mov [di], al
		inc di
		inc ecx

		jmp .move

	.recurse:
		inc byte [recurselevel]
		push ecx	; remember where the resouce pointer is
		jmp find	; start the process again

	.uncurse:
		call getsectors	; get and load the sectors for the dependancy
		dec byte [recurselevel]

		cmp byte [recurselevel], 0
		je .done

		pop ecx
		jmp getdeps

		

	.done:
		jmp reset	; eventually load program and run

	
getsectors:
	inc ecx	
	mov dl, [ecx]
	mov [sectorholder], dl
	times 2 inc ecx
	mov dl, [ecx]
	mov [sizeholder], dl
	inc ecx
		
	tochar byte [sectorholder]
	tochar byte [sizeholder]
	mkchar byte [sectorholder]
	mkchar byte [sizeholder]

	jmp reset
	;jmp loadsectors

	;; string constants ;;
	
hello db 'Hello World!', 0
newline db 10, 13, 0
cursor db '> ', 0
notfound db 'module not found: ', 0
back db 0x8, 0x20, 0x8, 0
chars dw 0
command times 50 db 0
nullbyte db 0
sectorholder dw 0
sizeholder dw 0
recurselevel dw 0
multarea dw 0

version db 'hipOS ver. 0.02', 10, 13, 0
