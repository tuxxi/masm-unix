; Include file for Along32 library          (Along32.inc)
; Copyright (C) 2009 Curtis Wong.
; All right reserved.
; Email: airekans@gmail.com
; Homepage: http://along32.sourceforge.net
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
; Last update: 2009/08/20

%ifndef ALONG32
%define ALONG32

; ------------------------------------------
; function descriptions 
; ------------------------------------------
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

; ------------------------------------------
; function prototypes
; ------------------------------------------
extern Clrscr
extern Crlf
extern Delay
extern DumpMem
extern DumpRegs
extern Gotoxy
extern IsDigit
extern ParseDecimal32
extern ParseInteger32
extern Random32
extern Randomize
extern RandomRange
extern ReadChar
extern ReadDec
extern ReadHex
extern ReadInt
extern ReadKey
extern ReadString
extern Str_compare
extern Str_copy
extern Str_length
extern Str_trim
extern Str_ucase
extern WriteBin
extern WriteBinB
extern WriteChar
extern WriteDec
extern WriteHex
extern WriteHexB
extern WriteInt
extern WriteString
; ------------------------------------------

%endif
