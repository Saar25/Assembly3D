; ========================================
; Main module
; 
; Written by: Saar ####
; ========================================

IDEAL
MODEL small
STACK 100h

; Includes
include "lib/util.asm"
include "lib/io.asm"
include "lib/file.asm"
include "lib/math.asm"
include "lib/graphics.asm"
include "lib/vectors.asm"

; Data segment
DATASEG
	
	color db 1
	pointOne dd 3dcccccdh
	
	Vec3f camera,  00000000h, 00000000h, 3f000000h;0, 0, .5
	Vec3f vertex1, 41200000h, 41200000h, 40000000h ;10, 10, 2
	Vec3f vertex2, 44480000h, 43960000h, 40000000h ;800, 300, 2
	Vec2w pixel1, ?, ?
	Vec2w pixel2, ?, ?
	
; Code segment
CODESEG

main:
	mov ax, @data
	mov ds, ax
	
	; Video mode
	;interruptx 10h, io@VIDEO_MODE
	
	; 1024x768
	mov ax, io@VESA_MODE
	mov bx, 105h
	int 10h
	
	
repaint:
	; Set background
	m_draw_background 11h
	mov ax, io@VESA_MODE
	mov bx, 105h
	int 10h
	
	; Project vertices
	m_fproject camera, vertex1, pixel1
	m_fproject camera, vertex2, pixel2
	
	; Draw line
	push 	[pixel1 + 0]
	push 	[pixel1 + 2]
	push 	[pixel2 + 0]
	push 	[pixel2 + 2]
	push 	2
	call 	draw_line
	add 	sp, 10
	
	; Wait for input
	interrupth 21h, 08h
	xor ah, ah
	
	; Input in ax
	
	fld [dword ptr pointOne]
	fadd [dword ptr camera + 8]
	fstp [dword ptr camera + 8]
	
	cmp ax, 27
	jne repaint
ending:

	; Text mode
	interruptx 10h, io@TEXT_MODE
	
exit:
	mov ax, 4c00h
	int 21h
end main