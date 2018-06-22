LDIR=lib
BDIR=bin

SRCS=$(wildcard *.asm)
BINS=$(addprefix $(BDIR)/,$(SRCS:.asm=))

JW_FLAGS = -nologo -zt0 -elf -Fo


UNAME_S := $(shell uname -s)

ifeq ($(UNAME_S), Linux)
CC=g++
CFLAGS = -O0 -g -m32 -march=i386 -lAlong32 -Llib -no-pie
endif
ifeq ($(UNAME_S), Darwin)
CC=clang
CFLAGS = -O0 -g -arch i386 -lAlong32 -Llib -Wl,-no_pie
endif


all: $(BINS)

# final steps: OS dependant
# on Linux, just link the elf into an executable that we can run
# $(BDIR)/%: $(BDIR)/%.o
# 	$(CC) $< -o $@ $(CFLAGS)

ifeq ($(UNAME_S),Linux)
# on Linux, just link the elf into an executable that we can run
$(BDIR)/%: $(BDIR)/%.o
	$(CC) $< -o $@ $(CFLAGS)
endif

ifeq ($(UNAME_S),Darwin)
# on OSX, we convert the elf from jwasm into a Mach-O using objconv
# because jwasm doesn't support mach-o

# link into executable using (clang by default)
$(BDIR)/%: $(BDIR)/%.macho
	$(CC) $< -o $@ $(CFLAGS)

# use objconv to convert elf to 32-bit Mach-O
$(BDIR)/%.macho: $(BDIR)/%.o
	$(LDIR)/objconv -fmac32 -nu $< $@
endif

# Next step: use jwasm to turn masm into elf binary
$(BDIR)/%.o: $(BDIR)/%.asm
	$(LDIR)/jwasm $(JW_FLAGS) $@ $<

# First step: use perl -e to replace "Include Irvine32.inc" with "Include lib/Along32.inc"
$(BDIR)/%.asm: %.asm
	mkdir -p $(BDIR)
	cp $< $@
	perl -pi -e 's,Include Irvine32.inc,Include lib/Along32.inc,i' $@

clean:
	rm -Rf $(BDIR)

.PHONY: all clean