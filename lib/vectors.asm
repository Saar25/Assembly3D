; ========================================
; Vectors module
; 
; Written by: Saar ####
; 
; Set of functions for handling vectors
; and creating vectors
; ========================================

CODESEG

; Creates 3 floats vector
; 
; @param var	the vector name
; @param x		the x component
; @param y		the y component
; @param z		the z component
macro Vec3f var, x, y, z
	var dd x, y, z
endm Vec3f

; Creates 3 dwords vector
; 
; @param var	the vector name
; @param x		the x component
; @param y		the y component
; @param z		the z component
macro Vec3d var, x, y, z
	var dd x, y, z
endm Vec3d

; Creates 3 words vector
; 
; @param var	the vector name
; @param x		the x component
; @param y		the y component
; @param z		the z component
macro Vec3w var, x, y, z
	var dw x, y, z
endm Vec3w

; Creates 3 bytes vector
; 
; @param var	the vector name
; @param x		the x component
; @param y		the y component
; @param z		the z component
macro Vec3b var, x, y, z
	var db x, y, z
endm Vec3b

; Creates 2 floats vector
; 
; @param var	the vector name
; @param x		the x component
; @param y		the y component
macro Vec2f var, x, y
	var dd x, y
endm Vec2f

; Creates 2 dwords vector
; 
; @param var	the vector name
; @param x		the x component
; @param y		the y component
macro Vec2d var, x, y
	var dd x, y
endm Vec2d

; Creates 2 words vector
; 
; @param var	the vector name
; @param x		the x component
; @param y		the y component
macro Vec2w var, x, y
	var dw x, y
endm Vec2w

; Creates 2 bytes vector
; 
; @param var	the vector name
; @param x		the x component
; @param y		the y component
macro Vec2b var, x, y
	var db x, y
endm Vec2b

; Sets a 3 floats vector 
; 
; @param vector	the vector
; @param x		the x component
; @param y		the y component
; @param z		the z component
macro setVec3f vector, x, y, z
	push bp
	mov bp, sp
	sub sp, 2
	mov [word ptr bp - 2], x
	fild [word ptr bp - 2]
	fstp [dword ptr vector + 00h]
	mov [word ptr bp - 2], y
	fild [word ptr bp - 2]
	fstp [dword ptr vector + 04h]
	mov [word ptr bp - 2], z
	fild [word ptr bp - 2]
	fstp [dword ptr vector + 08h]
endm setVec3f

; Sets a 3 dwords vector
; 
; @param vector	the vector
; @param x		the x component
; @param y		the y component
; @param z		the z component
macro setVec3w vector, x, y, z
	mov [dword ptr vector + 00h], x
	mov [dword ptr vector + 02h], y
	mov [dword ptr vector + 04h], z
endm setVec3w

; Sets a 3 words vector
; 
; @param vector	the vector
; @param x		the x component
; @param y		the y component
; @param z		the z component
macro setVec3w vector, x, y, z
	mov [word ptr vector + 00h], x
	mov [word ptr vector + 02h], y
	mov [word ptr vector + 04h], z
endm setVec3w

; Sets a 2 words vector
; 
; @param vector	the vector
; @param x		the x component
; @param y		the y component
macro setVec2w vector, x, y
	mov [word ptr vector + 00h], x
	mov [word ptr vector + 02h], y
endm setVec2w

; =================
; =	Float Setters =
; =================

macro setXf vector, x
	fild x
	fstp [word ptr vector + 00h]
endm setXw

macro setYf vector, y
	fild y
	fstp [word ptr vector + 04h]
endm setYw

macro setZf vector, z
	fild z
	fstp [word ptr vector + 08h]
endm setZw

; ================
; =	Word Setters =
; ================

macro setXw vector, x
	mov [word ptr vector + 00h], x
endm setXw

macro setYw vector, y
	mov [word ptr vector + 02h], y
endm setYw

macro setZw vector, z
	mov [word ptr vector + 04h], z
endm setZw

; ================
; =	Byte Setters =
; ================

macro setXb vector, x
	mov [word ptr vector + 00h], x
endm setXb

macro setYb vector, y
	mov [word ptr vector + 02h], y
endm setYb

macro setZb vector, z
	mov [word ptr vector + 04h], z
endm setZb

; =================
; =	DWord Getters =
; =================

macro getXd vector
	mov ax, [word ptr vector + 00h]
	mov dx, [word ptr vector + 02h]
endm getXd

macro getYd vector
	mov ax, [word ptr vector + 04h]
	mov dx, [word ptr vector + 06h]
endm getYd

macro getZd vector
	mov ax, [word ptr vector + 08h]
	mov dx, [word ptr vector + 0Ah]
endm getZd

; ================
; =	Word Getters =
; ================

macro getXw vector
	mov ax, [word ptr vector + 00h]
endm getXw

macro getYw vector
	mov ax, [word ptr vector + 02h]
endm getYw

macro getZw vector
	mov ax, [word ptr vector + 04h]
endm getZw

; ================
; =	Byte Getters =
; ================

macro getXb vector
	mov al, [byte ptr vector + 00h]
endm getXb

macro getYb vector
	mov al, [byte ptr vector + 01h]
endm getYb

macro getZb vector
	mov al, [byte ptr vector + 02h]
endm getZb
