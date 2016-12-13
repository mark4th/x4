

all:    linux

linux:
	cd src/kernel/ && make

clean:
	@rm -f src/kernel.o
	@rm -f src/kernel.lst
	@rm -f kernel.com
	@rm -f x4
