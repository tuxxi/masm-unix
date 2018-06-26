; Along32 Link Library Source Code ( Along32.asm )
; Copyright (C) 2009 Curtis Wong.
; All right reserved.
; Email: airekans@gmail.com
; Homepage: http://along32.sourceforge.net
;
; This file is part of Along32 library.
;
; Along32 library is free software: you can redistribute it and/or modify
; it under the terms of the GNU Lesser General Public License as
; published by the Free Software Foundation, either version 3 of the
; License, or(at your option) any later version.
;
; Along32 library is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU Lesser General Public License for more details.
;
; You should have received a copy of the GNU Lesser General Public License
; along with Along32 library.  If not, see <http://www.gnu.org/licenses/>.
;
;
; Recent Updates:
; 2009/05/25: The main body of this file
; 2009/08/19: add comments
; 2010/04/15: fix the bug in ReadInt, and a bug in ReadHex. ReadHex will
;             generate a segmentation fault.
;
; This library was created by Curtis Wong, for use with the book,
; "Assembly Language for Intel-based Computers", 4th Edition & 5th Edition,
; modified from Irvine32.asm.
;
; Function Prototypes
; -------------- global functions ------------
; Clrscr : Writes a carriage return / linefeed
; Crlf : output a new line
; Delay : Delay certain microseconds
; Gotoxy : Locate the cursor
; IsDigit : Determines whether the character in AL is a valid decimal digit.
; DumpMem : Writes a range of memory to standard output in hexadecimal.
; ParseDecimal32: convert the number string to a decimal number
; ParseInteger32 : Converts a string containing a signed decimal integer to binary.
; Str_length : compute the length of null-teminated string
; Str_compare : Compare two strings.
; Str_trim : Remove all occurences of a given character from the end of a string.
; Str_ucase : Convert a null-terminated string to upper case.
; BufferFlush: flush the buffer and reset the related variables
; Random32 : Generates an unsigned pseudo-random 32-bit integer
; Randomize : Re-seeds the random number generator with the current time in seconds.
; RandomRange : Returns an unsigned pseudo-random 32-bit integer in EAX, between 0 and n-1.
; ReadKeys: read certain number of characters from buffer
; ReadDec : read Decimal number from buffer
; ReadHex : Reads a 32-bit hexadecimal integer from the keyboard
; ReadInt : Reads a 32-bit signed decimal integer from standard input
; ReadString : read string from input buffer
; ReadChar : read a character from stdin
; WriteBin : write a 32-bit binary number to console( interface )
; WriteBinB : write a 32-bit binary number to console
; WriteChar : write a character to stdout
; WriteDec : write a decimal number to stdout
; WriteHex : Writes an unsigned 32-bit hexadecimal number to the console window.
; WriteHexB : Writes an unsigned 32-bit hexadecimal number to the console window.
; WriteInt : Writes a 32-bit signed binary integer to the console window in ASCII decimal.
; WriteString : output a null-terminated string
; -------------- private functions -----------
; AsciiDigit : convert the actual number to ascii represetation
; HexByte : Display the byte in AL in hexadecimal

%include "Macros_Along.inc"

%ifnmacro ShowFlag
;---------------------------------------------------------------------
%macro ShowFlag 2.nolist
;
; Helper macro.
; Display a single CPU flag value
; Directly accesses the eflags variable in Along32.asm
; (This macro cannot be placed in Macros.inc)
;---------------------------------------------------------------------

segment .data
%%flagStr: db "  ", %1, "="
%%flagVal: db 0, 0

segment .text
	push eax
	push edx

	mov  eax, dword [eflags]; retrieve the flags
	mov  byte [%%flagVal], '1'
	shr  eax, %2		; shift into carry flag
	jc   %%L1
	mov  byte [%%flagVal], '0'
%%L1:
	mov  edx, %%flagStr	; display flag name and value
	call WriteString

	pop  edx
	pop  eax
%endmacro
%endif

%ifnmacro CheckInit
;-------------------------------------------------------------
%macro CheckInit 0.nolist
;
; Helper macro
; Check to see if the console handles have been initialized
; If not, initialize them now.
;-------------------------------------------------------------
	cmp byte [InitFlag], 0
	jne %%exit
	mov byte [InitFlag], 1
	call BufferFlush
%%exit:
%endmacro
%endif
;-------------------------------------------------------------

; import libc functions
extern printf

%assign MAX_DIGITS 80
%define ESC 27			; escape code

segment .data			; initialized data
InitFlag DB 0			; initialization flag
xtable db "0123456789ABCDEF"

segment .bss			; uninitialized data
bytesWritten:  resd 1		; number of bytes written
eflags:  resd 1
digitBuffer: resb MAX_DIGITS + 1
timeSetting:
    istruc timespec
	at tv_sec, resd 1
	at tv_nsec, resd 1
    iend

buffer resb 512
%assign bufferMax $-buffer
bytesRead resd 1
bufferCnt resd 1

segment .text
; --------------------------------------------------------
; make the functions global as the shared library functions
; --------------------------------------------------------

global Clrscr, Crlf, Delay, DumpMem, DumpRegs, Gotoxy, IsDigit, ParseDecimal32
global ParseInteger32, Random32, Randomize, RandomRange, ReadChar, ReadDec
global ReadHex, ReadInt, ReadKey, ReadString, SetTextColor, Str_compare
global Str_copy, Str_length, Str_trim, Str_ucase, WriteBin, WriteBinB, WriteChar
global WriteDec, WriteHex, WriteHexB, WriteInt, WriteString
;----------------------------------------------------------

;-----------------------------------------------------
Clrscr:
;
; First, write the control characters to stdout to clear the screen.
; Then move the cursor to 0, 0 on the screen.
;-----------------------------------------------------
segment .data
clrStr db ESC, "[2J", 0

