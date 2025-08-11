GREEN='\033[32m'
NC='\033[0m'
logo='`7MMF*`7MM***Mq.  `7MMF*  .g8""8q.   `7MN.   `7MF*
  MM    MM   `MM.   MM  .dP*    `YM.   MMN.    M  
  MM    MM   ,M9    MM  dM*      `MM   M YMb   M  
  MM    MMmmdM9     MM  MM        MM   M  `MN. M  
  MM    MM  YM.     MM  MM.      ,MP   M   `MM.M  
  MM    MM   `Mb.   MM  `Mb.    ,dP*   M     YMM  
.JMML..JMML. .JMM..JMML.  `"bmmd"*   .JML.    YM'

clear

echo " "
echo "${logo}"
echo " "

echo -e "${GREEN}Compiling the bootloader${NC}"
nasm -f bin src/boot/boot.asm -o bin/boot.bin

echo -e "${GREEN}Compiling the kernel and programs${NC}"
nasm -f bin src/kernel/kernel.asm -o bin/kernel.bin
nasm -f bin program/calc.asm -o bin/calc.bin
nasm -f bin program/blockNote.asm -o bin/blockNote.bin
nasm -f bin program/bsod.asm -o bin/bsod.bin

echo -e "${GREEN}Creating a disk image${NC}"
dd if=/dev/zero of=img/irion.img bs=512 count=50

dd if=bin/boot.bin of=img/irion.img conv=notrunc
dd if=bin/kernel.bin of=img/irion.img bs=512 seek=1 conv=notrunc
dd if=bin/calc.bin of=img/irion.img bs=512 seek=5 conv=notrunc
dd if=bin/blockNote.bin of=img/irion.img bs=512 seek=10 conv=notrunc
dd if=bin/bsod.bin of=img/irion.img bs=512 seek=20 conv=notrunc

echo -e "${GREEN}Create ISO file"
dd if=img/irion.img of=iso/irion.iso bs=512 count=50

echo -e "${GREEN}Launching QEMU...${NC}"
qemu-system-i386 -audiodev pa,id=snd0 -machine pcspk-audiodev=snd0 -hda img/irion.img

