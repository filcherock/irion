BUILD_DIR=build


mkdir -p $BUILD_DIR

nasm -f elf src/boot.asm -o $BUILD_DIR/boot.o
gcc -m32 -ffreestanding -fno-pic -c src/kernel/kernel.cpp -o $BUILD_DIR/kernel.o

ld -m elf_i386 -T linker.ld -o $BUILD_DIR/kernel.elf \
    $BUILD_DIR/boot.o $BUILD_DIR/kernel.o
objcopy -O binary $BUILD_DIR/kernel.elf $BUILD_DIR/boot.bin

genisoimage -R -b boot.bin -no-emul-boot -boot-load-size 4 -o os.iso $BUILD_DIR/

rm -rf $BUILD_DIR

qemu-system-i386 -cdrom os.iso