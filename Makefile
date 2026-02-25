OS_SRC = os.asm
USER_SRC = user.asm
IMG = os.img

all: $(IMG)

$(IMG): $(OS_SRC) $(USER_SRC)
	nasm -f bin $(OS_SRC) -o $(IMG)
	nasm -f bin $(USER_SRC) -o user.bin
	dd if=user.bin of=$(IMG) conv=notrunc bs=512 seek=3

run: $(IMG)
	qemu-system-i386 -drive file=$(IMG),format=raw

clean:
	rm -f $(IMG) user.bin
