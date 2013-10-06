# make and write all programs associated

dev = /dev/sdf

all:
	nasm hello.asm -f bin -o hello.bin
	sudo dd if=hello.bin of=$(dev) seek=10
