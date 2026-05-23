# ASYNC_FIFO  
**日本語版はこちら → [README_JP](./README_JP.md)**  
A vendor-independent asynchronous FIFO module written in Verilog.

## Overview  
**ASYNC_FIFO** is a vendor-agnostic asynchronous FIFO module for FPGA designs.  
It is written in Verilog-2005 to help understand the internal architecture of asynchronous FIFOs.  
The testbench is written in SystemVerilog-2012.

## Status
![Version](https://img.shields.io/badge/Version-v0.13-green)
![license](https://img.shields.io/badge/license-CERN--OHL--W_v2-blue)

## Features  
### Almost Full / Empty  
Asserts *Almost Full* / *Almost Empty* one cycle before the FIFO reaches Full / Empty.

### Programmable Full / Empty  
Asserts *Programmable Full* when the stored data exceeds a configurable threshold,  
and *Programmable Empty* when it falls below a threshold.

### Write / Read Protection  
Prevents invalid operations such as:
- Overwriting data when the FIFO is Full  
- Re-reading already consumed data when the FIFO is Empty  

### Configurable Gray Code Synchronizer Depth  
The depth of the Gray code synchronizer can be extended beyond the typical two stages,  
which may improve MTBF in high-frequency designs.

## Modules  
This repository consists of the following modules.  
These modules are licensed under CERN-OHL-W v2.

| Module | Description |
|:------|:------------|
| [ASYNC_FIFO_ADDR_CTRL](https://github.com/AUDIY/ASYNC_FIFO/tree/main/src/ASYNC_FIFO_ADDR_CTRL) | Address generation for RAM and Gray code conversion |
| [ASYNC_FIFO](https://github.com/AUDIY/ASYNC_FIFO/tree/main/src/ASYNC_FIFO) | Core asynchronous FIFO module |

## Dependencies  
This project internally uses the following modules from [AUDIY_Verilog_IP](https://github.com/AUDIY/AUDIY_Verilog_IP).

These components are licensed under **CERN-OHL-P v2** and are **NOT covered by this repository’s license**.

| Module | Description |
|:------|:------------|
| [BIN2GRAY](https://github.com/AUDIY/AUDIY_Verilog_IP/tree/main/BIN2GRAY) | Binary to Gray code encoder |
| [GRAY2BIN](https://github.com/AUDIY/AUDIY_Verilog_IP/tree/main/GRAY2BIN) | Gray code to binary decoder |
| [SDPRAM_DUALCLK](https://github.com/AUDIY/AUDIY_Verilog_IP/tree/main/Memory/SDPRAM_DUALCLK) | Dual-clock simple dual-port RAM |

## Notes
- The memory depth must be a power of two.
- FWFT (First-Word Fall-Through) mode is currently not functioning correctly and is planned for future support.
- For reset handling, assert resets for both write and read sides simultaneously (e.g., by connecting the output of [ARESETN_SYNC](https://github.com/AUDIY/AUDIY_Verilog_IP/tree/main/ARESETN_SYNC)), and deassert them synchronously within each respective clock domain.
- Almost Full/Empty and Programmable Full/Empty require Gray-to-binary conversion during detection, which may negatively impact Fmax. If these features are not needed, leaving them unconnected may allow synthesis tools to remove the logic, potentially improving Fmax.

## Licensed under CERN-OHL-W v2
Copyright AUDIY 2026.                                                       

This source describes Open Hardware and is licensed under the CERN-OHL-W v2.

You may redistribute and modify this source and make products using it under the terms of the CERN-OHL-W v2 (https://cern.ch/cern-ohl).

This source is distributed WITHOUT ANY EXPRESS OR IMPLIED WARRANTY, INCLUDING OF MERCHANTABILITY, SATISFACTORY QUALITY AND FITNESS FOR A PARTICULAR PURPOSE. Please see the CERN-OHL-W v2 for applicable conditions.

Source location: https://github.com/AUDIY/ASYNC_FIFO

As per CERN-OHL-W v2 section 4.1, should You produce hardware based on these sources, You must maintain the Source Location visible on the external case of the ASYNC_FIFO or other products you make using this source.
