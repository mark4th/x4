## -----------------------------------------------------------------------
##  Configuration

# these should realy be set in the master make file

list = -l../kernel.lst
debug = -g

## -----------------------------------------------------------------------
##  Variables

flags = $(debug) $(list) -felf32

all: kernel

includes = \
	reloc.s syscalls.s stack.s memory.s \
	logic.s math.s loops.s exec.s \
	io.s find.s fload.s compile.s interpret.s \
	vocabs.s

kernel: kernel.o
	@ld -O2 -m elf_i386 ldscript -o../../kernel.com ../kernel.o
	@strip -R .comment ../../kernel.com

kernel.o: x4.asm $(includes)
	@nasm $(flags) x4.asm -o ../kernel.o

## =======================================================================
