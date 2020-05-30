; ========================================
; Math module
; 
; Written by: Saar ####
; 
; Set of functions for computing various
; mathematic functions
; ========================================
LOCALS @@

DATASEG

; Float constants
math@FHALF 	dd 0000003fh
math@PI 	dd 40490fdbh

CODESEG

; Calculates power
;
; @param base		[bp + 6]
; @param exponent	[bp + 4]
proc pow
	push bp
	mov bp, sp
	
	mov ax, 1
	mov cx, [bp + 4]
	
	pow_loop_1:
		mul [word ptr bp + 6]
		loop pow_loop_1
	
	pop bp
	ret
endp pow

macro m_pow b, e
	push b
	push e
	call pow
	add sp, 4
endm m_pow

; Project 3d point to 2d
; Using the formula
; (screenX, screenY) = 
;		(worldX, worldY) / worldZ
;
; @param camera	[bp + 8]
; @param vertex	[bp + 6]
; @param dest	[bp + 4]
proc project
	push 	bp
	mov 	bp, sp
	
	@@dest	 equ [word ptr bp + 8]
	@@vertex equ [word ptr bp + 6]
	@@dest   equ [word ptr bp + 4]
	
	; compute view space z value
	mov 	bx, @@vertex
	mov 	cx, [word ptr bx + 4]
	mov 	bx, @@dest
	sub 	cx, [word ptr bx + 4]
	
	; compute view space x value
	mov 	bx, @@vertex
	mov 	ax, [word ptr bx + 0]
	mov 	bx, @@dest
	sub 	ax, [word ptr bx + 0]
	
	; compute screen space x value
	xor 	dx, dx
	idiv 	cx
	push 	ax
	
	; compute view space y value
	mov 	bx, @@vertex
	mov 	ax, [word ptr bx + 2]
	mov 	bx, @@dest
	sub 	ax, [word ptr bx + 2]
	
	; compute screen space y value
	xor 	dx, dx
	idiv 	cx
	push 	ax
	
	; copy to destination
	mov 	bx, @@dest
	pop 	[word ptr bx + 2]
	pop 	[word ptr bx + 0]
	
	add 	[word ptr bx + 0], io@SCREEN_HALF_W
	add 	[word ptr bx + 2], io@SCREEN_HALF_H
	
	mov		al, [byte ptr bx + 2]
	mov 	[byte ptr bx + 3], al
	mov 	[byte ptr bx + 2], 0
	
	mov		al, [byte ptr bx + 0]
	mov 	[byte ptr bx + 1], al
	mov 	[byte ptr bx + 0], 0
	
	pop 	bp
	ret
endp project

macro m_project camera, vertex, dest
	lea 	ax, [camera]
	push	ax
	lea		ax, [vertex]
	push	ax
	lea 	ax, [dest]
	push	ax
	call 	project
	add		sp, 6
endm m_project

; Project Vec3d into a Vec2w 
; Using the formula
; (screenX, screenY) = 
;		(worldX, worldY) / worldZ
;
; @param word camera	[bp + 8]
; @param word vertex	[bp + 6]
; @param word dest		[bp + 4]
proc projectVec3d
	push 	bp
	mov 	bp, sp
	
	sub sp, 4
	
	; args
	projectVec3d_camera equ [word ptr bp + 8]
	projectVec3d_vertex equ [word ptr bp + 6]
	projectVec3d_dest	equ [word ptr bp + 4]
	
	; vars
	projectVec3d_depthf equ [word ptr bp - 2]
	projectVec3d_depthi equ [word ptr bp - 4]
	
	; compute view space z value (zVertex - z@@camera)
	mov 	bx, [word ptr bp + 06h]
	mov 	ax, [word ptr bx + 0Ch]
	mov 	dx, [word ptr bx + 08h]
	mov 	bx, [word ptr bp + 08h]
	sub 	ax, [word ptr bx + 0Ch]
	sub 	dx, [word ptr bx + 08h]
	mov		projectVec3d_depthi, ax
	mov		projectVec3d_depthf, ax
	
	; compute view space x value (xVertex - x@@camera)
	mov 	bx, [word ptr bp + 6]
	mov 	ax, [word ptr bx + 0]
	mov 	bx, [word ptr bp + 8]
	sub 	ax, [word ptr bx + 0]
	
	; compute screen space x value (xView / depth)
	xor 	dx, dx
	div 	cx
	push 	ax
	
	; compute view space y value (yVertex - y@@camera)
	mov 	bx, [word ptr bp + 6]
	mov 	ax, [word ptr bx + 2]
	mov 	bx, [word ptr bp + 8]
	sub 	ax, [word ptr bx + 2]
	
	; compute screen space y value (yView / depth)
	xor 	dx, dx
	div 	cx
	push 	ax
	
	; copy to destination
	mov 	bx, [word ptr bp + 4]
	pop 	[word ptr bx + 2]
	pop 	[word ptr bx + 0]

	add 	[word ptr bx + 0], io@SCREEN_HALF_W
	add 	[word ptr bx + 2], io@SCREEN_HALF_H
	
	pop 	bp
	ret
