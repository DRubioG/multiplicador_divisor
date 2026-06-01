
nvc -a multiplier.vhd
nvc -a tb_multiplier.vhd
nvc -e tb_multiplier
nvc -r tb_multiplier --stop-time=500ns --wave=multiplier.vcd