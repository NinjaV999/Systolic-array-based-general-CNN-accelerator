
module bias_rom1 #(parameter DW=8, parameter ROM_NUM_BIAS=6, parameter ROM_SIZE_BIAS=25 ,
parameter ADDR_DW=5,parameter COLS = 8 , parameter ADDR_DW_ROM = 8 )

(input clk,
 input rst_n,
 input [7:0] addr_r,// 与cnt_kernel 相连	      
input [15:0] KERNEL_NUM,

 input data_out_valid,
 
 output reg [(DW)*COLS-1:0] data_out
  );

 reg [ROM_NUM_BIAS-1:0] rd_en;

 reg [ROM_NUM_BIAS-1:0] rd_en_r;

 wire [DW-1:0] dout [ROM_NUM_BIAS-1:0];
 

// bias rom的个数与cols 一致 则 第一个存 0 - 8 ， 第二个就存 1 和 9 

always@(posedge clk) begin
	if(!rst_n) begin
		rd_en_r<='d0;
	end
	else begin
		rd_en_r<=rd_en;
	end
end

integer i;
   always@(*) begin
        for(i=0;i<=ROM_NUM_BIAS-1;i=i+1) begin
		if(i+addr_r*ROM_NUM_BIAS <= KERNEL_NUM-1)begin
		
			rd_en[i] = data_out_valid; // 因为就只有八个 所以只要读 其就是有效的
		end
		else begin
			rd_en[i] = 'd0;
		end
		
		
        end
       
    end


