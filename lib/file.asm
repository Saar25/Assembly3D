; ========================================
; File handling module
; 
; Written by: Saar ####
; 
; Set of file handling functions 
; ========================================
LOCALS @@

DATASEG

file@@FILE_NOT_FOUND db 02h, "File not found$"
file@@TOO_MANY_FILES db 05h, "Too many opened files$"
file@@ACCESS_DENIED  db 0Ch, "Access to file denied$"

file@@READ_ONLY 		equ 0
file@@WRITE_ONLY 		equ 1
file@@READ_AND_WRITE 	equ 2

CODESEG

; Print file exception
;
; @param exceptionCode	[bp + 4]
proc file@@printException
	push 	bp
	mov 	bp, sp
	
	@@exceptionCode equ [word ptr bp + 4]
	
	mov 	ax, @@exceptionCode
	
	lea 	dx, [file@@FILE_NOT_FOUND + 1]
	cmp 	al, [file@@FILE_NOT_FOUND]
	je file@@printException@@printAndRet
	
	lea 	dx, [file@@TOO_MANY_FILES + 1]
	cmp 	al, [file@@TOO_MANY_FILES]
	je file@@printException@@printAndRet
	
	lea 	dx, [file@@ACCESS_DENIED + 1]
	cmp 	al, [file@@ACCESS_DENIED]
	je file@@printException@@printAndRet
	
	jmp file@@printException@ret
	
	file@@printException@@printAndRet:
	push 	dx
	call 	println
	add 	sp, 2
	
	file@@printException@ret:
	
	pop 	bp
	ret
endp file@@printException

; Open the given file
;
; @param usage		[bp + 6]
; @param fileName	[bp + 4]
proc file@@openFile
	push 	bp
	mov 	bp, sp
	
	@@usage 	equ [byte ptr bp + 6]
	@@fileName 	equ [word ptr bp + 4]
	
	mov 	al, @@usage
	mov 	dx, @@fileName
	interrupth 21h, 3Dh
	
	jnc		file@@openFile@@NoError
		push 	ax
		call 	file@@printException
		add 	sp, 2
	file@@openFile@@NoError:
	
	pop bp
	ret
endp file@@openFile

macro file@@m_openFile usage, fileName
	mov 	ax, usage
	push	ax
	lea 	ax, fileName
	push	ax
	call 	file@@openFile
	add 	sp, 2
endm file@@m_openFile

; Read the given file
;
; @param fileHandle 	[bp + 8]
; @param targetBuffer	[bp + 6]
; @param numOfBytes 	[bp + 4]
proc file@@readFile
	push bp
	mov bp, sp
	
	@@fileHandle 	equ [word ptr bp + 8]
	@@targetBuffer 	equ [word ptr bp + 6]
	@@numOfBytes 	equ [word ptr bp + 4]
	
	; Read file
	mov 	bx, @@fileHandle
	mov 	cx, @@numOfBytes
	mov 	dx, @@targetBuffer
	interrupth 21h, 3Fh
	
	pop bp
	ret
endp file@@readFile

macro file@@m_readFile fileHandle, targetBuffer, numOfBytes
	push fileHandle
	lea ax, targetBuffer
	push ax
	mov ax, numOfBytes
	push ax
	call file@@readFile
	add sp, 6
endm file@@m_readFile

; Close the given file
;
; @param fileHandle	[bp + 4]
proc file@@closeFile
	push 	bp
	mov 	bp, sp
	
	@@fileHandle 	equ [word ptr bp + 4]
	
	mov 	bx, @@fileHandle
	interrupth 21h, 3Eh
	
	pop bp
	ret
endp file@@closeFile

macro file@@m_closeFile fileHandle
	mov 	bx, fileHandle
	interrupth 21h, 3Eh
endm file@@m_closeFile