segment .text
	push edx
	mov  edx, clrStr
	call WriteString	; clear the screen by escape code sequance

	mov  edx, 0
	call Gotoxy
	pop  edx
	ret
;--------------- End of Clrscr -----------------------

;-----------------------------------------------------
Crlf:
;
; Writes a carriage return / linefeed
; sequence (0Dh, 0Ah) to standard output.
;-----------------------------------------------------
	mWrite {0dh, 0ah}	; invoke a macrao in Macro_Along.inc
	ret
;--------------- End of Crlf -------------------------

;------------------------------------------------------
Delay:
;
; Delay (pause) the current process for a given number
; of milliseconds.
; Use the struct timeSetting in Linux
; Receives: EAX = number of milliseconds
; Returns: nothing
;------------------------------------------------------
	pushad
	mov edx, 0
	mov ecx, 1000
	div ecx
	mov dword [timeSetting + tv_sec], eax
	mov eax, edx
	mov edx, 0
	mov ecx, 1000000
	mul ecx
	mov dword [timeSetting + tv_nsec], eax
	mov ecx, 0
	mov ebx, timeSetting
	mov eax, 162
	int 80h
	popad
	ret
;--------------- End of Delay -------------------------

;--------------------------------------------------------
Gotoxy:
;
; Locate the cursor
; Receives: DH = screen row, DL = screen column
; Last update: 7/11/01
;--------------------------------------------------------
segment .data
locateStr db ESC, "[%d;%dH", 0

segment .text
	push  eax

	movzx eax, dl
	push  eax
	movzx eax, dh
	push  eax
	push  dword locateStr
	call  printf		; call the libc function printf
	add   esp, 12

	pop   eax
	ret
;--------------- End of Gotoxy -------------------------

;-----------------------------------------------
IsDigit:
;
; Determines whether the character in AL is a
; valid decimal digit.
; Receives: AL = character
; Returns: ZF=1 if AL contains a valid decimal
;   digit; otherwise, ZF=0.
;-----------------------------------------------
	cmp  al, '0'
	jb   .ID1
	cmp  al, '9'
	ja   .ID1
	test ax, 0		; set ZF = 1
.ID1:
	ret
;--------------- End of IsDigit ----------------------

;---------------------------------------------------
DumpMem:
;
; Writes a range of memory to standard output
; in hexadecimal.
; Receives: ESI = starting offset, ECX = number of units,
;           EBX = unit size (1=byte, 2=word, or 4=doubleword)
; Returns:  nothing
;---------------------------------------------------
segment .data
oneSpace:   db ' ', 0

dumpPrompt: db 13, 10, "Dump of offset ", 0
dashLine:   db "-------------------------------", 13, 10, 0

segment .text
	enter 8, 0		; [ebp - 4]: unit size; [ebp - 8]: number of units
	pushad

	mov  edx, dumpPrompt
	call WriteString
	mov  eax, esi		; get memory offset to dump
	call WriteHex
	call Crlf
	mov  edx, dashLine
	call WriteString

	mov  dword [ebp - 8], 0
	mov  dword [ebp - 4], ebx
	cmp  ebx, 4		; select output size
	je   .L1
	cmp  ebx, 2
	je   .L2
	jmp  .L3

	; 32-bit doubleword output
.L1:
	mov  eax, dword [esi]
	call WriteHex
	mWriteSpace 2
	add  esi, ebx
	loop .L1
	jmp  .L4

	; 16-bit word output
.L2:
	mov  ax, word [esi]	; get a word from memory
	ror  ax, 8		; display high byte
	call HexByte
	ror  ax, 8		; display low byte
	call HexByte
	mWriteSpace 1		; display 1 space
	add  esi, ebx		; point to next word
	loop .L2
	jmp  .L4

	; 8-bit byte output, 16 bytes per line
.L3:
	mov  al, byte [esi]
	call HexByte
	inc  dword [ebp - 8]
	mWriteSpace 1
	inc  esi

	; if( byteCount mod 16 == 0 ) call Crlf

	mov  dx, 0
	mov  ax, word [ebp - 8]
	mov  bx, 16
	div  bx
	cmp  dx, 0
	jne  .L3B
	call Crlf
.L3B:
	loop .L3
	jmp  .L4

.L4:
	call Crlf
	popad
	leave
	ret
;--------------- End of DumpMem -------------------------

;---------------------------------------------------
DumpRegs:
;
; Displays EAX, EBX, ECX, EDX, ESI, EDI, EBP, ESP in
; hexadecimal. Also displays the Zero, Sign, Carry, and
; Overflow flags.
; Receives: nothing.
; Returns: nothing.
;
; Warning: do not create any local variables or stack
; parameters, because they will alter the EBP register.
;---------------------------------------------------
segment .data
saveIP  dd 0
saveESP dd 0

segment .text
	pop  dword [saveIP]	; get current EIP
	mov  dword [saveESP], esp	; save ESP's value at entry
	push dword [saveIP]	; replace it on stack
	push eax		; save EAX (restore on exit)

	pushfd			; push extended flags

	pushfd			; push flags again, and
	pop  dword [eflags]	; save them in a variable

	call Crlf
	mShowRegister "EAX", EAX
	mShowRegister "EBX", EBX
	mShowRegister "ECX", ECX
	mShowRegister "EDX", EDX
	call Crlf
	mShowRegister "ESI", ESI
	mShowRegister "EDI", EDI

	mShowRegister "EBP", EBP

	mov  eax, dword [saveESP]
	mShowRegister "ESP", EAX
	call Crlf

	mov  eax, dword [saveIP]
	mShowRegister "EIP", EAX
	mov  eax, dword [eflags]
	mShowRegister "EFL", EAX

