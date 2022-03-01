#!bin/bash
rm ibex_simple_system.log
rm ../examples/sw/simple_system/hello_test/hello_test.vmem
make -C ../examples/sw/simple_system/hello_test/
cd ..
make clean
bender update
make scripts/compile.tcl
cd scripts

