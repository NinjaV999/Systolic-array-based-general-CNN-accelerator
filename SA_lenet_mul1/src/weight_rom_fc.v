
/*
关于参数设置：
1.ROM_NUM 与 COLS保持一致，总是为4个，然后第一个rom 就存0 -4 -8这几个kernel
第二个ROM就存1-5-9依次类推
2.要额外增加一个计数装置，要设置一个便宜地址，根据rom_select的值进行偏移，当rom select 为0的时候偏移为0，
当为1的时候 偏移地址为rom_select * 一个kernel的元素数量

3. 在偏移地址的基础上再加上addr_r 即为下一个kernel的元素索引


*/
module weight_rom_fc #(parameter DW=8, parameter ROM_NUM=6, parameter ROM_SIZE=25 ,
parameter ADDR_DW=5,parameter COLS = 8,parameter ABS_ADDR_DW =16 )//表示一个kernel所包含的元素数

(input clk,
 input rst_n,
 input [15:0] KERNEL_NUM,
 input [15:0] addr_r,// 与cnt_kernel 相连	      
 input [ABS_ADDR_DW-1:0] base_addr, //与folding_cols_cur相连
 input [15:0] rom_select,
 input data_out_valid,
 
 output reg [(DW)*COLS-1:0] data_out );




 reg [ROM_NUM-1:0] rd_en,rd_en_r; //4个
 wire [ABS_ADDR_DW-1:0] abs_addr;
 wire [DW-1:0] dout [ROM_NUM-1:0];


always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		rd_en_r<='d0;
	end
	else begin
		rd_en_r<=rd_en;
	end
	
end


integer i;
 

   assign abs_addr = base_addr+addr_r;

    always@(*)begin
	for(i=0;i<=ROM_NUM-1;i=i+1) begin //第一次是0，0 1 2 3, rd全为1 第二次是4 ， 45 为 1，67 为0 
		if(i+rom_select <= KERNEL_NUM-1 ) begin
			rd_en[i] = data_out_valid;
		end
		else begin
			rd_en [i] = 1'b0;
            
       		 end
        end
	
   end


