; ========================================
; Graphics module
; 
; Written by: Saar ####
; 
; Set of functions for displaying graphics
; on the screen
; ========================================

CODESEG

; Draw pixel
;
; @param x		[bp + 8]
; @param y		[bp + 6]
; @param color	[bp + 4]
proc draw_pixel
	push bp
	mov bp, sp
	
	mov bh, 00h
	mov cx, [bp + 8]
	mov dx, [bp + 6]
	mov al, [byte ptr bp + 4]
	interrupth 10h, 0Ch
	
	pop bp
	ret
endp draw_pixel

macro m_draw_pixel x, y, color
	push x
	push y
	push color
	call draw_pixel
	add sp, 6
endm m_draw_pixel

; Draw rectangle
;
; @param x		[bp + 12]
; @param y		[bp + 10]
; @param width	[bp + 8]
; @param height	[bp + 6]
; @param color	[bp + 4]
proc draw_rectangle
	push bp
	mov bp, sp
	
	mov cx, 0
	draw_rectangle_loop_1:
		push cx
		mov cx, 0
		draw_rectangle_loop_2:
			push cx
			push dx
			
			mov bh, 00h
			add cx, [bp + 12]
			
			cmp cx, io@SCREEN_W
			jb @@outside_screen
			
			mov dx, [bp - 2]
			add dx, [bp + 10]
			
			cmp dx, io@SCREEN_H
			jb @@outside_screen
			
			mov al, [byte ptr bp + 4]
			interrupth 10h, 0Ch
			
			@@outside_screen:
			
			pop dx
			
			pop cx
			inc cx
			cmp cx, [bp + 8]
			jne draw_rectangle_loop_2
		pop cx
		inc cx
		cmp cx, [bp + 6]
		jne draw_rectangle_loop_1
	pop bp
	ret
endp draw_rectangle

macro m_draw_rectangle x, y, w, h, color
	push x
	push y
	push w
	push h
	push color
	call draw_rectangle
	add sp, 10
endm m_draw_rectangle

; Draw background
;
; @param color	[bp + 4]
macro m_draw_background color
	mov 	ax, 0600h
	mov 	bh, color
	mov 	cx, 0000h
	mov 	dx, 184fh
	int 	10h
endm m_draw_background

proc draw_background
	push 	bp
	mov 	bp, sp
	
	mov 	ax, 0600h
	mov 	bh, [byte ptr bp + 4]
	mov 	cx, 0000h
	mov 	dx, 184Fh
	int 	10h
	
	mov ax,0600h
	mov bh,17h
	mov cx,0000h
	mov dx,184fh
	int 10h
	
	pop 	bp
	ret
endp draw_background

; Draw line
;
; @param x1		[bp + 12]
; @param y1		[bp + 10]
; @param x2		[bp + 8]
; @param y2		[bp + 6]
; @param color	[bp + 4]
proc draw_line
	push 	bp
	mov 	bp, sp
	sub 	sp, 4
	
	; args
	draw_line_x1 	equ [word ptr bp + 12]
	draw_line_y1 	equ [word ptr bp + 10]
	draw_line_x2 	equ [word ptr bp + 8]
	draw_line_y2	equ [word ptr bp + 6]
	draw_line_color equ [byte ptr bp + 4]
	
	; vars
	draw_line_dltX	equ [word ptr bp - 2]
	draw_line_dltY	equ [word ptr bp - 4]
	
	; make sure second point is to the right
	mov 	ax, draw_line_x2
	cmp 	ax, draw_line_x1
	ja 		draw_line_x2_is_above
		m_swap draw_line_x1, draw_line_x2
		m_swap draw_line_y1, draw_line_y2
	draw_line_x2_is_above:
	
	; compute delta x
	mov 	ax, draw_line_x2
	sub 	ax, draw_line_x1
	mov 	draw_line_dltX, ax
	
	; compute delta y
	mov 	bx, draw_line_y2
	sub 	bx, draw_line_y1
	mov 	draw_line_dltY, bx
	
	cmp 	ax, bx
	jge 	draw_line_x_is_bigger
	
	mov 	dx, 0
	draw_line_y_loop:
		push	dx
		; compute x (= stepY * dltX / dltY + x1)
		; compute y (= stepY + y1)
		push 	dx
		mov 	ax, dx
		xor 	dx, dx
		imul 	draw_line_dltX
		idiv 	draw_line_dltY
		mov 	cx, ax
		pop 	dx
		
		add		cx, draw_line_x1
		add		dx, draw_line_y1
		
		cmp cx, io@SCREEN_W
		jae @@draw_line_outside_screen1
		cmp dx, io@SCREEN_H
		jae @@draw_line_outside_screen1
		
		mov 	bh, 00h
		mov 	al, draw_line_color
		interrupth 10h, 0Ch
		
		@@draw_line_outside_screen1:
		
		pop		dx
		inc 	dx
		cmp 	dx, draw_line_dltY
		jb 		draw_line_y_loop
	
	jmp 	draw_line_done
	draw_line_x_is_bigger:
	
	mov 	cx, 0
	draw_line_x_loop:
		push 	cx
		; compute x (= stepX + x1)
		; compute y (= stepX * dltY / dltX + y1)
		mov 	ax, cx
		xor		dx, dx
		imul 	draw_line_dltY
		idiv 	draw_line_dltX
		mov 	dx, ax
		
		add		cx, draw_line_x1
		add		dx, draw_line_y1
		
		cmp cx, io@SCREEN_W
		jae @@draw_line_outside_screen2
		cmp dx, io@SCREEN_H
		jae @@draw_line_outside_screen2
		
		mov 	bh, 00h
		mov 	al, draw_line_color
		interrupth 10h, 0Ch
		
		@@draw_line_outside_screen2:
		
		pop 	cx
		inc 	cx
		mov 	ax, draw_line_dltX
		cmp 	cx, ax
		jb 		draw_line_x_loop
	
	draw_line_done:
	
	mov 	sp, bp
	pop 	bp
	ret
endp draw_line

macro m_draw_line x1, y1, x2, y2, color
	push x1
	push y1
	push x2
	push y2
	push color
	call draw_line
	add sp, 10
endm m_draw_line