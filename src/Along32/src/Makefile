# This makefile is to build the Along32 library and to install to the
# correct location for the sake of dynamic linking.
#
# Copyright (C) 2009 Curtis Wong.
# All right reserved.
# Email: airekans@gmail.com
# Homepage: http://along32.sourceforge.net
#
# Along32 library is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as 
# published by the Free Software Foundation, either version 3 of the
# License, or(at your option) any later version.
#
# Along32 library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with Along32 library.  If not, see <http://www.gnu.org/licenses/>.
#
#

# Assembler is NASM
ASM = nasm

# Format of object file depends on platform
UNAME_S := $(shell uname -s)

ifeq ($(UNAME_S), Linux)
FILE_FORMAT = elf32
endif
ifeq ($(UNAME_S), Darwin)
FILE_FORMAT = macho32
endif

# Flags used in assemblying phase
ASMFLAGS =
# Linker is ld
LINKER = ld

AR = ar

# Share libbrary option for linker
# SHLIB = -shared

all: libAlong32.a

libAlong32.a: Along32.o
	$(AR) rvs libAlong32.a Along32.o 

# libAlong32.so: Along32.o
# 	$(LINKER) -m elf_i386 $(SHLIB) Along32.o -o libAlong32.so -lc

Along32.o: Along32.asm 
	$(ASM) -f $(FILE_FORMAT) $(ASMFLAGS) -o Along32.o Along32.asm

clean:
	-rm Along32.o libAlong32.so
