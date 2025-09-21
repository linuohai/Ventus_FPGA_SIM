
module regs_ext(
  input W0_clk,
  input [7:0] W0_addr,
  input W0_en,
  input [511:0] W0_data,
  input [15:0] W0_mask,
  input R0_clk,
  input [7:0] R0_addr,
  input R0_en,
  output [511:0] R0_data
);

  reg reg_R0_ren;
  reg [7:0] reg_R0_addr;
  reg [511:0] ram [255:0];
  `ifdef RANDOMIZE_MEM_INIT
    integer initvar;
    initial begin
      #`RANDOMIZE_DELAY begin end
      for (initvar = 0; initvar < 256; initvar = initvar+1)
        ram[initvar] = {16 {$random}};
      reg_R0_addr = {1 {$random}};
    end
  `endif
  integer i;
  always @(posedge R0_clk)
    reg_R0_ren <= R0_en;
  always @(posedge R0_clk)
    if (R0_en) reg_R0_addr <= R0_addr;
  generate
    genvar gvar;
    for (gvar=0; gvar<16; gvar=gvar+1) begin
      always @(posedge W0_clk) begin
        if (W0_en) begin
          if (W0_mask[gvar]) begin
            ram[W0_addr][gvar*32 +: 32] <= W0_data[gvar*32 +: 32];
          end
        end
      end
    end
  endgenerate
  `ifdef RANDOMIZE_GARBAGE_ASSIGN
  reg [511:0] R0_random;
  `ifdef RANDOMIZE_MEM_INIT
    initial begin
      #`RANDOMIZE_DELAY begin end
      R0_random = {$random, $random, $random, $random, $random, $random, $random, $random, $random, $random, $random, $random, $random, $random, $random, $random};
      reg_R0_ren = R0_random[0];
    end
  `endif
  always @(posedge R0_clk) R0_random <= {$random, $random, $random, $random, $random, $random, $random, $random, $random, $random, $random, $random, $random, $random, $random, $random};
  assign R0_data = reg_R0_ren ? ram[reg_R0_addr] : R0_random[511:0];
  `else
  assign R0_data = ram[reg_R0_addr];
  `endif

endmodule