integer j;
//这里就不需要额外判断了，我在初始化mem的时候都分配相同的存储空间，不能整除的mem 补 0 存进去
	always@(*) begin
		
		for(j=COLS-1;j>=0; j=j-1) begin

			if(rd_en_r[j] == 1'b1) begin // 4+3 > 6 因此存0

				data_out  ={ data_out [(DW)*(COLS-1)-1: 0],dout [j]}; //最低为信号就会存储在data_out的低位 ，不够的信号回自动补0
			end
			else begin
				data_out   ={ data_out [(DW)*(COLS-1)-1: 0], {(DW){1'b0}}};
			end
		end
	end
	

  weight3_rom0 weight0 (
  .clka(clk),    // input wire clka
  .ena(rd_en[0]),      // input wire ena
  .addra(abs_addr),  // input wire [4 : 0] addra
  .douta(dout[0])  // output wire [15 : 0] douta

);

	  weight3_rom1 weight1 (
  .clka(clk),    // input wire clka
  .ena(rd_en[1]),      // input wire ena
  .addra(abs_addr),  // input wire [4 : 0] addra
  .douta(dout[1])  // output wire [15 : 0] douta

);
	
	
		  weight3_rom2 weight2 (
  .clka(clk),    // input wire clka
  .ena(rd_en[2]),      // input wire ena
  .addra(abs_addr),  // input wire [4 : 0] addra
  .douta(dout[2])  // output wire [15 : 0] douta

);

	
		  weight3_rom3 weight3 (
  .clka(clk),    // input wire clka
  .ena(rd_en[3]),      // input wire ena
  .addra(abs_addr),  // input wire [4 : 0] addra
  .douta(dout[3])  // output wire [15 : 0] douta

);
endmodule



module weight_rom_fc2 #(parameter DW=8, parameter ROM_NUM=6, parameter ROM_SIZE=25 ,
parameter ADDR_DW=5,parameter COLS = 8,parameter ABS_ADDR_DW =16 )//表示一个kernel所包含的元素数

(input clk,
 input rst_n,
 input [15:0] KERNEL_NUM,
 input [15:0] addr_r,// 与cnt_kernel 相连	      
 input [ABS_ADDR_DW-1:0] base_addr, //与folding_cols_cur相连
 input [15:0] rom_select,
 input data_out_valid,
 
 output reg [(DW)*COLS-1:0] data_out );




 reg [ROM_NUM-1:0] rd_en,rd_en_r; //4个
 wire [ABS_ADDR_DW-1:0] abs_addr;
 wire [DW-1:0] dout [ROM_NUM-1:0];


always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		rd_en_r<='d0;
	end
	else begin
		rd_en_r<=rd_en;
	end
	
end


integer i;
 

   assign abs_addr = base_addr+addr_r;

    always@(*)begin
	for(i=0;i<=ROM_NUM-1;i=i+1) begin //第一次是0，0 1 2 3, rd全为1 第二次是4 ， 45 为 1，67 为0 
		if(i+rom_select <= KERNEL_NUM-1 ) begin
			rd_en[i] = data_out_valid;
		end
		else begin
			rd_en [i] = 1'b0;
            
       		 end
        end
	
   end


integer j;
//这里就不需要额外判断了，我在初始化mem的时候都分配相同的存储空间，不能整除的mem 补 0 存进去
	always@(*) begin
		
		for(j=COLS-1;j>=0; j=j-1) begin

			if(rd_en_r[j] == 1'b1) begin // 4+3 > 6 因此存0

				data_out  ={ data_out [(DW)*(COLS-1)-1: 0],dout [j]}; //最低为信号就会存储在data_out的低位 ，不够的信号回自动补0
			end
			else begin
				data_out   ={ data_out [(DW)*(COLS-1)-1: 0], {(DW){1'b0}}};
			end
		end
	end
	

  weight4_rom0 weight0 (
  .clka(clk),    // input wire clka
  .ena(rd_en[0]),      // input wire ena
  .addra(abs_addr),  // input wire [4 : 0] addra
  .douta(dout[0])  // output wire [15 : 0] douta

);

	  weight4_rom1 weight1 (
  .clka(clk),    // input wire clka
  .ena(rd_en[1]),      // input wire ena
  .addra(abs_addr),  // input wire [4 : 0] addra
  .douta(dout[1])  // output wire [15 : 0] douta

);
	
	
		  weight4_rom2 weight2 (
  .clka(clk),    // input wire clka
  .ena(rd_en[2]),      // input wire ena
  .addra(abs_addr),  // input wire [4 : 0] addra
  .douta(dout[2])  // output wire [15 : 0] douta

);

	
		  weight4_rom3 weight3 (
  .clka(clk),    // input wire clka
  .ena(rd_en[3]),      // input wire ena
  .addra(abs_addr),  // input wire [4 : 0] addra
  .douta(dout[3])  // output wire [15 : 0] douta

);
endmodule


module weight_rom_fc3 #(parameter DW=8, parameter ROM_NUM=6, parameter ROM_SIZE=25 ,
parameter ADDR_DW=5,parameter COLS = 8,parameter ABS_ADDR_DW =16 )//表示一个kernel所包含的元素数

(input clk,
 input rst_n,
 input [15:0] KERNEL_NUM,
 input [15:0] addr_r,// 与cnt_kernel 相连	      
 input [ABS_ADDR_DW-1:0] base_addr, //与folding_cols_cur相连
 input [15:0] rom_select,
 input data_out_valid,
 
 output reg [(DW)*COLS-1:0] data_out );




 reg [ROM_NUM-1:0] rd_en,rd_en_r; //4个
 wire [ABS_ADDR_DW-1:0] abs_addr;
 wire [DW-1:0] dout [ROM_NUM-1:0];


always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		rd_en_r<='d0;
	end
	else begin
		rd_en_r<=rd_en;
	end
	
end


integer i;
 

   assign abs_addr = base_addr+addr_r;

    always@(*)begin
	for(i=0;i<=ROM_NUM-1;i=i+1) begin //第一次是0，0 1 2 3, rd全为1 第二次是4 ， 45 为 1，67 为0 
		if(i+rom_select <= KERNEL_NUM-1 ) begin
			rd_en[i] = data_out_valid;
		end
		else begin
			rd_en [i] = 1'b0;
            
       		 end
        end
	
   end


integer j;
//这里就不需要额外判断了，我在初始化mem的时候都分配相同的存储空间，不能整除的mem 补 0 存进去
	always@(*) begin
		
		for(j=COLS-1;j>=0; j=j-1) begin

			if(rd_en_r[j] == 1'b1) begin // 4+3 > 6 因此存0

				data_out  ={ data_out [(DW)*(COLS-1)-1: 0],dout [j]}; //最低为信号就会存储在data_out的低位 ，不够的信号回自动补0
			end
			else begin
				data_out   ={ data_out [(DW)*(COLS-1)-1: 0], {(DW){1'b0}}};
			end
		end
	end
	

  weight5_rom0 weight0 (
  .clka(clk),    // input wire clka
  .ena(rd_en[0]),      // input wire ena
  .addra(abs_addr),  // input wire [4 : 0] addra
  .douta(dout[0])  // output wire [15 : 0] douta

);

	  weight5_rom1 weight1 (
  .clka(clk),    // input wire clka
  .ena(rd_en[1]),      // input wire ena
  .addra(abs_addr),  // input wire [4 : 0] addra
  .douta(dout[1])  // output wire [15 : 0] douta

);
	
	
		  weight5_rom2 weight2 (
  .clka(clk),    // input wire clka
  .ena(rd_en[2]),      // input wire ena
  .addra(abs_addr),  // input wire [4 : 0] addra
  .douta(dout[2])  // output wire [15 : 0] douta

);

	
		  weight5_rom3 weight3 (
  .clka(clk),    // input wire clka
  .ena(rd_en[3]),      // input wire ena
  .addra(abs_addr),  // input wire [4 : 0] addra
  .douta(dout[3])  // output wire [15 : 0] douta

);
endmodule
