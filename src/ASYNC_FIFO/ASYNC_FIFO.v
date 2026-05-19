/*-----------------------------------------------------------------------------
* ASYNC_FIFO.v
*
* Asynchronous FIFO
*
* Version: 0.13
* Author : AUDIY
* Date   : 2026/05/19
*
* Port
*   Input
*       WRITE_CLK_I    : Write Clock Input
*       WRITE_EN_I     : Write Enable Input
*       WRITE_DATA_I   : Write Data Input
*       WRITE_ARESETN_I: Write Asynchronous Reset (Active Low)
*       READ_CLK_I     : Read Clock Input
*       READ_EN_I      : Read Enable Input
*       READ_ARESETN_I : Read Asynchronous Reset (Active Low)
*
*   Output
*       WRITE_FULL_O              : Write Full Flag Output
*       WRITE_ALMOST_FULL_O       : Write Almost Full Flag Output
*       WRITE_PROGRAMMABLE_FULL_O : Write Programmable Full Flag Output
*       READ_DATA_O               : Read Data Output
*       READ_EMPTY_O              : Read Empty Flag Output
*       READ_ALMOST_EMPTY_O       : Read Almost Empty Flag Output
*       READ_PROGRAMMABLE_EMPTY_O : Read Programmable Empty Flag Output
*
* Parameter
*       ADDR_WIDTH                  : FIFO Address Width (Default: 8)
*       DATA_WIDTH                  : FIFO Data Width (Default: 8)
*       PROGRAMMABLE_FULL_THRESHOLD : Programmable Full Threshold (Default: 4)
*       PROGRAMMABLE_EMPTY_THRESHOLD: Programmable Empty Threshold (Default: 4)
*       WRITE_PROTECT_FULL          : Write Protect Full Enable (Default: 1'b1)
*       READ_PROTECT_EMPTY          : Read Protect Empty Enable (Default: 1'b1)
*       FWFT                        : First Word Fall Through Enable (Default: 1'b0)
*       DFF_SYNC_STAGE              : The number of D-FF Synchronizer Stage (Default: 2)
*
* License
--------------------------------------------------------------------------------
| Copyright AUDIY 2026.                                                        |
|                                                                              |
| This source describes Open Hardware and is licensed under the CERN-OHL-W v2. |
|                                                                              |
| You may redistribute and modify this source and make products using it under |
| the terms of the CERN-OHL-W v2 (https://cern.ch/cern-ohl).                   |
|                                                                              |
| This source is distributed WITHOUT ANY EXPRESS OR IMPLIED WARRANTY,          |
| INCLUDING OF MERCHANTABILITY, SATISFACTORY QUALITY AND FITNESS FOR A         |
| PARTICULAR PURPOSE. Please see the CERN-OHL-W v2 for applicable conditions.  |
|                                                                              |
| Source location: https://github.com/AUDIY/ASYNC_FIFO                         |
|                                                                              |
| As per CERN-OHL-W v2 section 4.1, should You produce hardware based on these |
| sources, You must maintain the Source Location visible on the external case  |
| of the ASYNC_FIFO or other products you make using this source.              |
--------------------------------------------------------------------------------
*
-----------------------------------------------------------------------------*/
`default_nettype none

module ASYNC_FIFO #(
    /* Parameter Definition */
    parameter ADDR_WIDTH                   = 8,
    parameter DATA_WIDTH                   = 8,
    parameter PROGRAMMABLE_FULL_THRESHOLD  = 4,
    parameter PROGRAMMABLE_EMPTY_THRESHOLD = 4,
    parameter WRITE_PROTECT_FULL           = 1'b1,
    parameter READ_PROTECT_EMPTY           = 1'b1,
    parameter FWFT                         = 1'b0,
    parameter DFF_SYNC_STAGE               = 2
) (
    /* Write Domain */
    input  wire                      WRITE_CLK_I,
    input  wire                      WRITE_EN_I,
    input  wire [(DATA_WIDTH - 1):0] WRITE_DATA_I,
    input  wire                      WRITE_ARESETN_I,
    output wire                      WRITE_FULL_O,
    output wire                      WRITE_ALMOST_FULL_O,
    output wire                      WRITE_PROGRAMMABLE_FULL_O,
    
    /* Read Domain */
    input  wire                      READ_CLK_I,
    input  wire                      READ_EN_I,
    input  wire                      READ_ARESETN_I,
    output wire [(DATA_WIDTH - 1):0] READ_DATA_O,
    output wire                      READ_EMPTY_O,
    output wire                      READ_ALMOST_EMPTY_O,
    output wire                      READ_PROGRAMMABLE_EMPTY_O
);

    localparam PTR_WIDTH = ADDR_WIDTH + 1;
    localparam TRUE_DFF_SYNC_STAGE = (DFF_SYNC_STAGE < 2) ? 2 : DFF_SYNC_STAGE;

    wire w_en;
    
    wire [(PTR_WIDTH - 1):0] w_addr;
    wire [(PTR_WIDTH - 1):0] w_addr_next;
    wire [(PTR_WIDTH - 1):0] w_gray;
    wire [(PTR_WIDTH - 1):0] w_gray_next;

    reg  [(PTR_WIDTH - 1):0] r_gray_sync [(TRUE_DFF_SYNC_STAGE - 1):0];
    wire [(PTR_WIDTH - 1):0] r_gray_sync_last;
    wire [(PTR_WIDTH - 1):0] r_addr_sync_last;

    wire w_full_wire;
    reg  w_full_reg  = 1'b0;
    wire w_afull_wire;
    reg  w_afull_reg = 1'b0;
    wire w_pfull_wire;
    reg  w_pfull_reg = 1'b0;

    wire r_en;
    
    wire [(PTR_WIDTH - 1):0] r_addr;
    wire [(PTR_WIDTH - 1):0] r_addr_nofwft;
    wire [(PTR_WIDTH - 1):0] r_addr_next;
    wire [(PTR_WIDTH - 1):0] r_gray;
    wire [(PTR_WIDTH - 1):0] r_gray_next;

    reg  [(PTR_WIDTH - 1):0] w_gray_sync [(TRUE_DFF_SYNC_STAGE - 1):0];
    wire [(PTR_WIDTH - 1):0] w_gray_sync_last;
    wire [(PTR_WIDTH - 1):0] w_addr_sync_last;

    wire r_empty_wire;
    reg  r_empty_reg  = 1'b0;
    wire r_aempty_wire;
    reg  r_aempty_reg = 1'b0;
    wire r_pempty_wire;
    reg  r_pempty_reg = 1'b0;

    integer i, j, k;

    initial begin
        for (i = 0; i < TRUE_DFF_SYNC_STAGE; i = i + 1) begin
            r_gray_sync[i] = {(PTR_WIDTH){1'b0}};
            w_gray_sync[i] = {(PTR_WIDTH){1'b0}};
        end
    end
    
    /* Write Clock Domain */
    generate
        if (WRITE_PROTECT_FULL == 1'b1) begin: genif_wprotect1
            assign w_en = WRITE_EN_I & (~WRITE_FULL_O);
        end else begin: genif_wprotect0
            assign w_en = WRITE_EN_I;
        end
    endgenerate

    // Write Address Control
    ASYNC_FIFO_ADDR_CTRL #(
        .ADDR_WIDTH(PTR_WIDTH)
    ) u_wr_addr_ctrl (
        .CLK_I      (WRITE_CLK_I    ),
        .ARESETN_I  (WRITE_ARESETN_I),
        .ENABLE_I   (w_en           ),
        .ADDR_O     (w_addr         ),
        .GRAY_O     (w_gray         ),
        .NEXT_ADDR_O(w_addr_next    ),
        .NEXT_GRAY_O(w_gray_next    )
    );

    // Read address gray code synchronization
    always @(posedge WRITE_CLK_I or negedge WRITE_ARESETN_I) begin
        if (WRITE_ARESETN_I == 1'b0) begin
            for (j = 0; j < TRUE_DFF_SYNC_STAGE; j = j + 1) begin
                r_gray_sync[j] <= {(PTR_WIDTH){1'b0}};
            end
        end else begin
            r_gray_sync[0] <= r_gray;
            for (j = 1; j < TRUE_DFF_SYNC_STAGE; j = j + 1) begin
                r_gray_sync[j] <= r_gray_sync[j - 1];
            end
        end
    end

    assign r_gray_sync_last = r_gray_sync[TRUE_DFF_SYNC_STAGE - 1];

    // Full Detection
    assign w_full_wire = (w_gray_next == {~r_gray_sync_last[(PTR_WIDTH - 1):(PTR_WIDTH - 2)], r_gray_sync_last[(PTR_WIDTH - 3):0]});

    always @(posedge WRITE_CLK_I or negedge WRITE_ARESETN_I) begin
        if (WRITE_ARESETN_I == 1'b0) begin
            w_full_reg <= 1'b0;
        end else begin
            w_full_reg <= w_full_wire;
        end
    end

    // Gray code to Binary Decoder
    // Please Refer https://github.com/AUDIY/AUDIY_Verilog_IP/tree/main/GRAY2BIN for detail.
    GRAY2BIN #(
        .GRAY_WIDTH(PTR_WIDTH)
    ) u_wr_gray2bin (
        .GRAY_I(r_gray_sync_last),
        .BIN_O (r_addr_sync_last)
    );

    // Almost Full Detection
    assign w_afull_wire = (({~r_addr_sync_last[PTR_WIDTH - 1], r_addr_sync_last[(PTR_WIDTH - 2):0]} - w_addr_next) <= 1);

    always @(posedge WRITE_CLK_I or negedge WRITE_ARESETN_I) begin
        if (WRITE_ARESETN_I == 1'b0) begin
            w_afull_reg <= 1'b0;
        end else begin
            w_afull_reg <= w_afull_wire;
        end
    end

    // Programmable Full Detection
    assign w_pfull_wire = (({~r_addr_sync_last[PTR_WIDTH - 1], r_addr_sync_last[(PTR_WIDTH - 2):0]} - w_addr_next) <= PROGRAMMABLE_FULL_THRESHOLD);

    always @(posedge WRITE_CLK_I or negedge WRITE_ARESETN_I) begin
        if (WRITE_ARESETN_I == 1'b0) begin
            w_pfull_reg <= 1'b0;
        end else begin
            w_pfull_reg <= w_pfull_wire;
        end
    end

    /* Read Clock Domain */
    generate
        if (READ_PROTECT_EMPTY == 1'b1) begin: genif_rprotect1
            assign r_en = READ_EN_I & (~READ_EMPTY_O);
        end else begin: genif_rprotect0
            assign r_en = READ_EN_I;
        end
    endgenerate

    // Read Address Control
    ASYNC_FIFO_ADDR_CTRL #(
        .ADDR_WIDTH(PTR_WIDTH)
    ) u_rd_addr_ctrl (
        .CLK_I      (READ_CLK_I    ),
        .ARESETN_I  (READ_ARESETN_I),
        .ENABLE_I   (r_en          ),
        .ADDR_O     (r_addr_nofwft ),
        .GRAY_O     (r_gray        ),
        .NEXT_ADDR_O(r_addr_next   ),
        .NEXT_GRAY_O(r_gray_next   )
    );

    // Write address gray code synchronization
    always @(posedge READ_CLK_I or negedge READ_ARESETN_I) begin
        if (READ_ARESETN_I == 1'b0) begin
            for (k = 0; k < TRUE_DFF_SYNC_STAGE; k = k + 1) begin
                w_gray_sync[k] <= {(PTR_WIDTH){1'b0}};
            end
        end else begin
            w_gray_sync[0] <= w_gray;
            for (k = 1; k < TRUE_DFF_SYNC_STAGE; k = k + 1) begin
                w_gray_sync[k] <= w_gray_sync[k - 1];
            end 
        end
    end

    assign w_gray_sync_last = w_gray_sync[TRUE_DFF_SYNC_STAGE - 1];

    // Empty Detection
    assign r_empty_wire = (r_gray_next == w_gray_sync_last);

    always @(posedge READ_CLK_I or negedge READ_ARESETN_I) begin
        if (READ_ARESETN_I == 1'b0) begin
            r_empty_reg <= 1'b0;
        end else begin
            r_empty_reg <= r_empty_wire;
        end
    end

    // Gray code to Binary Decoder
    // Please Refer https://github.com/AUDIY/AUDIY_Verilog_IP/tree/main/GRAY2BIN for detail.
    GRAY2BIN #(
        .GRAY_WIDTH(PTR_WIDTH)
    ) u_rd_gray2bin (
        .GRAY_I(w_gray_sync_last),
        .BIN_O (w_addr_sync_last)
    );

    // Almost Empty Detection
    assign r_aempty_wire = ((w_addr_sync_last - r_addr_next) <= 1);

    always @(posedge READ_CLK_I or negedge READ_ARESETN_I) begin
        if (READ_ARESETN_I == 1'b0) begin
            r_aempty_reg <= 1'b0;
        end else begin
            r_aempty_reg <= r_aempty_wire;
        end
    end

    // Programmable Empty Detection
    assign r_pempty_wire = ((w_addr_sync_last - r_addr_next) <= PROGRAMMABLE_EMPTY_THRESHOLD);

    always @(posedge READ_CLK_I or negedge READ_ARESETN_I) begin
        if (READ_ARESETN_I == 1'b0) begin
            r_pempty_reg <= 1'b0;
        end else begin
            r_pempty_reg <= r_pempty_wire;
        end
    end

    /* RAM */
    generate
        if (FWFT == 1'b1) begin: genif_fwft1
            assign r_addr = r_addr_nofwft + (r_en ? 1'b1 : 1'b0);
        end else begin: genif_fwft0
            assign r_addr = r_addr_nofwft;
        end
    endgenerate

    // Simple Dual Port RAM
    // Please Refer https://github.com/AUDIY/AUDIY_Verilog_IP/tree/main/Memory/SDPRAM_DUALCLK for more detail
    SDPRAM_DUALCLK #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) u_ram (
        .WCLK_I   (WRITE_CLK_I               ),
        .WENABLE_I(w_en                      ),
        .WADDR_I  (w_addr[(ADDR_WIDTH - 1):0]),
        .WDATA_I  (WRITE_DATA_I              ),
        .RCLK_I   (READ_CLK_I                ),
        .RENABLE_I(r_en                      ),
        .RADDR_I  (r_addr[(ADDR_WIDTH - 1):0]),
        .RDATA_O  (READ_DATA_O               )
    );

    // Flag output
    assign WRITE_FULL_O              = w_full_reg ;
    assign WRITE_ALMOST_FULL_O       = w_afull_reg;
    assign WRITE_PROGRAMMABLE_FULL_O = w_pfull_reg;
    
    assign READ_EMPTY_O              = r_empty_reg ;
    assign READ_ALMOST_EMPTY_O       = r_aempty_reg;
    assign READ_PROGRAMMABLE_EMPTY_O = r_pempty_reg;

endmodule

`default_nettype wire