; Show the flags (using the eflags variable). The integer parameter indicates
; how many times EFLAGS must be shifted right to shift the selected flag
; into the Carry flag.

	ShowFlag "CF", 1
	ShowFlag "SF", 8
	ShowFlag "ZF", 7
	ShowFlag "OF", 12
	ShowFlag "AF", 5
	ShowFlag "PF", 3

	call Crlf
	call Crlf

	popfd
	pop  eax
	ret
;--------------- End of DumpRegs ---------------------

;--------------------------------------------------------
ParseDecimal32:
;
; Converts (parses) a string containing an unsigned decimal
; integer, and converts it to binary. All valid digits occurring
; before a non-numeric character are converted.
; Leading spaces are ignored.

; Receives: EDX = offset of string, ECX = length
; Returns:
;  If the integer is blank, EAX=0 and CF=1
;  If the integer contains only spaces, EAX=0 and CF=1
;  If the integer is larger than 2^32-1, EAX=0 and CF=1
;  Otherwise, EAX=converted integer, and CF=0
;--------------------------------------------------------
	enter 4, 0
	push ebx
	push ecx
	push edx
	push esi

	mov  esi, edx		; save offset in ESI

	cmp  ecx, 0		; length greater than zero?
	jne  .L1		; yes: continue
	mov  eax, 0		; no: set return value
	jmp  .L5 		; and exit with CF=1

; Skip over leading spaces, tabs

.L1:	mov  al, byte [esi]	; get a character from buffer
	cmp  al, ' '		; space character found?
	je   .L1A		; yes: skip it
	cmp  al, TAB		; TAB found?
	je   .L1A		; yes: skip it
	jmp  .L2		; no: goto next step

.L1A:
	inc  esi		; yes: point to next char
	loop .L1		; continue searching until end of string
	jmp  .L5		; exit with CF=1 if all spaces

; Start to convert the number.

.L2:	mov  eax, 0		; clear accumulator
	mov  ebx, 10		; EBX is the divisor

; Repeat loop for each digit.

.L3:	mov  dl, byte [esi]	; get character from buffer
	cmp  dl, '0'		; character < '0'?
	jb   .L4
	cmp  dl, '9'		; character > '9'?
	ja   .L4
	and  edx, 0Fh		; no: convert to binary

	mov  dword [ebp - 4], edx
	mul  ebx		; EDX:EAX = EAX * EBX
	jc   .L5		; quit if Carry (EDX > 0)
	mov  edx, dword [ebp - 4]
	add  eax, edx		; add new digit to sum
	jc   .L5		; quit if Carry generated
	inc  esi		; point to next digit
	jmp  .L3		; get next digit

.L4:	clc			; succesful completion (CF=0)
	jmp  .L6

.L5:	mov  eax, 0		; clear result to zero
	stc			; signal an error (CF=1)

.L6:
	pop  esi
	pop  edx
	pop  ecx
	pop  ebx
	leave
	ret
;--------------- End of ParseDecimal32 ---------------------

;--------------------------------------------------------
ParseInteger32:
;
; Converts a string containing a signed decimal integer to
; binary.
;
; All valid digits occurring before a non-numeric character
; are converted. Leading spaces are ignored, and an optional
; leading + or - sign is permitted. If the string is blank,
; a value of zero is returned.
;
; Receives: EDX = string offset, ECX = string length
; Returns:  If CF=0, the integer is valid, and EAX = binary value.
;   If CF=1, the integer is invalid and EAX = 0.
;
; Created 7/15/05, using Gerald Cahill's 10/10/03 corrections.
; Updated 7/19/05, to skip over tabs
;--------------------------------------------------------
segment .data
overflow_msgL db  " <32-bit integer overflow>", 0
invalid_msgL  db  " <invalid integer>", 0

segment .text
	enter 8, 0		; [ebp - 4]: Lsign; [ebp - 8]:saveDigit
	push ebx
	push ecx
	push edx
	push esi

	mov  dword [ebp - 4], 1	; assume number is positive
	mov  esi, edx		; save offset in SI

	cmp  ecx, 0		; length greater than zero?
	jne  .L1		; yes: continue
	mov  eax, 0		; no: set return value
	jmp  .L10		; and exit

; Skip over leading spaces and tabs.

.L1:	mov  al, byte [esi]	; get a character from buffer
	cmp  al, ' '		; space character found?
	je   .L1A		; yes: skip it
	cmp  al, TAB		; TAB found?
	je   .L1A		; yes: skip it
	jmp  .L2		; no: goto next step

.L1A:
	inc  esi		; yes: point to next char
	loop .L1		; continue searching until end of string
	mov  eax, 0		; all spaces?
	jmp  .L10		; return 0 as a valid value

; Check for a leading sign.

.L2:	cmp  al, '-'		; minus sign found?
	jne  .L3		; no: look for plus sign

	mov  dword [ebp - 4], -1; yes: sign is negative
	dec  ecx		; subtract from counter
	inc  esi		; point to next char
	jmp  .L3A

.L3:	cmp  al, '+'		; plus sign found?
	jne  .L3A		; no: skip
	inc  esi		; yes: move past the sign
	dec  ecx		; subtract from digit counter

; Test the first digit, and exit if nonnumeric.

.L3A:	mov  al, byte [esi]		; get first character
	call IsDigit		; is it a digit?
	jnz  .L7A		; no: show error message

; Start to convert the number.

.L4:	mov  eax, 0		; clear accumulator
	mov  ebx, 10		; EBX is the divisor

; Repeat loop for each digit.

.L5:	mov  dl, byte [esi]	; get character from buffer
	cmp  dl, '0'		; character < '0'?
	jb   .L9
	cmp  dl, '9'		; character > '9'?
	ja   .L9
	and  edx, 0Fh		; no: convert to binary

	mov  dword [ebp - 8], edx
	imul ebx		; EDX:EAX = EAX * EBX
	mov  edx, dword [ebp - 8]

	jo   .L6		; quit if overflow
	add  eax, edx		; add new digit to AX
	jo   .L6		; quit if overflow
	inc  esi		; point to next digit
	jmp  .L5		; get next digit