integer j;
	
	
	always@(*)begin
		for(j=COLS-1; j >=0 ; j= j-1) begin
			if(rd_en_r[j] == 1'b1) begin
				data_out  ={ data_out [(DW)*(COLS-1)-1: 0],dout [j]}; //最低为信号就会存储在data_out的低位 ，不够的信号回自动补0
			end
			else begin
				data_out = { data_out [(DW)*(COLS-1)-1: 0],{(DW){1'b0}}};
			end
		end
	end


bias1_rom0 rom0 (
  .clka(clk),    // input wire clka
  .ena(rd_en[0]),      // input wire ena
  .addra(addr_r),  // input wire [0 : 0] addra
  .douta(dout[0])  // output wire [15 : 0] douta
);
bias1_rom1 rom1 (
  .clka(clk),    // input wire clka
  .ena(rd_en[1]),      // input wire ena
  .addra(addr_r),  // input wire [0 : 0] addra
  .douta(dout[1])  // output wire [15 : 0] douta
);

bias1_rom2 rom2 (
  .clka(clk),    // input wire clka
  .ena(rd_en[2]),      // input wire ena
  .addra(addr_r),  // input wire [0 : 0] addra
  .douta(dout[2])  // output wire [15 : 0] douta
);

bias1_rom3 rom3 (
  .clka(clk),    // input wire clka
  .ena(rd_en[3]),      // input wire ena
  .addra(addr_r),  // input wire [0 : 0] addra
  .douta(dout[3])  // output wire [15 : 0] douta
);

endmodule


module bias_rom2 #(parameter DW=8, parameter ROM_NUM_BIAS=6, parameter ROM_SIZE_BIAS=25 ,
parameter ADDR_DW=5,parameter COLS = 8 , parameter ADDR_DW_ROM = 8 )

(input clk,
 input rst_n,
 input [7:0] addr_r,// 与cnt_kernel 相连	      
input [15:0] KERNEL_NUM,

 input data_out_valid,
 
 output reg [(DW)*COLS-1:0] data_out
  );

 reg [ROM_NUM_BIAS-1:0] rd_en;

 reg [ROM_NUM_BIAS-1:0] rd_en_r;

 wire [DW-1:0] dout [ROM_NUM_BIAS-1:0];
 

// bias rom的个数与cols 一致 则 第一个存 0 - 8 ， 第二个就存 1 和 9 

always@(posedge clk) begin
	if(!rst_n) begin
		rd_en_r<='d0;
	end
	else begin
		rd_en_r<=rd_en;
	end
end

integer i;
   always@(*) begin
        for(i=0;i<=ROM_NUM_BIAS-1;i=i+1) begin
		if(i+addr_r*ROM_NUM_BIAS <= KERNEL_NUM-1)begin
		
			rd_en[i] = data_out_valid; // 因为就只有八个 所以只要读 其就是有效的
		end
		else begin
			rd_en[i] = 'd0;
		end
		
		
        end
       
    end


integer j;
	
	
	always@(*)begin
		for(j=COLS-1; j >=0 ; j= j-1) begin
			if(rd_en_r[j] == 1'b1) begin
				data_out  ={ data_out [(DW)*(COLS-1)-1: 0],dout [j]}; //最低为信号就会存储在data_out的低位 ，不够的信号回自动补0
			end
			else begin
				data_out = { data_out [(DW)*(COLS-1)-1: 0],{(DW){1'b0}}};
			end
		end
	end


bias2_rom0 rom0 (
  .clka(clk),    // input wire clka
  .ena(rd_en[0]),      // input wire ena
  .addra(addr_r),  // input wire [0 : 0] addra
  .douta(dout[0])  // output wire [15 : 0] douta
);
bias2_rom1 rom1 (
  .clka(clk),    // input wire clka
  .ena(rd_en[1]),      // input wire ena
  .addra(addr_r),  // input wire [0 : 0] addra
  .douta(dout[1])  // output wire [15 : 0] douta
);

bias2_rom2 rom2 (
  .clka(clk),    // input wire clka
  .ena(rd_en[2]),      // input wire ena
  .addra(addr_r),  // input wire [0 : 0] addra
  .douta(dout[2])  // output wire [15 : 0] douta
);

bias2_rom3 rom3 (
  .clka(clk),    // input wire clka
  .ena(rd_en[3]),      // input wire ena
  .addra(addr_r),  // input wire [0 : 0] addra
  .douta(dout[3])  // output wire [15 : 0] douta
);

endmodule



module bias_rom3 #(parameter DW=8, parameter ROM_NUM_BIAS=6, parameter ROM_SIZE_BIAS=25 ,
parameter ADDR_DW=5,parameter COLS = 8 , parameter ADDR_DW_ROM = 8 )

(input clk,
 input rst_n,
 input [7:0] addr_r,// 与cnt_kernel 相连	      
input [15:0] KERNEL_NUM,

 input data_out_valid,
 
 output reg [(DW)*COLS-1:0] data_out
  );

 reg [ROM_NUM_BIAS-1:0] rd_en;

 reg [ROM_NUM_BIAS-1:0] rd_en_r;

 wire [DW-1:0] dout [ROM_NUM_BIAS-1:0];
 

// bias rom的个数与cols 一致 则 第一个存 0 - 8 ， 第二个就存 1 和 9 

always@(posedge clk) begin
	if(!rst_n) begin
		rd_en_r<='d0;
	end
	else begin
		rd_en_r<=rd_en;
	end
end

integer i;
   always@(*) begin
        for(i=0;i<=ROM_NUM_BIAS-1;i=i+1) begin
		if(i+addr_r*ROM_NUM_BIAS <= KERNEL_NUM-1)begin
		
			rd_en[i] = data_out_valid; // 因为就只有八个 所以只要读 其就是有效的
		end
		else begin
			rd_en[i] = 'd0;
		end
		
		
        end
       
    end


integer j;
	
	
	always@(*)begin
		for(j=COLS-1; j >=0 ; j= j-1) begin
			if(rd_en_r[j] == 1'b1) begin
				data_out  ={ data_out [(DW)*(COLS-1)-1: 0],dout [j]}; //最低为信号就会存储在data_out的低位 ，不够的信号回自动补0
			end
			else begin
				data_out = { data_out [(DW)*(COLS-1)-1: 0],{(DW){1'b0}}};
			end
		end
	end


bias3_rom0 rom0 (
  .clka(clk),    // input wire clka
  .ena(rd_en[0]),      // input wire ena
  .addra(addr_r),  // input wire [0 : 0] addra
  .douta(dout[0])  // output wire [15 : 0] douta
);
bias3_rom1 rom1 (
  .clka(clk),    // input wire clka
  .ena(rd_en[1]),      // input wire ena
  .addra(addr_r),  // input wire [0 : 0] addra
  .douta(dout[1])  // output wire [15 : 0] douta
);

bias3_rom2 rom2 (
  .clka(clk),    // input wire clka
  .ena(rd_en[2]),      // input wire ena
  .addra(addr_r),  // input wire [0 : 0] addra
  .douta(dout[2])  // output wire [15 : 0] douta
);

bias3_rom3 rom3 (
  .clka(clk),    // input wire clka
  .ena(rd_en[3]),      // input wire ena
  .addra(addr_r),  // input wire [0 : 0] addra
  .douta(dout[3])  // output wire [15 : 0] douta
);

endmodule


module bias_rom4 #(parameter DW=8, parameter ROM_NUM_BIAS=6, parameter ROM_SIZE_BIAS=25 ,
parameter ADDR_DW=5,parameter COLS = 8 , parameter ADDR_DW_ROM = 8 )

(input clk,
 input rst_n,
 input [7:0] addr_r,// 与cnt_kernel 相连	      
input [15:0] KERNEL_NUM,

 input data_out_valid,
 
 output reg [(DW)*COLS-1:0] data_out
  );

 reg [ROM_NUM_BIAS-1:0] rd_en;

 reg [ROM_NUM_BIAS-1:0] rd_en_r;

 wire [DW-1:0] dout [ROM_NUM_BIAS-1:0];
 

// bias rom的个数与cols 一致 则 第一个存 0 - 8 ， 第二个就存 1 和 9 

always@(posedge clk) begin
	if(!rst_n) begin
		rd_en_r<='d0;
	end
	else begin
		rd_en_r<=rd_en;
	end
end

integer i;
   always@(*) begin
        for(i=0;i<=ROM_NUM_BIAS-1;i=i+1) begin
		if(i+addr_r*ROM_NUM_BIAS <= KERNEL_NUM-1)begin
		
			rd_en[i] = data_out_valid; // 因为就只有八个 所以只要读 其就是有效的
		end
		else begin
			rd_en[i] = 'd0;
		end
		
		
        end
       
    end


integer j;
	
	
	always@(*)begin
		for(j=COLS-1; j >=0 ; j= j-1) begin
			if(rd_en_r[j] == 1'b1) begin
				data_out  ={ data_out [(DW)*(COLS-1)-1: 0],dout [j]}; //最低为信号就会存储在data_out的低位 ，不够的信号回自动补0
			end
			else begin
				data_out = { data_out [(DW)*(COLS-1)-1: 0],{(DW){1'b0}}};
			end
		end
	end


bias4_rom0 rom0 (
  .clka(clk),    // input wire clka
  .ena(rd_en[0]),      // input wire ena
  .addra(addr_r),  // input wire [0 : 0] addra
  .douta(dout[0])  // output wire [15 : 0] douta
);
bias4_rom1 rom1 (
  .clka(clk),    // input wire clka
  .ena(rd_en[1]),      // input wire ena
  .addra(addr_r),  // input wire [0 : 0] addra
  .douta(dout[1])  // output wire [15 : 0] douta
);

bias4_rom2 rom2 (
  .clka(clk),    // input wire clka
  .ena(rd_en[2]),      // input wire ena
  .addra(addr_r),  // input wire [0 : 0] addra
  .douta(dout[2])  // output wire [15 : 0] douta
);

bias4_rom3 rom3 (
  .clka(clk),    // input wire clka
  .ena(rd_en[3]),      // input wire ena
  .addra(addr_r),  // input wire [0 : 0] addra
  .douta(dout[3])  // output wire [15 : 0] douta
);

endmodule



module bias_rom5 #(parameter DW=8, parameter ROM_NUM_BIAS=6, parameter ROM_SIZE_BIAS=25 ,
parameter ADDR_DW=5,parameter COLS = 8 , parameter ADDR_DW_ROM = 8 )

(input clk,
 input rst_n,
 input [7:0] addr_r,// 与cnt_kernel 相连	      
input [15:0] KERNEL_NUM,

 input data_out_valid,
 
 output reg [(DW)*COLS-1:0] data_out
  );

 reg [ROM_NUM_BIAS-1:0] rd_en;

 reg [ROM_NUM_BIAS-1:0] rd_en_r;

 wire [DW-1:0] dout [ROM_NUM_BIAS-1:0];
 

// bias rom的个数与cols 一致 则 第一个存 0 - 8 ， 第二个就存 1 和 9 

always@(posedge clk) begin
	if(!rst_n) begin
		rd_en_r<='d0;
	end
	else begin
		rd_en_r<=rd_en;
	end
end

integer i;
   always@(*) begin
        for(i=0;i<=ROM_NUM_BIAS-1;i=i+1) begin
		if(i+addr_r*ROM_NUM_BIAS <= KERNEL_NUM-1)begin
		
			rd_en[i] = data_out_valid; // 因为就只有八个 所以只要读 其就是有效的
		end
		else begin
			rd_en[i] = 'd0;
		end
		
		
        end
       
    end


integer j;
	
	
	always@(*)begin
		for(j=COLS-1; j >=0 ; j= j-1) begin
			if(rd_en_r[j] == 1'b1) begin
				data_out  ={ data_out [(DW)*(COLS-1)-1: 0],dout [j]}; //最低为信号就会存储在data_out的低位 ，不够的信号回自动补0
			end
			else begin
				data_out = { data_out [(DW)*(COLS-1)-1: 0],{(DW){1'b0}}};
			end
		end
	end


bias5_rom0 rom0 (
  .clka(clk),    // input wire clka
  .ena(rd_en[0]),      // input wire ena
  .addra(addr_r),  // input wire [0 : 0] addra
  .douta(dout[0])  // output wire [15 : 0] douta
);
bias5_rom1 rom1 (
  .clka(clk),    // input wire clka
  .ena(rd_en[1]),      // input wire ena
  .addra(addr_r),  // input wire [0 : 0] addra
  .douta(dout[1])  // output wire [15 : 0] douta
);

bias5_rom2 rom2 (
  .clka(clk),    // input wire clka
  .ena(rd_en[2]),      // input wire ena
  .addra(addr_r),  // input wire [0 : 0] addra
  .douta(dout[2])  // output wire [15 : 0] douta
);

bias5_rom3 rom3 (
  .clka(clk),    // input wire clka
  .ena(rd_en[3]),      // input wire ena
  .addra(addr_r),  // input wire [0 : 0] addra
  .douta(dout[3])  // output wire [15 : 0] douta
);

endmodule

	
	
		
