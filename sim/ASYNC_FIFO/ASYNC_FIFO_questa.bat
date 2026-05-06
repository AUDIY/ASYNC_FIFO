vlib work
vdel -lib work -all
vlib work

vmap work work

vlog +cover=bcefst ../../src/ASYNC_FIFO/ASYNC_FIFO.v
vlog ../../src/ASYNC_FIFO_ADDR_CTRL/ASYNC_FIFO_ADDR_CTRL.v
vlog ../../src/AUDIY_Verilog_IP/ARESETN_SYNC/ARESETN_SYNC.v
vlog ../../src/AUDIY_Verilog_IP/BIN2GRAY/BIN2GRAY.v
vlog ../../src/AUDIY_Verilog_IP/GRAY2BIN/GRAY2BIN.v
vlog ../../src/AUDIY_Verilog_IP/Memory/SDPRAM_DUALCLK/SDPRAM_DUALCLK.v
vlog -sv ../../src/ASYNC_FIFO/ASYNC_FIFO_tb.sv

vsim -t ns -coverage -voptargs=+acc -debugdb=+acc -assertdebug work.ASYNC_FIFO_tb -do "do run.do"