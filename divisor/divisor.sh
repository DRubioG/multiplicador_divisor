nvc -a divisor.vhd
nvc -a divisor_tb.vhd
nvc -e divisor_tb

nvc -r divisor_tb --stop-time=55000ns --wave=divisor.vcd