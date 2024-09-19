# Makefile

ASM = nasm
EMU = qemu-system-x86_64
BOOTLOADER = bootloader.bin
MYNAME = myname.bin
FLOPPY_IMG = os-image.bin

all: $(BOOTLOADER) $(MYNAME) $(FLOPPY_IMG)

$(BOOTLOADER): bootloader.asm
	$(ASM) -f bin bootloader.asm -o $(BOOTLOADER)

$(MYNAME): myname.asm
	$(ASM) -f bin myname.asm -o $(MYNAME)

$(FLOPPY_IMG): $(BOOTLOADER) $(MYNAME)
	dd if=/dev/zero of=$(FLOPPY_IMG) bs=512 count=2880
	dd if=$(BOOTLOADER) of=$(FLOPPY_IMG) bs=512 count=1 conv=notrunc
	dd if=$(MYNAME) of=$(FLOPPY_IMG) bs=512 seek=1 conv=notrunc

run: $(FLOPPY_IMG)
	$(EMU) -drive format=raw,file=$(FLOPPY_IMG),if=floppy,index=0 -boot a

clean:
	rm -f $(BOOTLOADER) $(MYNAME) $(FLOPPY_IMG)

compile:
	nasm -f bin bootloader.asm -o bootloader.bin
	dd if=bootloader.bin of=bootloader.img bs=512 count=1 conv=notrunc
	nasm -f bin myname.asm -o myname.bin
	dd if=myname.bin of=bootloader.img bs=512 seek=1 conv=notrunc
