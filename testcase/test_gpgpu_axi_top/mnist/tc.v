
`define drv_gpu               u_host_inter.drv_gpu
`define exe_finish            u_host_inter.exe_finish
`define get_result_addr       u_host_inter.get_result_addr
`define parsed_base           u_host_inter.parsed_base_r
`define parsed_size           u_host_inter.parsed_size_r
`define kernel_cycles         u_host_inter.kernel_cycles

`define display_mem           u_ram.display_mem
`define store_mem             u_ram.store_mem
`define mem_tmp_1             u_ram.mem_tmp_1
`define mem_tmp_2             u_ram.mem_tmp_2


//**********Selsct gaussian test case, remember modify `define NUM_THREAD at the same time**********
//`define CASE_2W8T
//`define CASE_1W16T
//`define CASE_4W4T
//`define CASE_4W8T


module tc;
  parameter METADATA_SIZE   = 1024; //the maximun size of .data
  parameter DATADATA_SIZE   = 2500; //the maximun size of .metadata

  parameter META_FNAME_SIZE = 128;
  parameter DATA_FNAME_SIZE = 128;

  parameter BUF_NUM         = 18;


  parameter FILE_NUM        = 3;


  defparam u_host_inter.META_FNAME_SIZE = META_FNAME_SIZE;
  defparam u_host_inter.DATA_FNAME_SIZE = DATA_FNAME_SIZE;
  defparam u_host_inter.METADATA_SIZE   = METADATA_SIZE;
  defparam u_host_inter.DATADATA_SIZE   = DATADATA_SIZE;

  wire clk  = u_gen_clk.clk;
  wire rstn = u_gen_rst.rst_n;
 
  reg [META_FNAME_SIZE*8-1:0] meta_fname[7:0];
  reg [DATA_FNAME_SIZE*8-1:0] data_fname[7:0];
  
  reg [31:0] sum_cycles = 32'b0;  

  initial begin
    repeat(100)
    @(posedge clk);
    init_test_file();
    test_main();
    repeat(100)
    @(posedge clk);
    $finish();
  end

  task init_test_file;
    begin

     `ifdef MNIST_SMALL
     meta_fname[0] = "./softdata/mnist_small/conv_0.metadata";
     meta_fname[1] = "./softdata/mnist_small/conv_1.metadata";
     meta_fname[2] = "./softdata/mnist_small/conv_2.metadata";

     data_fname[0] = "./softdata/mnist_small/conv_0.data";
     data_fname[1] = "./softdata/mnist_small/conv_1.data";
     data_fname[2] = "./softdata/mnist_small/conv_2.data";
     `endif

     `ifdef MNIST_TINY
     meta_fname[0] = "./softdata/mnist_tiny/conv_0.metadata";
     meta_fname[1] = "./softdata/mnist_tiny/conv_1.metadata";
     meta_fname[2] = "./softdata/mnist_tiny/conv_2.metadata";

     data_fname[0] = "./softdata/mnist_tiny/conv_0.data";
     data_fname[1] = "./softdata/mnist_tiny/conv_1.data";
     data_fname[2] = "./softdata/mnist_tiny/conv_2.data";
     `endif
     
     `ifdef CASE_1W32T
     meta_fname[0] = "./softdata/1w32t/Fan1_0.metadata";
     meta_fname[1] = "./softdata/1w32t/Fan2_0.metadata";
     meta_fname[2] = "./softdata/1w32t/Fan1_1.metadata";
     meta_fname[3] = "./softdata/1w32t/Fan2_1.metadata";
     meta_fname[4] = "./softdata/1w32t/Fan1_2.metadata";
     meta_fname[5] = "./softdata/1w32t/Fan2_2.metadata";

     data_fname[0] = "./softdata/1w32t/Fan1_0.data";
     data_fname[1] = "./softdata/1w32t/Fan2_0.data";
     data_fname[2] = "./softdata/1w32t/Fan1_1.data";
     data_fname[3] = "./softdata/1w32t/Fan2_1.data";
     data_fname[4] = "./softdata/1w32t/Fan1_2.data";
     data_fname[5] = "./softdata/1w32t/Fan2_2.data";
     `endif

     `ifdef CASE_4W4T
     meta_fname[0] = "./softdata/4x4/Fan1_0.metadata";
     meta_fname[1] = "./softdata/4x4/Fan2_0.metadata";
     meta_fname[2] = "./softdata/4x4/Fan1_1.metadata";
     meta_fname[3] = "./softdata/4x4/Fan2_1.metadata";
     meta_fname[4] = "./softdata/4x4/Fan1_2.metadata";
     meta_fname[5] = "./softdata/4x4/Fan2_2.metadata";

     data_fname[0] = "./softdata/4x4/Fan1_0.data";
     data_fname[1] = "./softdata/4x4/Fan2_0.data";
     data_fname[2] = "./softdata/4x4/Fan1_1.data";
     data_fname[3] = "./softdata/4x4/Fan2_1.data";
     data_fname[4] = "./softdata/4x4/Fan1_2.data";
     data_fname[5] = "./softdata/4x4/Fan2_2.data";
     `endif

     `ifdef CASE_4W8T
     meta_fname[0] = "./softdata/4x8/Fan1_0.metadata";
     meta_fname[1] = "./softdata/4x8/Fan2_0.metadata";
     meta_fname[2] = "./softdata/4x8/Fan1_1.metadata";
     meta_fname[3] = "./softdata/4x8/Fan2_1.metadata";
     meta_fname[4] = "./softdata/4x8/Fan1_2.metadata";
     meta_fname[5] = "./softdata/4x8/Fan2_2.metadata";
     meta_fname[6] = "./softdata/4x8/Fan1_3.metadata";
     meta_fname[7] = "./softdata/4x8/Fan2_3.metadata";

     data_fname[0] = "./softdata/4x8/Fan1_0.data";
     data_fname[1] = "./softdata/4x8/Fan2_0.data";
     data_fname[2] = "./softdata/4x8/Fan1_1.data";
     data_fname[3] = "./softdata/4x8/Fan2_1.data";
     data_fname[4] = "./softdata/4x8/Fan1_2.data";
     data_fname[5] = "./softdata/4x8/Fan2_2.data";
     data_fname[6] = "./softdata/4x8/Fan1_3.data";
     data_fname[7] = "./softdata/4x8/Fan2_3.data";
     `endif
    end
  endtask

  task test_main;
    integer i;
    integer block_num;
    begin
      for(i=0; i<FILE_NUM; i=i+1) begin
        force u_dut.l2_2_mem.m_axi_bvalid_i = 1'd0;
        init_mem(meta_fname[i], data_fname[i]);
        release u_dut.l2_2_mem.m_axi_bvalid_i;

        // 根据宏定义和文件索引决定block数量
        `ifdef MNIST_TINY
          block_num = 1; // MNIST_TINY所有文件都是1个block
        `elsif MNIST_SMALL
          if(i == 0) begin
            block_num = 16; // MNIST_SMALL第一个文件是16个block
          end else begin
            block_num = 1;  // MNIST_SMALL第二三个文件都是1个block
          end
        `else
          block_num = 1; // 其他测试默认都是1个block
        `endif

        // `drv_gpu(meta_fname[i], data_fname[i]);
        if(i==0) begin
          `get_result_addr(meta_fname[i], data_fname[i]);
        end
        
        `exe_finish(meta_fname[i], data_fname[i], block_num);
        sum_cycles = sum_cycles + `kernel_cycles;        
        #15000 if(i==(FILE_NUM-1)) begin
          print_result();
        end
        repeat(5000)
        @(posedge clk);
      end
    end
  endtask

  task init_mem;
    input      [META_FNAME_SIZE*8-1:0] fn_metadata;
    input      [DATA_FNAME_SIZE*8-1:0] fn_data;
    reg [63:0] buf_num_soft;
    reg [31:0] data         [DATADATA_SIZE-1:0];
    reg [31:0] metadata     [METADATA_SIZE-1:0];
    reg [63:0] buf_ba_w     [BUF_NUM-1:0]; //buffer's base addr
    reg [63:0] buf_size     [BUF_NUM-1:0]; //buffer's size
    reg [63:0] buf_size_tmp [BUF_NUM-1:0]; //size align
    reg [63:0] buf_asize    [BUF_NUM-1:0]; //buffer's allocate size
    reg [63:0] burst_len    [BUF_NUM-1:0]; //burst len
    reg [63:0] burst_len_div[BUF_NUM-1:0];
    reg [63:0] burst_len_mod[BUF_NUM-1:0];
    reg [63:0] burst_times  [BUF_NUM-1:0];
    reg [63:0] burst_data   /*[BUF_NUM-1:0]*/;
    reg [32:0] addr;
    integer i, j, k, l, m;
    begin
      $readmemh(fn_data, data);
      $readmemh(fn_metadata, metadata);
      buf_num_soft = {metadata[27], metadata[26]};

      //buffer base addr init
      for(i=0; i<buf_num_soft; i=i+1) begin
        buf_ba_w[i] = {metadata[i*2+29], metadata[i*2+28]};
      end

      //buffer size init
      for(i=0; i<buf_num_soft; i=i+1) begin
        buf_size[i] = {metadata[i*2+29+(buf_num_soft*2)], metadata[i*2+28+(buf_num_soft*2)]};
      end

      //buffer allocate size init,unused
      for(i=0; i<buf_num_soft; i=i+1) begin
        buf_asize[i] = {metadata[i*2+29+buf_num_soft*4], metadata[i*2+28+buf_num_soft*4]};
      end
      
      for(i=0;i<buf_num_soft;i=i+1) begin
        buf_size_tmp[i] = (buf_size[i]%4==0) ? buf_size[i] : (buf_size[i]/4)*4+4;
        burst_len[i] = buf_size_tmp[i]/4;
        burst_len_div[i] = burst_len[i]/16;
        burst_len_mod[i] = burst_len[i]%16;
        burst_times[i] = (burst_len_mod[i]==0) ? burst_len_div[i] : burst_len_div[i]+1;
        //burst_data[i] = (burst_len_mod[i]==0) ? 16 : (k<burst_times[j]-1) ? 16 : burst_len_mod[i];
      end 

      j=0; //buf_num cnt
      m=0;
      while(j<buf_num_soft) begin
        force u_ram.s_axi_bready  = 1'd1;
        k=0;
        while(k<burst_times[j]) begin
          @(posedge clk);
          if(burst_len_mod[j]==0) begin
            force u_ram.s_axi_awvalid = 1'd1;
            force u_ram.s_axi_awid    = 4'd0;
            force u_ram.s_axi_awaddr  = (k==0) ? buf_ba_w[j] : addr+16*4;//start address
            force u_ram.s_axi_awlen   = 8'hf; //16 times
            force u_ram.s_axi_awsize  = 3'd2; //4bytes
            force u_ram.s_axi_awburst = 2'd1; //INCR
          end
          else begin
            force u_ram.s_axi_awvalid = 1'd1;
            force u_ram.s_axi_awid    = 4'd0;
            force u_ram.s_axi_awaddr  = (k==0) ? buf_ba_w[j] : addr+16*4;//start address
            force u_ram.s_axi_awlen   = (k==(burst_times[j]-1))? burst_len_mod[j]-1 : 8'hf; 
            force u_ram.s_axi_awsize  = 3'd2; //4bytes
            force u_ram.s_axi_awburst = 2'd1; //INCR
          end 
          wait(u_ram.s_axi_awready==1'd1);
          @(posedge clk);
          addr                        = u_ram.s_axi_awaddr;
          release u_ram.s_axi_awvalid;
          release u_ram.s_axi_awid;   
          release u_ram.s_axi_awaddr; 
          release u_ram.s_axi_awlen;  
          release u_ram.s_axi_awsize;
          release u_ram.s_axi_awburst;
          l=0;
          burst_data = (burst_len_mod[j]==0) ? 16 : ((k<burst_times[j]-1) ? 16 : burst_len_mod[j]);
          while(l<burst_data) begin
            force u_ram.s_axi_wvalid  = 1'd1;
            force u_ram.s_axi_wdata   = (l%2==0) ? {32'd0,data[m]} : {data[m],32'd0};
            force u_ram.s_axi_wstrb   = (l%2==0) ? 8'hf : 8'hf0;
            if(l==burst_data-1)begin
              force u_ram.s_axi_wlast = 1'd1;
            end 
            wait(u_ram.s_axi_wready==1'd1);
            @(posedge clk);
            release u_ram.s_axi_wvalid;  
            release u_ram.s_axi_wdata;
            release u_ram.s_axi_wstrb;   
            release u_ram.s_axi_wlast;
            l=l+1;
            m=m+1;
          end 
          k=k+1;
        end
      wait(u_ram.s_axi_bvalid==1'd1);
      @(posedge clk);
      release u_ram.s_axi_bready;
      j=j+1;
      end 
    end
  endtask


  task print_result;
    reg   [31:0]    matrix_a   [24:0];
    reg   [31:0]    matrix_b    [15:0] ;
    reg   [31:0]    matrix_c    [9:0] ;
    reg   [31:0]    matrix_c2    [9:0] ;
    reg   [24:0]    matrix_a_pass     ;
    reg   [15:0]    matrix_b_pass     ;
    reg   [9:0]     matrix_c_pass     ;
    reg   [31:0]    conv0_size        ;
    reg   [31:0]    conv1_size        ;
    reg  [31:0]    result_addr = 32'h90007000;
    reg  [31:0]    result_addr2 = 32'h90008000;
    reg  [31:0]    conv2_size  = 32'h00000028;     

    integer i,j,k;
    begin
      @(posedge clk);


      matrix_a = {32'h3ade121e,32'h3ade121e,32'h3ade121e,32'h3ade121e,32'h3ade121e,32'h3ade121e,32'h40395231,32'h4062fab6,32'h405f7af7,32'h3f65c680,32'h3ade121e,32'h3ade121e,32'h3ec05eed,32'h408913d7,32'h3f85925a,32'h3ade121e,32'h3ade121e,32'h3f472b0d,32'h40699bed,32'h3ade121e,32'h3ade121e,32'h3ade121e,32'h409ad597,32'h3f082330,32'h3ade121e};
      matrix_b = {32'h40bcd8cc,32'h410136f0,32'h4102787e,32'h4035d51a,32'h3fbb8172,32'h400ad0bd,32'h41224622,32'h4056b7d4,32'h00000000,32'h3fe2471f,32'h411cc121,32'h3f8145a5,32'h00000000,32'h4124383c,32'h4087a818,32'h00000000};
      matrix_c = {32'h3f20960c,32'hc0eca689,32'hbec5057b,32'h40818182,32'hc0115c36,32'hc016fffa,32'hc0f2abea,32'h4112a783,32'h3edec0ac,32'h40328269};
      matrix_c2 = {32'h3eccd99d,32'hc06f6092,32'h3ec9ece9,32'h3ff7f27e,32'hbf616ad6,32'hc0025c14,32'hc121ab08,32'h41251c30,32'h3f349f45,32'h4068b791};



      conv0_size  = `parsed_size[3]/8 ;
      conv1_size  = (32'h40)/8 ;
      // conv2_size  = `parsed_size[3]/8 ;


      $display("----------case_mnist result----------");
      `ifdef MNIST_TINY
        $display("----------------conv0:---------------");
        for(i=0; i<conv0_size+1; i=i+1) begin
          `display_mem(`parsed_base[3]+i*8);        
        end
      //for(integer addr=`parsed_base[1]; addr<`parsed_base[1]+`parsed_size[1]; addr=addr+4) begin
      //  //$fwrite(file1,"0x%h %h%h%h%h\n",addr,`mem[addr+3],`mem[addr+2],`mem[addr+1],`mem[addr]);
      //  $display("          0x%h %h%h%h%h",addr,`mem[addr+3],`mem[addr+2],`mem[addr+1],`mem[addr]);
      //  `ifdef CASE_4W8T
      //     matrix_a_5_hard[(addr-`parsed_base[1])/4]  = {`mem[addr+3],`mem[addr+2],`mem[addr+1],`mem[addr]};
      //   `else
      //     matrix_a_4_hard[(addr-`parsed_base[1])/4]  = {`mem[addr+3],`mem[addr+2],`mem[addr+1],`mem[addr]};
      //   `endif
      //end

        $display("----------------conv1:----------------");
        for(j=0; j<conv1_size; j=j+1) begin
        `display_mem(`parsed_base[4]+j*8);        
        end
      
 
        $display("----------------RESULT:----------------");
        for(k=0; k<5; k=k+1) begin
          `display_mem(result_addr+k*8);        
        end
      `endif

      `ifdef MNIST_SMALL
        $display("----------------RESULT:----------------");
        for(k=0; k<5; k=k+1) begin
          `display_mem(result_addr2+k*8);        
        end
      `endif

      `store_mem(`parsed_base[3],`parsed_base[4],`parsed_size[3],32'h40,1,1);

      `ifdef MNIST_TINY
        for(integer i=0; i<25; i=i+1) begin        
          if(`mem_tmp_1[i]==matrix_a[24-i]) begin
            matrix_a_pass[i]  = 1'b1;
          end else begin
            matrix_a_pass[i]  = 1'b0;
          end
        end
        for(integer i=0; i<16; i=i+1) begin        
          if(`mem_tmp_2[i]==matrix_b[15-i]) begin
            matrix_b_pass[i]  = 1'b1;
          end else begin
            matrix_b_pass[i]  = 1'b0;
          end
        end

      `store_mem(result_addr,0,conv2_size,0,1,0);
        for(integer i=0; i<10; i=i+1) begin        
          if(`mem_tmp_1[i]==matrix_c[9-i]) begin
            matrix_c_pass[i]  = 1'b1;
          end else begin
            matrix_c_pass[i]  = 1'b0;
          end
        end
        // $display("matrix_a_pass: %b\nmatrix_b_pass: %b\nmatrix_c_pass: %b",matrix_a_pass,matrix_b_pass,matrix_c_pass);
      `endif

      `ifdef MNIST_SMALL
      `store_mem(result_addr2,0,conv2_size,0,1,0);
        for(integer i=0; i<10; i=i+1) begin        
          if(`mem_tmp_1[i]==matrix_c2[9-i]) begin
            matrix_c_pass[i]  = 1'b1;
          end else begin
            matrix_c_pass[i]  = 1'b0;
          end
        end
        // $display("matrix_a_pass: %b\nmatrix_b_pass: %b\nmatrix_c_pass: %b",matrix_a_pass,matrix_b_pass,matrix_c_pass);
      `endif

      `ifdef MNIST_TINY
        if((&matrix_a_pass) && (&matrix_b_pass) && (&matrix_c_pass)) begin
          $display("***********Mnist_tiny**********");
          PASSED;
        end else begin
          $display("***********Mnist_tiny**********");
          FAILED;
        end
      `endif
      `ifdef MNIST_SMALL
        if((&matrix_c_pass)) begin
          $display("***********Mnist_small*********");
          PASSED;
        end else begin
          $display("***********Mnist_small*********");
          FAILED;
        end
      `endif

      `ifdef CASE_1W32T
        if((&matrix_4_pass) && (&array_4_pass)) begin
          $display("***********case_guassian_1w32t*********");
          PASSED;
        end else begin
          $display("***********case_guassian_1w32t*********");
          FAILED;
        end
      `endif
      `ifdef CASE_4W4T
        if((&matrix_4_pass) && (&array_4_pass)) begin
          $display("***********case_guassian_4w4t**********");
          PASSED;
        end else begin
          $display("***********case_guassian_4w4t**********");
          FAILED;
        end
      `endif
      `ifdef CASE_4W8T
        if((&matrix_5_pass) && (&array_5_pass)) begin
          $display("***********case_guassian_4w8t**********");
          PASSED;
        end else begin
          $display("***********case_guassian_4w8t**********");
          FAILED;
        end
      `endif

      $display("************************************");
      $display("************************************");
      $display("All kernels need : %p cycles",sum_cycles);       
      $display("************************************");
      $display("************************************");
      

    end
  endtask

endmodule

