# See LICENSE.SiFive for license details

debug_rom = debug_rom.sv debug_rom_one_scratch.sv

GCC?=riscv64-unknown-elf-gcc
OBJCOPY?=riscv64-unknown-elf-objcopy
OBJDUMP?=riscv64-unknown-elf-objdump
FLAGS?=

PYTHON ?= python

all: $(debug_rom) rename

%.sv: %.img
	$(PYTHON) gen_rom.py $<

%.img: %.bin
	dd if=$< of=$@ bs=256 count=1

%.bin: %.elf
	$(OBJCOPY) -O binary $< $@

%.elf: $(findstring debug_rom, $(debug_rom)).S link.ld
	$(GCC) $(if  $(findstring one_scratch,$@),,-DSND_SCRATCH=1) $(FLAGS) -I$(RISCV)/include -Tlink.ld $< -nostdlib -fPIC -static -Wl,--no-gc-sections -o $@

%.dump: %.elf
	$(OBJDUMP) -d $< --disassemble-all --disassemble-zeroes --section=.text --section=.text.startup --section=.text.init --section=.data  > $@

clean:
	rm -f *.img *.dump *.bin *.sv

rename:
	$(shell grep -rl "debug_rom" debug_rom.sv | xargs sed -i 's/debug_rom/debug_ot_rom/g')
	$(shell grep -rl "debug_rom_one_scratch" debug_rom_one_scratch.sv | xargs sed -i 's/debug_rom_one_scratch/debug_ot_rom_one_scratch/g')