; Overflow has occured, unlesss EAX = 80000000h
; and the sign is negative:

.L6:	cmp  eax, 80000000h
	jne  .L7
	cmp  dword [ebp - 4], -1
	jne  .L7		; overflow occurred
	jmp  .L9		; the integer is valid

; Choose "integer overflow" messsage.

.L7:	mov  edx, overflow_msgL
	jmp  .L8

; Choose "invalid integer" message.

.L7A:
	mov  edx, invalid_msgL

; Display the error message pointed to by EDX, and set the Overflow flag.

.L8:
	call WriteString
	call Crlf
	mov  al, 127
	add  al, 1		; set Overflow flag
	mov  eax, 0		; set return value to zero
	jmp  .L10		; and exit

; IMUL leaves the Sign flag in an undeterminate state, so the OR instruction
; determines the sign of the iteger in EAX.
.L9:	imul dword [ebp - 4]	; EAX = EAX * sign
	or eax, eax		; determine the number's Sign

.L10:
	pop esi
	pop edx
	pop ecx
	pop ebx
	leave
	ret
;--------------- End of ParseInteger32 ---------------------

;---------------------------------------------------------
Str_length:
;
; Return the length of a null-terminated string.
; Receives: pointer to a string
; Returns: EAX = string length
;---------------------------------------------------------
	push edi
	push ebp
	mov  ebp, esp

	mov  edi, [ebp + 12]
	mov  eax, 0		; character count
.L1:
	cmp  byte [edi], 0	; end of string?
	je   .L2		; yes: quit
	inc  edi		; no: point to next
	inc  eax		; add 1 to count
	jmp  .L1
.L2:
	pop  ebp
	pop  edi
	ret
;--------------- End of Str_length -----------------------

;----------------------------------------------------------
Str_compare:
;
; Compare two strings.
; Receive: the pointers to the first and the second strings.
; Returns nothing, but the Zero and Carry flags are affected
; exactly as they would be by the CMP instruction.
;-----------------------------------------------------
	enter 0, 0
	pushad
	mov  esi, dword [ebp + 8]
	mov  edi, dword [ebp + 12]

.L1:	mov  al, byte [esi]
	mov  dl, byte [edi]
	cmp  al, 0		; end of string1?
	jne  .L2		; no
	cmp  dl, 0		; yes: end of string2?
	jne  .L2		; no
	jmp  .L3		; yes, exit with ZF = 1

.L2:	inc  esi		; point to next
	inc  edi
	cmp  al, dl		; chars equal?
	je   .L1		; yes: continue loop
				; no: exit with flags set
.L3:
	popad
	leave
	ret
;--------------- End of Str_compare -----------------------

;---------------------------------------------------------
Str_copy:
;
; Copy a string from source to target.
; Requires: the target string must contain enough
;           space to hold a copy of the source string.
;----------------------------------------------------------
	enter 0, 0
	pushad
	INVOKE Str_length, {[ebp + 8]}	; EAX = length source
	mov  ecx, eax		; REP count
	inc  ecx		; add 1 for null byte
	mov  esi, dword [ebp + 8]
	mov  edi, dword [ebp + 12]
	cld			; direction = up
	rep movsb		; copy the string
	popad
	leave
	ret
;--------------- End of Str_copy -----------------------

;-----------------------------------------------------------
Str_trim:
;
; Remove all occurences of a given character from
; the end of a string.
; Returns: nothing
;-----------------------------------------------------------
	enter 0, 0
	pushad
	mov  edi, dword [ebp + 8]
	INVOKE Str_length, edi	; returns length in EAX
	cmp  eax, 0		; zero-length string?
	je   .L2		; yes: exit
	mov  ecx, eax		; no: counter = string length
	dec  eax
	add  edi, eax		; EDI points to last char
	mov  al, byte [ebp + 12]; char to trim
	std			; direction = reverse
	repe scasb		; skip past trim character
	jne  .L1		; removed first character?
	dec  edi		; adjust EDI: ZF=1 && ECX=0
.L1:	mov  byte [edi + 2], 0	; insert null byte
.L2:
	popad
	leave
	ret
;--------------- End of Str_trim -----------------------

;---------------------------------------------------
Str_ucase:
;
; Convert a null-terminated string to upper case.
; Receives: a pointer to the string
; Returns: nothing
; Last update: 1/18/02
;---------------------------------------------------
	enter 0, 0
	push eax
	push esi
	mov  esi, dword [ebp + 8]
.L1:
	mov  al, byte [esi]	; get char
	cmp  al, 0		; end of string?
	je   .L3		; yes: quit
	cmp  al, 'a'		; below "a"?
	jb   .L2
	cmp  al, 'z'		; above "z"?
	ja   .L2
	and  byte [esi], 11011111b; convert the char

.L2:	inc  esi		; next char
	jmp  .L1

.L3:
	pop  esi
	pop  eax
	leave
	ret
;--------------- End of Str_ucase -----------------------

;------------------------------------------------------------
BufferFlush:
;
; Clear the reading buffer and reset it to the initial state.
; Recieves: nothing
;----------------------------------------------------------
	mov dword [bytesRead], 0
	mov dword [bufferCnt], 1
	ret
;------------------ End of BufferFlush --------------------

;--------------------------------------------------------------
Random32:
;
; Generates an unsigned pseudo-random 32-bit integer
;   in the range 0 - FFFFFFFFh.
; Receives: nothing
; Returns: EAX = random integer
;--------------------------------------------------------------
segment .data
seed  dd 1
segment .text
	push edx
	mov  eax, 343FDh
	imul dword [seed]
	add  eax, 269EC3h
	mov  dword [seed], eax	; save the seed for the next call
	ror  eax, 8		; rotate out the lowest digit (10/22/00)
	pop  edx

	ret
