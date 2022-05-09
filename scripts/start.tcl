vsim testbench -t 1ps -voptargs=+acc -classdebug +OT_STRING=/home/mciani/Workspace/cva6/hardware/working_dir/opentitan/hw/top_titangrey/examples/sw/simple_system/hello_test/hello_test.elf \
    -sv_lib work-dpi/ariane_dpi

set StdArithNoWarnings 1
set NumericStdNoWarnings 1
log -r /*

delete wave *
