.ONESHELL:

LDFLAGS = -nostdlib -nostartfiles -T link.ld
STRIPFLAGS = -K mmio -K fb -K bootboot -K environment -K initstack
OSNAME = tunnel
FILELIST =  main.o screen.o stdio.o tunnel.o shell.o cstring.o cint.o panic.o mm.o     \
			smt.o keyboard_ps2.o tools.o serial.o idt.o idta.o pit.o window.o fs.o ui.o\
	    	window_welcome.o shell_mouse.o ide.o idea.o event.o fpua.o path.o hal.o    \
	    	tunnelconfig/system.o cpuid_toolsa.o ssea.o avxa.o sse.o uhci.o cmos.o     \
	    	easter.o math.o desktop.o pita.o toolsa.o pica.o rtc.o nmi.o stdlib.o api.o\
	    	encoder.o sort.o cJSON/cJSON.o cJSON/cJSON_Utils.o systemconf.o pic.o      \
	    	trnd.o unitype.o placeholder.o test.o
FONTLIST = fonts/text.o fonts/gui.o

all: $(OSNAME).x86_64.elf iso fullclean

setup:
	@bash setup.sh
help:
	@echo "Avaliable commands"
	@echo "make all - compiles code into iso file"
	@echo "make setup - sets up compiling environment"
	@echo "make iso - generates iso file"
	@echo "make clean - cleans folder from object files"
	@echo "make fullclean - execute clean and remove target files"
	@echo "make vhd - generate vhd file"
	@echo "make turron - starts qemu"
$(OSNAME).x86_64.elf:
	@rm -rfv debug 
	@mkdir debug
	@bash finder.sh
	@ld $(LDFLAGS) $(FILELIST) $(FONTLIST) -o $(OSNAME).x86_64.elf || false
	@strip $(STRIPFLAGS) $(OSNAME).x86_64.elf
	@readelf -hls $(OSNAME).x86_64.elf > $(OSNAME).x86_64.txt
	@rm -rfv fonts_compiled
	@mkdir fonts_compiled
	@mv fonts/*.o fonts_compiled/
	@cp $(OSNAME).x86_64.elf debug/$(OSNAME).x86_64.elf
	@cd debug
	@objdump -D tunnel.x86_64.elf > tunnel.x86_64.txt
	@cd ..
iso:
	@rm -rv iso
	@mkdir iso
	@mkdir iso/tmp
	@mkdir iso/tmp/mkbootimg
	@cp bootboot/mkbootimg iso/tmp/mkbootimg/ -r
	@mkdir iso/tmp/sys
	@cp tunnelconfig/* .
	@cp config iso/tmp/sys/
	@cd iso/tmp/mkbootimg/mkbootimg
	@make all
	@cp ../../../../$(OSNAME).x86_64.elf . -r
	@cp ../../../../$(OSNAME).json . -r
	@./mkbootimg check $(OSNAME).x86_64.elf
	@mkdir boot
	@cp ../../sys boot/ -r
	@cp $(OSNAME).x86_64.elf boot/sys/core -r
	@./mkbootimg $(OSNAME).json $(OSNAME).x86_64.img
	@mv $(OSNAME).x86_64.img ../../../$(OSNAME).x86_64.img -v
	@cd ../../../
	@rm -rf tmp
	@iat $(OSNAME).x86_64.img $(OSNAME).x86_64.iso
	@du -h $(OSNAME).x86_64.iso
	@du -h ../$(OSNAME).x86_64.elf
	@rm -rfv $(OSNAME).x86_64.img
	@cd ../
	@rm -rf config tunnel.json
clean:
	@rm -rf *.o fonts/*.o tunnelconfig/*.o
fullclean: clean
	@rm -rf *.elf *.iso
	@cp iso/$(OSNAME).x86_64.iso .
	@rm -rf iso
vhd:
	@dd if=/dev/zero of=VHD.img bs=1M count=512
turron:
	@qemu-system-x86_64 --cpu kvm64-v1,+avx -d int --boot d --cdrom $(OSNAME).x86_64.iso -m 20M -smp 3 -serial stdio -drive file=VHD.img,index=0,if=ide,format=raw -s -S
