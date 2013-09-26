dev = /dev/sdg

all: core pgm run
	
core:
	nasm boot.asm -f bin -o boot.bin
	nasm kernel.asm -f bin -o kernel.bin 
	sudo dd if=boot.bin bs=512 of=$(dev)
	sudo dd if=kernel.bin of=$(dev) seek=4
	sudo dd if=filetable of=$(dev) seek=2
	
run:
	sudo qemu-system-x86_64 -hda $(dev)
	
pgm:
	
