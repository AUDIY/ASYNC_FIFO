:@echo off

wsl verilator --cc --binary --timing --trace-vcd --trace-params --trace-structs ^
--trace-underscore -Wno-WIDTHEXPAND -Wno-TIMESCALEMOD -Wno-WIDTHTRUNC -Wno-INITIALDLY --assert --coverage ^
-I../../src/ASYNC_FIFO ^
-I../../src/ASYNC_FIFO_ADDR_CTRL ^
-I../../src/AUDIY_Verilog_IP/ARESETN_SYNC ^
-I../../src/AUDIY_Verilog_IP/BIN2GRAY ^
-I../../src/AUDIY_Verilog_IP/GRAY2BIN ^
-I../../src/AUDIY_Verilog_IP/Memory/SDPRAM_DUALCLK ^
../../src/ASYNC_FIFO/ASYNC_FIFO_tb.sv

cd obj_dir

wsl ./VASYNC_FIFO_tb

gtkwave ASYNC_FIFO.vcd

cd ..

wsl verilator_coverage --annotate ./coverage --annotate-all --annotate-min 1 --write-info ./coverage/coverage.info ./obj_dir/coverage.dat

wsl genhtml ./coverage/coverage.info --branch-coverage -o ./coverage/info
