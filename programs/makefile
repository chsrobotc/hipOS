# make and write all programs associated

dev = /dev/sdf

all:
	nasm hello.asm -f bin -o hello.bin
	sudo dd if=hello.bin of=$(dev) seek=10
	
	nasm about.asm -f bin -o about.bin
	sudo dd if=about.bin of=$(dev) seek=9
	
	nasm echo.asm -f bin -o echo.bin
	sudo dd if=echo.bin of=$(dev) seek=11
	
	nasm add.asm -f bin -o add.bin
	sudo dd if=add.bin of=$(dev) seek=12
