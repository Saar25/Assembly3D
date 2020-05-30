; ========================================
; Utilities module
; 
; Written by: Saar ####
; 
; Set of utilities functions 
; ========================================
LOCALS @@

DATASEG
; Heap constants
HEAP_SIZE equ 100h

; Bit constants
BYTE_MSB equ 80h ; 1000 0000b
WORD_MSB equ 8000h ; 1000 0000 0000 0000b

; Procedure arguments
arg0 equ [bp + 4]
arg1 equ [bp + 6]
arg2 equ [bp + 8]
arg3 equ [bp + 10]
arg4 equ [bp + 12]

; Data definitions
; heap db HEAP_SIZE dup (?)
; heap_position db ?

CODESEG

macro interrupth i, val
	mov ah, val
	int i
endm interrupth

macro interruptl i, val
	mov al, val
	int i
endm interruptl

macro interruptx i, val
	mov ax, val
	int i
endm interruptx

macro m_swap a, b
	push a
	push b
	pop a
	pop b
endm m_swap

macro pushByteHeap val
	mov bp, sp
	mov bl, offset heap
	add bl, [heap_position]
	mov bl, [byte ptr bl]
	mov [byte ptr bp + 4], bl
endm pushByteHeap

macro pushWordHeap val
	mov bp, sp
	mov bl, offset heap
	add bl, [heap_position]
	int [heap_position]
	mov bl, [word ptr bl]
	mov [word ptr bp + 4], bx
endm pushWordHeap

; Copy buffer to another buffer
;
; @param ptr src	[bp + 8]
; @param ptr dest	[bp + 6]
; @param length		[bp + 4]
proc copy
	push bp
	mov bp, sp
	
	; loop from 0 to length
	mov cx, 0
	copy_loop_1:
		; get source value
		mov bx, [bp + 8]
		add bx, cx
		mov ax, [bx]
		
		; set destination value
		mov bx, [bp + 6]
		add bx, cx
		mov [bx], ax
		
		cmp cx, [bp + 4]
		je copy_loop_1
	
	pop bp
	ret
endp copy

macro m_copy src, dest, len
	push src
	push dest
	push len
	call copy
	add sp, 6
endm m_copy