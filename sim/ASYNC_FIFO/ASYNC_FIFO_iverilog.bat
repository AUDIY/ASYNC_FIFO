:@echo off

cd /d %~dp1

del /Q ASYNC_FIFO.o
del /Q ASYNC_FIFO.vcd

iverilog -o ASYNC_FIFO.o -s ASYNC_FIFO_tb ^
-g2012 ../../src/ASYNC_FIFO/ASYNC_FIFO_tb.sv ^
../../src/ASYNC_FIFO/ASYNC_FIFO.v ^
../../src/ASYNC_FIFO_ADDR_CTRL/ASYNC_FIFO_ADDR_CTRL.v ^
../../src/AUDIY_Verilog_IP/ARESETN_SYNC/ARESETN_SYNC.v ^
../../src/AUDIY_Verilog_IP/BIN2GRAY/BIN2GRAY.v ^
../../src/AUDIY_Verilog_IP/GRAY2BIN/GRAY2BIN.v ^
../../src/AUDIY_Verilog_IP/Memory/SDPRAM_DUALCLK/SDPRAM_DUALCLK.v

vvp ASYNC_FIFO.o

gtkwave ASYNC_FIFO.vcd