endp projectVec3d

macro m_projectVec3d camera, vertex, dest
	lea 	ax, [camera]
	push	ax
	lea		ax, [vertex]
	push	ax
	lea 	ax, [dest]
	push	ax
	call 	project
	add		sp, 6
endm m_projectVec3d

; Project Vec3f point to Vec2w
;
; @param camera	[bp + 8]
; @param vertex	[bp + 6]
; @param dest	[bp + 4]
proc fproject
	; Vec3f d = {vertex.x - camera.x,
	; 			 vertex.y - camera.y,
	; 			 vertex.z - camera.z};
	; Vec3f c = {cos(rotation.x),
	; 			 cos(rotation.y),
	; 			 cos(rotation.z)};
	; Vec3f s = {sin(rotation.x),
	; 			 sin(rotation.y),
	;			 sin(rotation.z)};
	; 
	; 
	; temp.x = c.y * (s.z * d.y - c.z * d.x) - s.y * d.z;
	; temp.y = s.x * (c.y * d.z + s.y * (s.z * d.y + c.z * d.x)) + c.x * (c.z * d.y - s.z * d.x);
	; temp.z = c.x * (c.y * d.z + s.y * (s.z * d.y + c.z * d.x)) - s.x * (c.z * d.y - s.z * d.x);
	; 
	; result.x = temp.x / temp.z;
	; result.y = temp.y / temp.z;
	
	push 	bp
	mov 	bp, sp
	sub		sp, 12h
	
	; arguments
	@@camera 	equ [word ptr bp + 8]
	@@vertex	equ [word ptr bp + 6]
	@@dest 		equ [word ptr bp + 4]
	
	; variables
	@@tempInteger	equ [word ptr bp - 12h]
	@@tempFloat 	equ [dword ptr bp - 10h]
	@@tempVec		equ [dword ptr bp - 0Ch]
	
	; compute view space z value
	mov bx, @@vertex
	fld [dword ptr bx + 8]
	mov bx, @@camera
	fsub [dword ptr bx + 8]
	fstp @@tempFloat
	
	; compute view space x value
	mov bx, @@vertex
	fld [dword ptr bx + 0]
	mov bx, @@camera
	fsub [dword ptr bx + 0]
	fdiv @@tempFloat
	lea bx, @@tempVec
	fstp [dword ptr bx + 0]
	
	; compute view space y value
	mov bx, @@vertex
	fld [dword ptr bx + 4]
	mov bx, @@camera
	fsub [dword ptr bx + 4]
	fdiv @@tempFloat
	lea bx, @@tempVec
	fstp [dword ptr bx + 4]
	
	; compute screen space x value
	mov 	@@tempInteger, io@SCREEN_W
	fild	@@tempInteger
	fmul 	[dword ptr math@FHALF]
	lea 	bx, @@tempVec
	fadd 	[dword ptr bx + 0]
	mov		bx, @@dest
	fistp	[word ptr bx + 0]
	
	; compute screen space y value
	mov 	@@tempInteger, io@SCREEN_H
	fild	@@tempInteger
	fmul 	[dword ptr math@FHALF]
	lea 	bx, @@tempVec
	fadd 	[dword ptr bx + 4]
	mov		bx, @@dest
	fistp	[word ptr bx + 2]
	
	mov		sp, bp
	pop 	bp
	ret
endp fproject

macro m_fproject camera, vertex, dest
	lea 	ax, [word ptr camera]
	push	ax
	lea		ax, [word ptr vertex]
	push	ax
	lea 	ax, [word ptr dest]
	push	ax
	call 	fproject
	add		sp, 6
endm m_fproject