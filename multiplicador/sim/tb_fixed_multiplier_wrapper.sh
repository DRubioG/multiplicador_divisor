nvc -a ../../../src/Operaciones/multiplier.vhd
nvc -a ../../../src/Operaciones/multiplier_wrapper_fixed.vhd

nvc -a tb_fixed_multipler_wrapper.vhd

nvc -e fixed_multiplier_wrapper_tb

nvc -r fixed_multiplier_wrapper_tb --stop-time=1us --wave=fixed_multiplier_wrapper_tb.vcd