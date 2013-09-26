all:
	nasm boot.asm -f bin -o boot.bin
	nasm kernel.asm -f bin -o kernel.bin 
	sudo dd if=boot.bin bs=512 of=/dev/sdf
	sudo dd if=kernel.bin of=/dev/sdf seek=4
	sudo dd if=filetable of=/dev/sdf seek=2
	sudo qemu-system-x86_64 -hda /dev/sdf