;------------------ End of Random32 --------------------

;--------------------------------------------------------
Randomize:
;
; Re-seeds the random number generator with the current time
; in seconds.
; Receives: nothing
; Returns: nothing
;--------------------------------------------------------
	pushad

	mov ebx, 0
	mov eax, 13
	int 80h
	mov dword [seed], eax

	popad
	ret
;------------------ End of Randomize --------------------

;--------------------------------------------------------------
RandomRange:
;
; Returns an unsigned pseudo-random 32-bit integer
; in EAX, between 0 and n-1.
; Input parameter: EAX = n.
;--------------------------------------------------------------
	push ebx
	push edx

	mov  ebx, eax		; maximum value
	call Random32		; eax = random number
	mov  edx, 0
	div  ebx		; divide by max value
	mov  eax, edx		; return the remainder

	pop  edx
	pop  ebx

	ret
;------------------ End of RandomRange --------------------

;------------------------------------------------------------
ReadKeys:
;
; Read keys from buffer, if there is no keys in it, read from STDIN and
; store in buffer
; Recieves: ECX = Number of key to return
;	    EDX = address of input buffer
;----------------------------------------------------------
	enter 4, 0
	pushad
	CheckInit
	cmp  dword [bytesRead], 0; check if no keys in the buffer
	je   .NoKey
.Begin:
	cmp  ecx, dword [bytesRead]; else, return the keys from the buffer
	jbe  .L1
	mov  ecx, dword [bytesRead]
.L1:
	mov  dword [ebp - 4], ecx
	sub  dword [bytesRead], ecx
	mov  edi, edx		; copy the content of buffer to the destination
	mov  esi, buffer
	add  esi, dword [bufferCnt]
	dec  esi
	cld
	rep  movsb
	mov  ebx, buffer
	add  ebx, bufferMax
	cmp  dword [bytesRead], 0; if number of left bytes is greater than 0
	jbe  .L2
	cmp  esi, ebx		; if out of bound
	jae  .L2
	mov  al, byte [esi]	; check if next char is NL
	cmp  al, NL
	jne  .L2
	dec  dword [bytesRead]	; mov forword
	inc  esi
.L2:
	sub  esi, buffer
	inc  esi
	mov  dword [bufferCnt], esi
	jmp  .L3
.NoKey:
	call BufferFlush	; if no Key, read from the keyboard
	push ecx		; save size
	push edx		; save destination
	mov  eax, 3
	mov  ebx, STDIN
	mov  edx, buffer
	mov  ecx, bufferMax
	push ecx
	push edx
	push ebx
	push eax
	int  80h
	add  esp, 16
	pop  edx		; restore destination
	pop  ecx		; restore size
	mov  dword [bytesRead], eax
	jmp  .Begin
.L3:
	popad
	mov  eax, dword [ebp - 4]
	leave
	ret
;--------------------- End of ReadKeys ----------------------

;------------------------------------------------------------
ReadChar:
;
; Reads one character from the keyboard.
; Waits for the character if none is
; currently in the input buffer.
; Returns:  AL = ASCII code
;----------------------------------------------------------
	enter 4, 0
	push ebx
	push edx
.L1:
	mov  ecx, 1
	mov  edx, ebp
	sub  edx, 4
	call ReadKeys

	mov  al, byte [ebp - 4]
	pop  edx
	pop  ebx
	leave
	ret
;--------------- End of ReadChar -------------------------

;--------------------------------------------------------
ReadDec:
;
; Reads a 32-bit unsigned decimal integer from the keyboard,
; stopping when the Enter key is pressed.All valid digits occurring
; before a non-numeric character are converted to the integer value.
; Leading spaces are ignored.

; Receives: nothing
; Returns:
;  If the integer is blank, EAX=0 and CF=1
;  If the integer contains only spaces, EAX=0 and CF=1
;  If the integer is larger than 2^32-1, EAX=0 and CF=1
;  Otherwise, EAX=converted integer, and CF=0
;--------------------------------------------------------

	mov  edx, digitBuffer
	mov  ecx, MAX_DIGITS
	call ReadString
	mov  ecx, eax		; save length

	call ParseDecimal32	; returns EAX

	ret
;--------------- End of ReadDec ------------------------

;--------------------------------------------------------
ReadHex:
;
; Reads a 32-bit hexadecimal integer from the keyboard,
; stopping when the Enter key is pressed.
; Receives: nothing
; Returns: EAX = binary integer value
; Returns:
;  If the integer is blank, EAX=0 and CF=1
;  If the integer contains only spaces, EAX=0 and CF=1
;  Otherwise, EAX=converted integer, and CF=0

; Remarks: No error checking performed for bad digits
; or excess digits.
;--------------------------------------------------------
segment .data
xbtable	db 0, 1, 2, 3, 4, 5, 6, 7, 8, 9
	times 7 db 0FFh
	db 10, 11, 12, 13, 14, 15
numVal	dd 0
charVal	db 0

segment .text
	push ebx
	push ecx
	push edx
	push esi

	mov  edx, digitBuffer
	mov  esi, edx		; save in ESI also
	mov  ecx, MAX_DIGITS
	call ReadString		; input the string
	mov  ecx, eax		; save length in ECX

	cmp  ecx, 0		; greater than zero?
	jne  .B1		; yes: continue
	jmp  .B8		; no: exit with CF=1

; Skip over leading spaces and tabs.

.B1:	mov  al, byte [esi]	; get a character from buffer
	cmp  al, ' '		; space character found?
	je   .B1A		; yes: skip it
	cmp  al, TAB		; TAB found?
	je   .B1A		; yes: skip it
	jmp  .B4		; no: goto next step

.B1A:
	inc  esi		; yes: point to next char
	loop .B1		; all spaces?
	jmp  .B8		; yes: exit with CF=1

	; Start to convert the number.

