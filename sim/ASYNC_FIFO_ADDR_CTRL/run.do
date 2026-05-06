add log -r *

add wave -position insertpoint  \
sim:/ASYNC_FIFO_ADDR_CTRL_tb/dut/CLK_I \
sim:/ASYNC_FIFO_ADDR_CTRL_tb/dut/ARESETN_I \
sim:/ASYNC_FIFO_ADDR_CTRL_tb/dut/ENABLE_I \
sim:/ASYNC_FIFO_ADDR_CTRL_tb/dut/ADDR_O \
sim:/ASYNC_FIFO_ADDR_CTRL_tb/dut/GRAY_O \
sim:/ASYNC_FIFO_ADDR_CTRL_tb/dut/NEXT_ADDR_O \
sim:/ASYNC_FIFO_ADDR_CTRL_tb/dut/NEXT_GRAY_O

onfinish stop

run -all

coverage report -output ASYNC_FIFO_ADDR_CTRL_coverage_report.txt -srcfile=* -assert -directive -cvg -codeAll