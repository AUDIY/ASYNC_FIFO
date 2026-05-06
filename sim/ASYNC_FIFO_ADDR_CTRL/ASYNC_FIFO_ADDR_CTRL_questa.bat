vlib work
vdel -lib work -all
vlib work

vmap work work

vlog +cover=bcefst ../../src/ASYNC_FIFO_ADDR_CTRL/ASYNC_FIFO_ADDR_CTRL.v
vlog ../../src/AUDIY_Verilog_IP/ARESETN_SYNC/ARESETN_SYNC.v
vlog ../../src/AUDIY_Verilog_IP/BIN2GRAY/BIN2GRAY.v
vlog -sv ../../src/ASYNC_FIFO_ADDR_CTRL/ASYNC_FIFO_ADDR_CTRL_tb.sv

vsim -t ns -coverage -voptargs=+acc -debugdb=+acc -assertdebug work.ASYNC_FIFO_ADDR_CTRL_tb -do "do run.do"