.B4:	mov  dword [numVal], 0	; clear accumulator
	mov  ebx, xbtable	; translate table

	; Repeat loop for each digit.

.B5:	mov  al, byte [esi]	; get character from buffer
	cmp  al, 'F'		; lowercase letter?
	jbe  .B6		; no
	and  al, 11011111b	; yes: convert to uppercase

.B6:	sub  al, 30h		; adjust for table
	xlat			; translate to binary
	mov  byte [charVal], al
	mov  eax, 16		; numVal *= 16
	mul  dword [numVal]
	mov  dword [numVal], eax
	movzx eax, byte [charVal]; numVal += charVal
	add  dword [numVal], eax
	inc  esi		; point to next digit
	loop .B5		; repeat, decrement counter

.B7:	mov  eax, dword [numVal]; return valid value
	clc			; CF=0
	jmp  .B9

.B8:	mov  eax, 0		; error: return 0
	stc			; CF=1

.B9:
	pop  esi
	pop  edx
	pop  ecx
	pop  ebx
	ret
;--------------- End of ReadHex ------------------------

;--------------------------------------------------------
ReadInt:
;
; Reads a 32-bit signed decimal integer from standard
; input, stopping when the Enter key is pressed.
; All valid digits occurring before a non-numeric character
; are converted to the integer value. Leading spaces are
; ignored, and an optional leading + or - sign is permitted.
; All spaces return a valid integer, value zero.

; Receives: nothing
; Returns:  If CF=0, the integer is valid, and EAX = binary value.
;   If CF=1, the integer is invalid and EAX = 0.
;--------------------------------------------------------

	push edx
	push ecx
; Input a signed decimal string.

	mov  edx, digitBuffer
	mov  ecx, MAX_DIGITS
	call ReadString
	mov  ecx, eax		; save length in ECX

; Convert to binary (EDX -> string, ECX = length)

	call ParseInteger32	; returns EAX, CF

	pop  ecx
	pop  edx
	ret
;--------------- End of ReadInt ------------------------

;--------------------------------------------------------
ReadString:
;
; Reads a string from the keyboard and places the characters
; in a buffer.
; Receives: EDX offset of the input buffer
;           ECX = maximum characters to input (including terminal null)
; Returns:  EAX = size of the input string.
; Comments: Stops when Enter key (0Dh, 0Ah) is pressed. If the user
; types more characters than (ECX-1), the excess characters
; are ignored.
; Written by Kip Irvine and Gerald Cahill
; Modified by Curtis Wong
;--------------------------------------------------------
	enter 8, 0		; bufSize: ebp - 4
				; bytesRead: ebp - 8
	pushad

	mov  edi, edx		; set EDI to buffer offset
	mov  dword [ebp - 4], ecx; save buffer size

	call ReadKeys

	mov  dword [ebp - 8], eax

	cmp  eax, 0
	jz   .L5 		; skip move if zero chars input

	cld			; search forward
	mov  ecx, dword [ebp - 4]; repetition count for SCASB
	dec  ecx
	mov  al, NL		; scan for 0Ah (Line Feed) terminal character
	repne scasb
	jne  .L1		; if not found, jump to L1

	;if we reach this line, length of input string <= (bufsize - 2)

	dec  dword [ebp - 8]	; second adjustment to bytesRead
	dec  edi		; 0Ah found: back up two positions
	cmp  edi, edx 		; don't back up to before the user's buffer
	jae  .L2
	mov  edi, edx 		; 0Ah must be the only byte in the buffer
	jmp  .L2		; and jump to L2

.L1:	mov  edi, edx		; point to last byte in buffer
	add  edi, dword [ebp - 4]
	dec  edi
	mov  byte [edi], 0	; insert null byte

	; Clear excess characters from the buffer, 1 byte at a time
.L6:	call BufferFlush
	jmp  .L5

.L2:	mov  byte [edi], 0	; insert null byte

.L5:	popad
	mov  eax, dword [ebp - 8]
	leave
	ret
;--------------- End of ReadString --------------------

;--------------------------------------------------------
SetTextColor:
;
; Sets the foreground and background colors of all
; subsequent text output to the console.
; Receives: AL = color attribute
;           First 4 bytes are background and last are foreground
; Returns:  nothing
;--------------------------------------------------------
segment .data
styleStr db ESC, "[0m"		; no null, so write both strings at once
colorStr db ESC, "[30;40m", 0
strEnd   equ $
colorArr db gray,  lightRed, lightGreen, yellow, lightBlue, lightMagenta, lightCyan, white
	 db black, red,      green,      brown,  blue,      magenta,      cyan,      lightGray
colorEnd equ $
black        equ 0000b
blue         equ 0001b
green        equ 0010b
cyan         equ 0011b
red          equ 0100b
magenta      equ 0101b
brown        equ 0110b
lightGray    equ 0111b
gray         equ 1000b
lightBlue    equ 1001b
lightGreen   equ 1010b
lightCyan    equ 1011b
lightRed     equ 1100b
lightMagenta equ 1101b
yellow       equ 1110b
white        equ 1111b

segment .text
	pushad

	mov  esi, colorStr

	xor  ebx, ebx
	mov  bl, al
	and  bl, 0Fh		; bl = foreground color
	mov  bh, 1		; flag: foreground (1) or background (0)

.SetupLoop:
	mov  edx, colorEnd
	mov  ecx, colorEnd - strEnd; length of array

.CheckColor:
	dec  edx
	cmp  [edx], bl		; if color matches
	je   .Update		; yes: update the string
	loop .CheckColor	; no: keep checking

.Update:
	add  esi, 3		; move to '0's in the string
	mov  bl, al		; save color in al for division
	mov  ecx, colorEnd	; setup div
	sub  ecx, edx
	mov  al, colorEnd - strEnd; number of colors
	sub  al, cl
	mov  cl, 8
	div  cl			; ah = remainder (0-7), al = 0 if light
	cmp  al, 0		; if light color
	jne  .NormalColor	; yes: make bright/bold
	mov  byte [strEnd - 11], '2'; styleStr

