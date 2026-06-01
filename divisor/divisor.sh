nvc -a divisor.vhd
nvc -a divisor_tb.vhd
nvc -e divisor_tb

nvc -r divisor_tb --stop-time=1000ms --wave=divisor.vcd