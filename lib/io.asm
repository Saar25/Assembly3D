; ========================================
; Input/Output module
; 
; Written by: Saar ####
; 
; Set of io functions 
; ========================================
LOCALS @@

DATASEG

; DOS interrupts
io@READ_CHAR 	equ 01h
io@PRINT_CHAR   equ 02h
io@PRINT_STRING equ 09h

; Screen modes
io@TEXT_MODE  	equ 03h
io@VIDEO_MODE 	equ 13h
io@VESA_MODE 	equ 4F02h

; 1024x768
; Screen size
io@RESOLUTION_W 	equ 1024
io@RESOLUTION_H 	equ 768
io@SCREEN_W 		equ io@RESOLUTION_W
io@SCREEN_H 		equ io@RESOLUTION_H
io@SCREEN_HALF_W 	equ 512
io@SCREEN_HALF_H 	equ 384

; ; 320x200
; io@RESOLUTION_W equ 320
; io@RESOLUTION_H equ 200
; io@SCREEN_W equ io@RESOLUTION_W
; io@SCREEN_H equ io@RESOLUTION_H
; io@SCREEN_HALF_W equ 160
; io@SCREEN_HALF_H equ 100

; Special characters
io@LF_CODE equ 0Ah
io@CR_CODE equ 0Dh
io@@new_line db io@LF_CODE, io@CR_CODE, '$'

CODESEG

; Print message and new line
; 
; @ param message	[bp + 4]
proc println
	push bp
	mov bp, sp
	
	mov dx, [bp + 4]
	interrupth 21h io@PRINT_STRING
	
	mov dx, offset io@@new_line
	interrupth 21h io@PRINT_STRING
	
	pop bp
	ret
endp println

macro m_println message
	mov dx, offset message
	interrupth 21h io@PRINT_STRING
	mov dx, offset io@@new_line
	interrupth 21h io@PRINT_STRING
endm m_println

; Print message
; 
; @param message	[bp + 4]
proc print
	push bp
	mov bp, sp
	
	mov dx, [bp + 4]
	interrupth 21h io@PRINT_STRING
	
	pop bp
	ret
endp print

macro m_print message
	mov dx, offset message
	interrupth 21h io@PRINT_STRING
endm m_print

; Print character
;
; @param character
macro m_print_char val
	mov dx, val
	interrupth 21h io@PRINT_CHAR
endm m_print_char

; Print new line
;
;
macro m_new_line
	mov dx, offset io@@new_line
	interrupth 21h io@PRINT_STRING
endm m_new_line

; Print number in decimal representation
; 
; @param number	[bp + 4]
proc print_number
	push bp
	mov bp, sp
	
	mov ax, [bp + 4]
	xor cx, cx
	
	; until number is 0
	print_number_loop_1:
		; get left digit
		xor dx, dx
		mov bx, 10
		div bx
		
		; to decimal char, ax % 10 < 10h
		add dl, '0'
		push dx
		
		inc cx
		cmp ax, 0
		jne print_number_loop_1
	
	print_number_loop_2:
		pop dx
		interrupth 21h io@PRINT_CHAR
		loop print_number_loop_2
	
	pop bp
	ret
endp print_number

macro m_print_number number
	push number
	call print_number
	add sp, 2
endm m_print_number

; Print number in hexadecimal representation
; 
; @param number	[bp + 4]
proc print_number_hex
	push 	bp
	mov 	bp, sp
	
	mov 	ax, [word ptr bp + 4]
	
	push 	'$'
	xor 	dx, dx
	mov 	cx, 4
	print_number_hex_loop_1:
		mov 	dl, al
		and 	dl, 0Fh
		
		; Set dx to the character
		cmp		dx, 9
		ja		print_number_hex_if_1
			add		dx, '0'
			jmp 	print_number_hex_if_1_end
		
		print_number_hex_if_1:
			add		dx, 'A' - 10
		
		print_number_hex_if_1_end:
		push 	dx
		
		push 	cx
		mov 	cl, 4
		shr 	ax, cl
		pop 	cx
		loop 	print_number_hex_loop_1
	
	pop 	dx
	print_number_hex_loop_2:
		cmp		dx, '$'
		je 		print_number_hex_loop_2_end
		interrupth 21h io@PRINT_CHAR
		
		pop 	dx
		jmp 	print_number_hex_loop_2
	print_number_hex_loop_2_end:
	
	mov 	sp, bp
	pop 	bp
	ret
endp print_number_hex

macro m_print_number_hex number
	push number
	call print_number_hex
	add sp, 2
endm m_print_number_hex

; Print number in binary representation
; 
; @param number	[bp + 4]
proc print_number_bin
	push 	bp
	mov 	bp, sp
	
	mov 	ax, [word ptr bp + 4]
	
	push 	'$'
	print_number_bin_loop_1:
		xor 	dx, dx
		shr 	ax, 1
		adc		dx, '0'
		push 	dx
		
		cmp 	ax, 0
		jne 	print_number_bin_loop_1
	
	pop 	dx
	print_number_bin_loop_2:
		cmp		dx, '$'
		je 		print_number_bin_loop_2_end
		interrupth 21h io@PRINT_CHAR
		
		pop 	dx
		jmp 	print_number_bin_loop_2
	print_number_bin_loop_2_end:
	
	mov 	sp, bp
	pop 	bp
	ret
endp print_number_bin

macro m_print_number_bin number
	push 	number
	call 	print_number_bin
	add 	sp, 2
endm m_print_number_bin

; Read number in decimal representation
; 
; return ax
proc read_digit
	interrupth 21h, io@READ_CHAR
	sub		al, '0'
	xor 	ah, ah
	ret
endp read_digit

macro m_read_digit
	interrupth 21h, io@READ_CHAR
	sub		al, '0'
	xor 	ah, ah
endm m_read_digit