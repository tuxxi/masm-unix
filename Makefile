
UNAME_S := $(shell uname -s)

ifeq ($(UNAME_S), Linux)
CC=g++
CFLAGS = -O0 -g -m32 -march=i386 -lAlong32 -Llib -no-pie
endif
ifeq ($(UNAME_S), Darwin)
CC=clang
CFLAGS=-Wall -O0 -g -arch i386 -lAlong32 -Llib -Wl,-no_pie
endif

JWFLAGS = -nologo -zt0 -elf -Fo

LDIR=lib
BDIR=bin

SRCS=$(wildcard *.asm)
all: $(addprefix ,$(SRCS:.asm=))


# final steps: OS dependant

ifeq ($(UNAME_S),Linux)
# on Linux, just link the elf into an executable that we can run
%: %.o
	$(CC) $< -o $@ $(CFLAGS)
	cp $@ bin/$@	# move into bin
	rm $@
endif

ifeq ($(UNAME_S),Darwin)
# on OSX, we convert the elf from jwasm into a Mach-O using objconv
# because jwasm doesn't support mach-o

# link into executable
%: %.macho
	$(CC) $< -o $@ $(CFLAGS)
	cp $@ bin/$@	# move into bin
	rm $@

# use objconv to convert elf to 32-bit Mach-O
%.macho: %.o
	$(LDIR)/objconv -fmac32 -nu $< $@

endif

# Next step: use jwasm to turn masm into elf binary
%.o: %.asm.p
	$(LDIR)/jwasm $(JWFLAGS) $@ $<

# First step: use perl -e to replace "Include Irvine32.inc" with "Include lib/Along32.inc"
%.asm.p: %.asm
	mkdir -p $(BDIR)
	cp $< $@
	perl -pi -e 's,Include Irvine32.inc,Include lib/Along32.inc,i' $@

clean:
	rm -Rf $(BDIR)

.PHONY: all clean