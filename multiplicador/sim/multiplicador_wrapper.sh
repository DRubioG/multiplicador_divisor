
nvc -a ../src/multiplier.vhd
nvc -a ../src/multiplier_wrapper.vhd
nvc -a multipler_wrapper_tb.vhd
nvc -e multiplier_wraper_tb
nvc -r multiplier_wraper_tb --stop-time=500ns --wave=multiplier_wraper_tb.vcd