add log -r *

add wave -position insertpoint  \
sim:/ASYNC_FIFO_tb/dut/WRITE_CLK_I \
sim:/ASYNC_FIFO_tb/dut/WRITE_EN_I \
sim:/ASYNC_FIFO_tb/dut/WRITE_DATA_I \
sim:/ASYNC_FIFO_tb/dut/WRITE_ARESETN_I \
sim:/ASYNC_FIFO_tb/dut/WRITE_FULL_O \
sim:/ASYNC_FIFO_tb/dut/WRITE_ALMOST_FULL_O \
sim:/ASYNC_FIFO_tb/dut/WRITE_PROGRAMMABLE_FULL_O \
sim:/ASYNC_FIFO_tb/dut/READ_CLK_I \
sim:/ASYNC_FIFO_tb/dut/READ_EN_I \
sim:/ASYNC_FIFO_tb/dut/READ_ARESETN_I \
sim:/ASYNC_FIFO_tb/dut/READ_DATA_O \
sim:/ASYNC_FIFO_tb/dut/READ_EMPTY_O \
sim:/ASYNC_FIFO_tb/dut/READ_ALMOST_EMPTY_O \
sim:/ASYNC_FIFO_tb/dut/READ_PROGRAMMABLE_EMPTY_O

onfinish stop

run -all

coverage report -output ASYNC_FIFO_coverage_report.txt -srcfile=* -assert -directive -cvg -codeAll