.NormalColor
	mov  al, bl		; restore al after division
	add  [esi], ah		; update 30 and 40 in the string

	cmp  bh, 0		; if checking background
	je   .Write		; yes: write the string
				; no: check background
	dec  bh			; dh = 0, check background
	and  bl, 0F0h		; bl = background color
	shr  bl, 4
	jmp  .SetupLoop

.Write:
	mov  edx, styleStr
	call WriteString

	mov  byte [esi], '0'	; restore "40"
	mov  byte [esi - 3], '0'; restore "30"
	mov  byte [strEnd - 11], '0'; restore "0"

	popad
	ret
;--------------- End of SetTextColor --------------------

;------------------------------------------------------
WriteBin:
;
; Writes a 32-bit integer to the console window in
; binary format. Converted to a shell that calls the
; WriteBinB procedure, to be compatible with the
; library documentation in Chapter 5.
; Receives: EAX = the integer to write
; Returns: nothing
;------------------------------------------------------

	push ebx
	mov  ebx, 4		; select doubleword format
	call WriteBinB
	pop  ebx

	ret
;--------------- End of WriteBin --------------------

;------------------------------------------------------
WriteBinB:
;
; Writes a 32-bit integer to the console window in
; binary format.
; Receives: EAX = the integer to write
;           EBX = display size (1, 2, 4)
; Returns: nothing
;------------------------------------------------------
	pushad

	cmp  ebx, 1		; ensure EBX is 1, 2, or 4
	jz   .WB0
	cmp  ebx, 2
	jz   .WB0
	mov  ebx, 4		; set to 4 (default) even if it was 4
.WB0:
	mov  ecx, ebx
	shl  ecx, 1		; number of 4-bit groups in low end of EAX
	cmp  ebx, 4
	jz   .WB0A
	ror  eax, 8		; assume TYPE==1 and ROR byte
	cmp  ebx, 1
	jz   .WB0A 		; good assumption
	ror  eax, 8		; TYPE==2 so ROR another byte
.WB0A:
	call BufferFlush
	mov  esi, buffer

.WB1:
	push ecx		; save loop count

	mov  ecx, 4		; 4 bits in each group
.WB1A:
	shl  eax, 1		; shift EAX left into Carry flag
	mov  byte [esi], '0'	; choose '0' as default digit
	jnc  .WB2		; if no carry, then jump to L2
	mov  byte [esi], '1'	; else move '1' to DL
.WB2:
	inc  esi
	loop .WB1A		; go to next bit within group

	mov  byte [esi], ' '  	; insert a blank space
	inc  esi		; between groups
	pop  ecx		; restore outer loop count
	loop .WB1		; begin next 4-bit group

	dec  esi		; eliminate the trailing space
	mov  byte [esi], 0	; insert null byte at end
	mov  edx, buffer	; display the buffer
	call WriteString

	popad
	ret
;--------------- End of WriteBinB --------------------

;------------------------------------------------------
WriteChar:
;
; Write a character to the console window
; Recevies: AL = character
;------------------------------------------------------
	pushad
	pushfd			; save flags

	mov  [buffer], al

	mov  eax, 4
	mov  ebx, STDOUT
	mov  ecx, buffer
	mov  edx, 1
	int  80h		; call sys_write to the char

	mov  [bytesWritten], eax
	popfd			; restore flags
	popad
	ret
;--------------- End of WriteChar --------------------

;-----------------------------------------------------
WriteDec:
;
; Writes an unsigned 32-bit decimal number to
; the console window.
; Input parameters: EAX = the number to write.
;------------------------------------------------------
segment .data
; There will be as many as 10 digits.
%assign WDBUFFER_SIZE 12

bufferL: times WDBUFFER_SIZE db 0
	 db 0

segment .text
	pushad

	mov  ecx, 0		; digit counter
	mov  edi, bufferL
	add  edi, (WDBUFFER_SIZE - 1)
	mov  ebx, 10		; decimal number base

.WI1:
	mov  edx, 0		; clear dividend to zero
	div  ebx		; divide EAX by the radix

	xchg eax, edx		; swap quotient, remainder
	call AsciiDigit		; convert AL to ASCII
	mov  byte [edi], al	; save the digit
	dec  edi		; back up in buffer
	xchg eax, edx		; swap quotient, remainder

	inc  ecx		; increment digit count
	or   eax, eax		; quotient = 0?
	jnz  .WI1		; no, divide again

	 ; Display the digits (CX = count)
.WI3:
	 inc  edi
	 mov  edx, edi
	 call WriteString

.WI4:
	 popad			; restore 32-bit registers
	 ret
;--------------- End of WriteDec ---------------------

;------------------------------------------------------
WriteHex:
;
; Writes an unsigned 32-bit hexadecimal number to
; the console window.
; Input parameters: EAX = the number to write.
; Shell interface for WriteHexB, to retain compatibility
; with the documentation in Chapter 5.
;------------------------------------------------------
	push ebx
	mov  ebx, 4
	call WriteHexB
	pop  ebx
	ret
;--------------- End of WriteHex ---------------------

;------------------------------------------------------
WriteHexB:
;
; Writes an unsigned 32-bit hexadecimal number to
; the console window.
; Receives: EAX = the number to write. EBX = display size (1, 2, 4)
; Returns: nothing
;------------------------------------------------------

%assign DOUBLEWORD_BUFSIZE 8

segment .data
bufferLHB: times DOUBLEWORD_BUFSIZE db 0
	   db 0

segment .text
	enter 4, 0		; [ebp - 4]: displaySize
	pushad			; save all 32-bit data registers
	mov dword [ebp - 4], ebx; save component size

