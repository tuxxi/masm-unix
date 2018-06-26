; Along32 Link Library Source Code ( Macros_Along.inc )
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
; Macro definitions for Along32 library
; This is just a auxiliary file for Along32.asm, which means
; that it cannot be used solely.
; If you want to utilize the macros in this file, just include
; Along32.inc.
; Last Update: 2009.08.20
;

%ifndef MACRO_ALONG
%define MACRO_ALONG

%define STDIN  0
%define STDOUT 1
%define STDERR 2

%define TAB 09h
%define NL 0Ah

; define the timespec structure used in nanosleep
struc timespec
	tv_sec: resd 1
	tv_nsec: resd 1
endstruc

; Synonym for MASM .exit
%ifnmacro Exit
%macro Exit 1.nolist
	mov ebx, %1
	mov eax, 1
	int 80h
%endmacro
%endif

; Synonym for MASM invoke
%ifnmacro INVOKE
%macro INVOKE 1-*.nolist
	%rep %0 - 1
	%rotate -1
	push dword %1
	%endrep

	%rotate -1
	call %1

	add esp, (%0 - 1) * 4
%endmacro
%endif

%ifnmacro mWrite
;------------------------------------------------------
%macro mWrite 1.nolist
;
; Writes a string literal to standard output.
; Receives: a string enclosed in single or double
;   quotes (null terminator not required).
;------------------------------------------------------
segment .data
	%%string: db %1, 0
segment .text
	push edx
	mov  edx, %%string
	call WriteString
	pop  edx
%endmacro
%endif

%ifnmacro mWriteSpace
;------------------------------------------------------
%macro mWriteSpace 0-1.nolist 1
;
; Writes one or more spaces to standard output.
; Receives: an integer specifying the number of spaces.
;   If count is blank, a single space is written.
;------------------------------------------------------
segment .data
%%spaces: times %1 db ' '
	  db 0
segment .text
	push edx
	mov  edx, %%spaces
	call WriteString
	pop  edx
%endmacro
%endif

%ifnmacro mShowRegister
;---------------------------------------------------
%macro mShowRegister 2.nolist
;
; Displays a 32-bit register name and contents.
; Receives: the register name, the register value.
;---------------------------------------------------
segment .data
%%tempStr: db "  ", %1, "=", 0

segment .text
	push eax

; Display the register name
	push edx
	mov  edx, %%tempStr
	call WriteString
	pop  edx

; Display the register contents
	mov  eax, %2
	call WriteHex
	pop  eax
%endmacro
%endif

%endif	    ; end of the file
