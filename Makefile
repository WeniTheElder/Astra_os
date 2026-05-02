run: build
	@echo "Booting..."
	@sudo qemu-system-x86_64 -hda ./boot.bin
build: 
	@echo "Assembling..."
	@nasm -f bin ./boot.asm -o boot.bin
clean: 
	@rm boot.bin