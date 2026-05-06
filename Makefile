.PHONY: run build clean

run: build
	@echo "Booting..."
	@sudo qemu-system-x86_64 -hda bin/boot.bin
build: 
	@echo "Assembling..."
	@nasm -f bin src/boot/boot.asm -o bin/boot.bin
	@echo "Done!"
clean:
	@echo "cleaning..."
	@rm -rf bin/boot.bin
	@echo "Done!"