; Clear unused bits from EAX to avoid a divide overflow.
; Also, verify that EBX contains either 1, 2, or 4. If any
; other value is found, default to 4.
; The following contains the MASM psudo-instructions as the comments.

; .IF EBX == 1	; check specified display size
	cmp ebx, 1
	jne .outerElse
	and  eax, 0FFh		; byte == 1
	jmp .outerEndif
; .ELSE
.outerElse:
;	.IF EBX == 2
	cmp ebx, 2
	jne .innerElse
	and eax, 0FFFFh		; word == 2
	jmp .innerEndif
;	.ELSE
.innerElse:
	mov dword [ebp - 4], 4	; default (doubleword) == 4
;	.ENDIF
.innerEndif:
; .ENDIF
.outerEndif:

	mov  edi, dword [ebp - 4]; let EDI point to the end of the buffer:
	shl  edi, 1		; multiply by 2 (2 digits per byte)
	mov  byte [bufferLHB + edi], 0 ; store null string terminator
	dec  edi		; back up one position

	mov  ecx, 0		; digit counter
	mov  ebx, 16		; hexadecimal base (divisor)

.L1:
	mov  edx, 0		; clear upper dividend
	div  ebx		; divide EAX by the base

	xchg eax, edx		; swap quotient, remainder
	call AsciiDigit		; convert AL to ASCII
	mov  byte [bufferLHB + edi], al; save the digit
	dec  edi		; back up in buffer
	xchg eax, edx		; swap quotient, remainder

	inc  ecx		; increment digit count
	or   eax, eax		; quotient = 0?
	jnz  .L1		; no, divide again

	 ; Insert leading zeros

	mov  eax, dword [ebp - 4]; set EAX to the
	shl  eax, 1		; number of digits to print
	sub  eax, ecx		; subtract the actual digit count
	jz   .L3		; display now if no leading zeros required
	mov  ecx, eax		; CX = number of leading zeros to insert

.L2:
	mov  byte [bufferLHB + edi], '0'; insert a zero
	dec  edi		; back up
	loop .L2		; continue the loop

	; Display the digits. ECX contains the number of
	; digits to display, and EDX points to the first digit.
.L3:
	mov  ecx, dword [ebp - 4]; output format size
	shl  ecx, 1		; multiply by 2
	inc  edi
	mov  edx, bufferLHB
	add  edx, edi
	call WriteString

	popad	; restore 32-bit registers
	leave
	ret
;--------------- End of WriteHexB ---------------------

;-----------------------------------------------------
WriteInt:
;
; Writes a 32-bit signed binary integer to the console window
; in ASCII decimal.
; Receives: EAX = the integer
; Returns:  nothing
; Comments: Displays a leading sign, no leading zeros.
;-----------------------------------------------------
%assign WI_Bufsize 12
%assign true 1
%assign false 0

segment .data
buffer_B  times WI_Bufsize db 0
	  db 0  ; buffer to hold digits
neg_flag  db  0

segment .text
	pushad

	mov  byte [neg_flag], false; assume neg_flag is false
	or   eax, eax		; is AX positive?
	jns  .WIS1		; yes: jump to B1
	neg  eax		; no: make it positive
	mov  byte [neg_flag], true; set neg_flag to true

.WIS1:
	mov  ecx, 0		; digit count = 0
	mov  edi, buffer_B
	add  edi, (WI_Bufsize-1)
	mov  ebx, 10		; will divide by 10

.WIS2:
	mov  edx, 0		; set dividend to 0
	div  ebx		; divide AX by 10
	or   dl, 30h		; convert remainder to ASCII
	dec  edi		; reverse through the buffer
	mov  byte [edi], dl	; store ASCII digit
	inc  ecx		; increment digit count
	or   eax, eax		; quotient > 0?
	jnz  .WIS2		; yes: divide again

	; Insert the sign.

	dec  edi		; back up in the buffer
	inc  ecx		; increment counter
	mov  byte [edi], '+'	; insert plus sign
	cmp  byte [neg_flag], false; was the number positive?
	jz   .WIS3		; yes
	mov  byte [edi], '-'	; no: insert negative sign

.WIS3:	; Display the number
	mov  edx, edi
	call WriteString

	popad
	ret
;--------------- End of WriteInt ---------------------

;--------------------------------------------------------
WriteString:
;
; Writes a null-terminated string to standard
; output.
; Input parameter: EDX points to the string.
;--------------------------------------------------------
	pushad

	INVOKE Str_length, edx	; return length of string in EAX

	push dword eax		; string length
	push dword edx		; string
	push dword STDOUT
	mov  eax, 4		; syscall number for write
	sub  esp, 4
	int  80h
	add  esp, 16

	popad
	ret
;--------------- End of WriteString ---------------------

;*************************************************************
;*                    PRIVATE PROCEDURES                     *
;*************************************************************

;--------------------------------------------------------
AsciiDigit:
;
; Convert AL to an ASCII digit. Used by WriteHex & WriteDec
;--------------------------------------------------------
	 push  ebx
	 mov   ebx, xtable
	 xlat
	 pop   ebx
	 ret
;---------------- End of AsciiDigit ---------------------

;--------------------------------------------------------
HexByte:
;
; Display the byte in AL in hexadecimal
;--------------------------------------------------------

	pushad
	mov  dl, al

	rol  dl, 4
	mov  al, dl
	and  al, 0Fh
	mov  ebx, xtable
	xlat
	call BufferFlush
	mov  byte [buffer], al	; save first char
	rol  dl, 4
	mov  al, dl
	and  al, 0Fh
	xlat
	mov  byte [buffer+1], al; save second char
	mov  byte [buffer+2], 0	; null byte

	mov  edx, buffer	; display the buffer
	call WriteString
	call BufferFlush

	popad
	ret
;------------------ End of HexByte ---------------------
