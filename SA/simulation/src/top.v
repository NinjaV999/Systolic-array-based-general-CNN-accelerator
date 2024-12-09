` timescale 1ns/1ps


// 有几个点需要额外考虑的
//1.什么时候使用双计数器，什么时候使用单计数器： 单一计数器的最大计数为ROWS+COLS ，因此当kernel_dim2 <= ROWS+COLS时会启用双计数器
//2.每次处理的卷积窗口个数（一个输出通道的元素数） 与ROWS 有关， 这个个数除以2 即为每次进行池化的个数，池化需要的cycle数 = x*5+2， 如果池化所需要的cycles数大于两次卷积结果输出的间隔则需要额外的寄存器
//3.对于inputflag的输出，不全的卷积窗口会被自动补全，但是不全的kernel不会，而是会提前输出 （但是由于加入池化的影响，因此可能最好将二者统一）
//4.建议根据所有的计算条件 来设置一个最大的阵列数和最小阵列 ，这样会简单一点
module top #(

	parameter DW=16,
	parameter ADDR_DW =5,
	parameter ADDR_DW_ROM = 8,
	parameter ABS_ADDR_DW =16,
	
	parameter CNT_W=9,// 计数器的位宽

	parameter ROWS = 4,//8; //SA阵列的行数
	parameter COLS = 4,//8;//SA阵列的列数
	// 32 32 -> 14 14 6->5 5 16-> 1 1 120->1 1 84 -> 1 1 10
	parameter ROM_CH = 1,
	parameter ROM_SIZE = ROM_CH*25*2,//50;
	parameter ROM_NUM = COLS,//9;
	parameter KERNEL_ELEMENT = 25,

	parameter ROM_CH2 = 6,
	parameter ROM_SIZE2 = ROM_CH2*25*4,//600;
	parameter ROM_NUM2 =COLS,//9;
	parameter KERNEL_ELEMENT2 = 150,

	
	parameter ROM_NUM3 =COLS ,//9;
	parameter ROM_SIZE3 = 40000,
	

	parameter ROM_NUM4 =COLS ,//9;
	parameter ROM_SIZE4 = 8400,
	

	parameter ROM_NUM5 =COLS ,//9;
	parameter ROM_SIZE5 = 252,
	

	parameter RAM_SIZE = 32,//7;
	parameter RAM_NUM = 32,//7;

	parameter ROM_SIZE_BIAS = 2,//7;
	parameter ROM_SIZE_BIAS2= 4,//7;
	parameter ROM_SIZE_BIAS3= 100,//7;
	parameter ROM_SIZE_BIAS4=21,
	parameter ROM_SIZE_BIAS5=3,
	parameter ROM_NUM_BIAS = COLS,//7;
	

	parameter RAM_CH_OUT1 =6,// 9 
	parameter RAM_NUM_OUT1= 14,
	parameter RAM_SIZE_OUT1 = 14,


	
	parameter RAM_CH_OUT2 =16,
	parameter RAM_NUM_OUT2= 5,
	parameter RAM_SIZE_OUT2= 5,
	
	parameter RAM_NUM_FC1 =COLS,
	parameter RAM_SIZE_FC1 = 100,

	parameter RAM_NUM_FC2 =COLS,
	parameter RAM_SIZE_FC2 = 21

	)
// 第三层卷积
	


	//对于fc的输出需要存储需要特殊处理
	

	(input clk,
	 input rst_n,
	 output reg [(DW)*COLS-1:0] output_data
	 );
	
	
	reg host2inMem_flag;

	
	


	reg [(DW)*ROWS-1:0] din_inf;
	wire [(DW)*ROWS-1:0] din_inf1,din_inf_out,din_inf_out2;
        wire [DW-1:0] out_data_fc1,out_data_fc2;
	reg [(DW)*COLS-1:0] din_weight;
	wire [(DW)*COLS-1:0] din_weight1,din_weight2,din_weight3,din_weight4,din_weight5;
	reg [(DW)*COLS-1:0] din_bias;
	wire [(DW)*COLS-1:0] din_bias1,din_bias2,din_bias3,din_bias4,din_bias5;
	wire [ABS_ADDR_DW-1:0] base_addr;
	
	
	 wire RA_enable;
	 wire RA_enable_bias;
	 wire mem_initial_sig_weight;
	 wire mem_initial_sig_inf;
	
	
	wire [3:0] KERNEL_DIM;
	wire [15:0] KERNEL_NUM;
	wire [1:0] STRIDE;

	wire [7:0] addr_inf_x;
	wire [3:0] addr_inf_y;
	wire [15:0] addr_weight;
	wire [7:0] addr_bias;
	wire [7:0] addr_w_fc;
	wire [15:0] rom_select;
	wire [3:0] ch_select;
	
	
	wire  [ADDR_DW-1:0] ram_select_x;
	wire [ADDR_DW-1:0] ram_select_y;
	wire WR_enable_out ;
	wire [ADDR_DW-1:0] addr_out_w;
	wire [ADDR_DW-1:0] ram_select_out_w;
	wire  [3:0] ch_out_w;

	wire [3:0] layer_index;
	wire [5:0] INFMAP_ROWS;
	
	
	
	
	reg clk_enable1,clk_enable2,clk_enable3,clk_enable4,clk_enable5;
	

	reg read_enable_1,read_enable_out1,write_enable_out1;
	reg read_enable_out2,write_enable_out2;
	//reg read_enable_out3, write_enable_out3;
	reg read_enable_fc1 , write_enable_fc1;
	reg read_enable_fc2, write_enable_fc2;
	
	
	always@(*) begin
		case (layer_index)
			4'b0001: begin clk_enable1 = 1'b1;
					clk_enable2 = 1'b0;
					clk_enable3 = 1'b0;
					clk_enable4=1'b0;
					clk_enable5 = 1'b0;

					read_enable_1 = 1'b1;
					read_enable_out1 = 1'b0;
					write_enable_out1 =1'b1;

					read_enable_out2 = 1'b0;
					write_enable_out2 =1'b0;

					read_enable_fc1 = 1'b0;
					write_enable_fc1 = 1'b0;

					read_enable_fc2 = 1'b0;
					write_enable_fc2 = 1'b0;

					din_inf = din_inf1;
					din_weight = din_weight1;
					din_bias = din_bias1;
				end



			4'b0010 : begin clk_enable1 = 1'b0;
					clk_enable2 = 1'b1;
					clk_enable3 = 1'b0;
					clk_enable4=1'b0;
					clk_enable5 = 1'b0;

					read_enable_1 = 1'b0;
					read_enable_out1 = 1'b1;
					write_enable_out1 =1'b0;

					read_enable_out2 = 1'b0;
					write_enable_out2 =1'b1;

					read_enable_fc1 = 1'b0;
					write_enable_fc1= 1'b0;

					read_enable_fc2 = 1'b0;
					write_enable_fc2 = 1'b0;

					din_inf = din_inf_out;
					din_weight = din_weight2;
					din_bias = din_bias2;
					
				 end
			4'b0011: begin

					clk_enable1 = 1'b0;
					clk_enable2 = 1'b0;
					clk_enable3 = 1'b1;
					clk_enable4=1'b0;
					clk_enable5 = 1'b0;

					read_enable_1 = 1'b0;
					read_enable_out1 = 1'b0;
					write_enable_out1 =1'b0;

					read_enable_out2 = 1'b1;
					write_enable_out2 =1'b0;

					read_enable_fc1= 1'b0;
					write_enable_fc1 = 1'b1;

					read_enable_fc2 = 1'b0;
					write_enable_fc2 = 1'b0;

					din_inf = din_inf_out2;
					din_weight = din_weight3;
					din_bias = din_bias3;
			
				end


			4'b0100: begin

					clk_enable1 = 1'b0;
					clk_enable2 = 1'b0;
					clk_enable3 = 1'b0;
					clk_enable4=1'b1;
					clk_enable5 = 1'b0;

					read_enable_1 = 1'b0;
					read_enable_out1 = 1'b0;
					write_enable_out1 =1'b0;

					read_enable_out2 = 1'b0;
					write_enable_out2 =1'b0;

					read_enable_fc1= 1'b1;
					write_enable_fc1 = 1'b0;

					read_enable_fc2 = 1'b0;
					write_enable_fc2 = 1'b1;

					din_inf = out_data_fc1;
					din_weight = din_weight4;
					din_bias = din_bias4;
			
				end

			4'b0101: begin

					clk_enable1 = 1'b0;
					clk_enable2 = 1'b0;
					clk_enable3 = 1'b0;
					clk_enable4=1'b0;
					clk_enable5 = 1'b1;

					read_enable_1 = 1'b0;
					read_enable_out1 = 1'b0;
					write_enable_out1 =1'b0;

					read_enable_out2 = 1'b0;
					write_enable_out2 =1'b0;

					read_enable_fc1= 1'b0;
					write_enable_fc1 = 1'b1;

					read_enable_fc2 = 1'b1;
					write_enable_fc2 = 1'b0;

					din_inf = out_data_fc2;
					din_weight = din_weight5;
					din_bias = din_bias5;
			
				end


			default : begin
					clk_enable1 = 1'b0;
					clk_enable2 = 1'b0;
					clk_enable3 = 1'b0;
					clk_enable4 = 1'b0;
					clk_enable5 = 1'b0;

					read_enable_1 = 1'b0;
					read_enable_out1 = 1'b0;
					write_enable_out1 =1'b0;

					read_enable_out2 = 1'b0;
					write_enable_out2 =1'b0;

					read_enable_fc1 = 1'b0;
					write_enable_fc1 = 1'b0;
			
					read_enable_fc2 = 1'b0;
					write_enable_fc2 = 1'b0;

					din_inf = 'd0;
					din_weight = 'd0;
					din_bias = 'd0;
				end
		endcase
	end
			
			
			
	


data_ram #( .DW (DW),  .RAM_NUM (RAM_NUM),  .RAM_SIZE (RAM_SIZE) ,
.ADDR_DW (ADDR_DW),.ROWS  (ROWS))
u_data_ram
( .clk (clk ),
  .rst_n (rst_n),
   .STRIDE (STRIDE),
  .initial_sig (host2inMem_flag),
  .addr_r_x (addr_inf_x),	      // 对有效信号进行移位起到了类似卷积窗口滑动的效果
  .addr_r_y (addr_inf_y),	      // 确定一个卷积块中的列数
  .ram_select_r_x (ram_select_x), //用来索引哪几个ram 块 有效
  .ram_select_r_y (ram_select_y), // 考虑到当前的行折叠
  .KERNEL_DIM      (KERNEL_DIM),
   .data_out_valid  (RA_enable && read_enable_1),
 
  .data_out         (din_inf1),
  .mem_sig  (mem_initial_sig_inf));


weight_rom #( .DW (DW),  .ROM_NUM (ROM_NUM),  .ROM_SIZE (ROM_SIZE) ,
.ADDR_DW (ADDR_DW),.COLS  (COLS), .ABS_ADDR_DW(ABS_ADDR_DW), .KERNEL_ELEMENT (KERNEL_ELEMENT))
u_weight_rom
(.clk	(clk),
 .rst_n (rst_n),
 .initial_sig (host2inMem_flag),
 .KERNEL_NUM (KERNEL_NUM),
 .addr_r (addr_weight),// 与cnt_kernel 相连	
 .base_addr (base_addr),        
 .rom_select  (rom_select), //与folding_cols_cur相连

 .data_out_valid (RA_enable  && clk_enable1) ,
 
 .data_out  (din_weight1),
 .mem_sig  (mem_initial_sig_weight));


weight_rom #(.DW (DW),  .ROM_NUM (ROM_NUM2),  .ROM_SIZE (ROM_SIZE2) ,
.ADDR_DW (ADDR_DW),.COLS  (COLS) , .ABS_ADDR_DW(ABS_ADDR_DW), .KERNEL_ELEMENT (KERNEL_ELEMENT2))
u_weight_rom_2
(.clk	(clk ),
 .rst_n (rst_n),
.initial_sig (host2inMem_flag),
   .KERNEL_NUM (KERNEL_NUM),
 .addr_r (addr_weight),// 与cnt_kernel 相连	
 .base_addr (base_addr),        
 .rom_select  (rom_select), //与folding_cols_cur相连initial_sig (host2inMem_flag),
 .data_out_valid (RA_enable && clk_enable2),
 
 .data_out  (din_weight2),
 .mem_sig  (mem_initial_sig_weight));


weight_rom_fc #(.DW (DW),  .ROM_NUM (ROM_NUM3),  .ROM_SIZE (ROM_SIZE3) ,
.ADDR_DW (ADDR_DW),.COLS  (COLS), .ABS_ADDR_DW  (ABS_ADDR_DW) )
u_weight_rom_3
(.clk	(clk ),
 .rst_n (rst_n),
.initial_sig (host2inMem_flag),
   .KERNEL_NUM (KERNEL_NUM),
 .addr_r (addr_weight),// 与cnt_kernel 相连	
 .base_addr (base_addr),      
 .rom_select  (rom_select), //与folding_cols_cur相连initial_sig (host2inMem_flag),
 .data_out_valid (RA_enable && clk_enable3),
 
 .data_out  (din_weight3),
 .mem_sig  (mem_initial_sig_weight));


weight_rom_fc #(.DW (DW),  .ROM_NUM (ROM_NUM4),  .ROM_SIZE (ROM_SIZE4) ,
.ADDR_DW (ADDR_DW),.COLS  (COLS), .ABS_ADDR_DW  (ABS_ADDR_DW))
u_weight_rom_4
(.clk	(clk ),
 .rst_n (rst_n),
.initial_sig (host2inMem_flag),
   .KERNEL_NUM (KERNEL_NUM),
 .addr_r (addr_weight),// 与cnt_kernel 相连	
 .base_addr (base_addr),      
 .rom_select  (rom_select), //与folding_cols_cur相连initial_sig (host2inMem_flag),
 .data_out_valid (RA_enable && clk_enable4),
 
 .data_out  (din_weight4),
 .mem_sig  (mem_initial_sig_weight));


weight_rom_fc #(.DW (DW),  .ROM_NUM (ROM_NUM5),  .ROM_SIZE (ROM_SIZE5) ,
.ADDR_DW (ADDR_DW),.COLS  (COLS), .ABS_ADDR_DW  (ABS_ADDR_DW))
u_weight_rom_5
(.clk	(clk ),
 .rst_n (rst_n),
.initial_sig (host2inMem_flag),
   .KERNEL_NUM (KERNEL_NUM),
 .addr_r (addr_weight),// 与cnt_kernel 相连	
 .base_addr (base_addr),      
 .rom_select  (rom_select), //与folding_cols_cur相连initial_sig (host2inMem_flag),
 .data_out_valid (RA_enable && clk_enable5),
 
 .data_out  (din_weight5),
 .mem_sig  (mem_initial_sig_weight));





bias_rom #( .DW (DW),  .ROM_NUM_BIAS (ROM_NUM_BIAS),  .ROM_SIZE_BIAS (ROM_SIZE_BIAS) ,
.ADDR_DW (ADDR_DW),.COLS  (COLS),.ADDR_DW_ROM (ADDR_DW_ROM))
u_bias_rom
(.clk	(clk  ),
 .rst_n  (rst_n),
 .initial_sig (host2inMem_flag),
 .KERNEL_NUM (KERNEL_NUM),
 .addr_r (addr_bias),// 与cnt_kernel 相连	      
 

 .data_out_valid (1'b0 && read_enable_1),
 
 .data_out  (din_bias1),
 .mem_sig  (mem_initial_sig_weight));


bias_rom #( .DW (DW),  .ROM_NUM_BIAS (ROM_NUM_BIAS),  .ROM_SIZE_BIAS (ROM_SIZE_BIAS2) ,
.ADDR_DW (ADDR_DW),.COLS  (COLS),.ADDR_DW_ROM (ADDR_DW_ROM))
u_bias_rom2
(.clk	(clk ),
 .rst_n  (rst_n),
 .initial_sig (host2inMem_flag),
 .KERNEL_NUM (KERNEL_NUM),
 .addr_r (addr_bias),// 与cnt_kernel 相连	      
 

 .data_out_valid (1'b0 && clk_enable2),
 
 .data_out  (din_bias2),
 .mem_sig  (mem_initial_sig_weight));


bias_rom #( .DW (DW),  .ROM_NUM_BIAS (ROM_NUM_BIAS),  .ROM_SIZE_BIAS (ROM_SIZE_BIAS3) ,
.ADDR_DW (ADDR_DW),.COLS  (COLS),.ADDR_DW_ROM (ADDR_DW_ROM))
u_bias_rom3
(.clk	(clk ),
 .rst_n  (rst_n),
 .initial_sig (host2inMem_flag),
 .KERNEL_NUM (KERNEL_NUM),
 .addr_r (addr_bias),// 与cnt_kernel 相连	      
 

 .data_out_valid (1'b0 && clk_enable3),
 
 .data_out  (din_bias3),
 .mem_sig  (mem_initial_sig_weight));

bias_rom #( .DW (DW),  .ROM_NUM_BIAS (ROM_NUM_BIAS),  .ROM_SIZE_BIAS (ROM_SIZE_BIAS4) ,
.ADDR_DW (ADDR_DW),.COLS  (COLS),.ADDR_DW_ROM (ADDR_DW_ROM))
u_bias_rom4
(.clk	(clk ),
 .rst_n  (rst_n),
 .initial_sig (host2inMem_flag),
 .KERNEL_NUM (KERNEL_NUM),
 .addr_r (addr_bias),// 与cnt_kernel 相连	      
 

 .data_out_valid (1'b0 && clk_enable4),
 
 .data_out  (din_bias4),
 .mem_sig  (mem_initial_sig_weight));


bias_rom #( .DW (DW),  .ROM_NUM_BIAS (ROM_NUM_BIAS),  .ROM_SIZE_BIAS (ROM_SIZE_BIAS5) ,
.ADDR_DW (ADDR_DW),.COLS  (COLS),.ADDR_DW_ROM (ADDR_DW_ROM))
u_bias_rom5
(.clk	(clk ),
 .rst_n  (rst_n),
 .initial_sig (host2inMem_flag),
 .KERNEL_NUM (KERNEL_NUM),
 .addr_r (addr_bias),// 与cnt_kernel 相连	      
 

 .data_out_valid (1'b0 && clk_enable5),
 
 .data_out  (din_bias5),
 .mem_sig  (mem_initial_sig_weight));






 CNN_MODULE //必须 满足SW_N > ROWS -1
	#( .DW (DW),
	 .ADDR_DW  (ADDR_DW),
	// kernel 84 10 

        .CNT_W  (CNT_W),// 计数器的位宽

	.ROWS  (ROWS), //SA阵列的行数
	.COLS   (COLS)//SA阵列的列数

	
	)
	u_cnn
	( .clk  (clk),
	  .rst_n (rst_n),
	  .mem_initial_sig (mem_initial_sig_inf),
	  .kernel_dim (KERNEL_DIM),
          .kernel_num  (KERNEL_NUM),
	  .stride      (STRIDE),
     	  .layer_index (layer_index),
          .infmap_rows  (INFMAP_ROWS),
	
	  .RA_enable     (RA_enable),
	  .din_inf (din_inf),
	  .fold_rows_cur_o_x (ram_select_x),
	  .fold_rows_cur_o_y (ram_select_y),
	  .addr_inf_x (addr_inf_x), // 0-25
	  .addr_inf_y (addr_inf_y  ),


	  .din_weight (din_weight),
	  .addr_weight (addr_weight), //用来选中rom中对应的一个数据 还需要两个额外的片选信号，分别是选中哪一个通道以及选中哪一个折叠；
	  .cols_num_cur_o (rom_select),//用来选中对应的折叠
	  .cols_num_cur_kernel_element_o (base_addr),
	 
	  .addr_bias (addr_bias),
	  .din_bias (din_bias),
	  .RA_enable_bias (RA_enable_bias),

	   .cnt_ch_o (ch_select), // 用来选中对应的通道；
	  .output_data (output_data),
	
	  .ch_out	(ch_out_w),
	 . ram_select_out	( ram_select_out_w),
	. addr_out (addr_out_w),
	 
	 .WR_enable_out (WR_enable_out),

	 .addr_out_fc (addr_w_fc)
	
	   );

	
	
ram_out #(.DW (DW),.RAM_CH_OUT(RAM_CH_OUT1), .RAM_NUM_OUT (RAM_NUM_OUT1),  .RAM_SIZE_OUT (RAM_SIZE_OUT1),.ADDR_DW (ADDR_DW), .ROWS (ROWS), .COLS(COLS))

u_ram1_out

(.clk	(clk),
 .rst_n (rst_n),
 .STRIDE (STRIDE),
 .KERNEL_DIM (KERNEL_DIM),
 .INFMAP_ROWS (INFMAP_ROWS),
 .ch_select_w	(ch_out_w), //输入的值为0 ，8 类似的 输入0 则选取0-7 个通道
 .ch_select_r	(ch_select),
 .addr_w	(addr_out_w),// 输入写地址，可认为是输出特征图的列索引
 .addr_r_x (addr_inf_x),	      // 对有效信号进行移位起到了类似卷积窗口滑动的效果
  .addr_r_y (addr_inf_y),	
 .data_in	(output_data),//每个人clk 选中多个通道 每个通道存入一个值
 .data_out	(din_inf_out),//每一个cycles 选中8个通道每个选取一个数存入
 .RAenable	(RA_enable && read_enable_out1),//读有效
 .WRenable	(WR_enable_out && write_enable_out1),//写有效
       // 确定一个卷积块中的列数
  .ram_select_r_x (ram_select_x), //用来索引哪几个ram 块 有效
  .ram_select_r_y (ram_select_y), 

 .ram_select_w	(ram_select_out_w)) ; 



ram_out #(.DW (DW),.RAM_CH_OUT(RAM_CH_OUT2), .RAM_NUM_OUT (RAM_NUM_OUT2),  .RAM_SIZE_OUT (RAM_SIZE_OUT2),.ADDR_DW (ADDR_DW), .ROWS (ROWS), .COLS(COLS))

u_ram2_out

(.clk	(clk),
 .rst_n (rst_n),
 .STRIDE (STRIDE),
 .KERNEL_DIM (KERNEL_DIM),
 .INFMAP_ROWS (INFMAP_ROWS),
 .ch_select_w	(ch_out_w), //输入的值为0 ，8 类似的 输入0 则选取0-7 个通道
 .ch_select_r	(ch_select),
 .addr_w	(addr_out_w),// 输入写地址，可认为是输出特征图的列索引
 .addr_r_x (addr_inf_x),	      // 对有效信号进行移位起到了类似卷积窗口滑动的效果
  .addr_r_y (addr_inf_y),	
 .data_in	(output_data),//每个人clk 选中多个通道 每个通道存入一个值
 .data_out	(din_inf_out2),//每一个cycles 选中8个通道每个选取一个数存入
 .RAenable	(RA_enable && read_enable_out2),//读有效
 .WRenable	(WR_enable_out && write_enable_out2),//写有效
       // 确定一个卷积块中的列数
  .ram_select_r_x (ram_select_x), //用来索引哪几个ram 块 有效
  .ram_select_r_y (ram_select_y), 

 .ram_select_w	(ram_select_out_w)) ; 


	 
fc_ram #( .DW(DW) , .RAM_NUM(RAM_NUM_FC1) , .RAM_SIZE (RAM_SIZE_FC1), .ADDR_DW(ADDR_DW),.COLS(COLS)) 
u_fc_ram1
	(
		.clk (clk),
		.rst_n (rst_n),
		.WR_enable (WR_enable_out && write_enable_fc1 ),
		.RA_enable (RA_enable && read_enable_fc1),
		.addr_w (addr_w_fc),
		.in_data (output_data),
		.ram_select (addr_inf_y),
		.addr_r (addr_inf_x),
		.out_data (out_data_fc1)
		

	);


fc_ram #( .DW(DW) , .RAM_NUM(RAM_NUM_FC2) , .RAM_SIZE (RAM_SIZE_FC2), .ADDR_DW(ADDR_DW), .COLS(COLS)) 
u_fc_ram2
	(
		.clk (clk),
		.rst_n (rst_n),
		.WR_enable (WR_enable_out && write_enable_fc2 ),
		.RA_enable (RA_enable && read_enable_fc2),
		.addr_w (addr_w_fc),
		.in_data (output_data),
		.ram_select (addr_inf_y),
		.addr_r (addr_inf_x),
		.out_data (out_data_fc2)
		

	);


	


	
endmodule
