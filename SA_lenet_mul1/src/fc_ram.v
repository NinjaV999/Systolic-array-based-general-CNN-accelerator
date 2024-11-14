
module fc_ram #(parameter DW =16, parameter RAM_NUM = 4 , parameter RAM_SIZE = 100,parameter ADDR_DW =5, parameter COLS = 4 )

	(
		input clk,
		input rst_n,
		input WR_enable,
		input RA_enable,
		input [7:0] addr_w,
		input [(DW)*COLS-1:0] in_data,
		input [3:0] ram_select,
		input [7:0] addr_r,
		output  [DW-1:0] out_data
		

	);

	wire [7:0] addr_w_rom = (addr_w>=1'b1) ? addr_w-1: 'd0;
	reg [RAM_NUM-1:0] rd_en ;
	reg [RAM_NUM-1:0] rd_en_r ;
	reg [RAM_NUM-1:0] wr_en ;
	reg [DW-1:0] din [RAM_NUM-1:0];
	wire [DW-1:0] dout [RAM_NUM-1:0];
	reg [ADDR_DW-1:0] valid_out;
	assign out_data = (rd_en_r[valid_out] == 1'b1)? dout[valid_out] :'d0;

	integer i;
	always@(*) begin
		for (i = 0 ; i <=RAM_NUM-1; i = i+1) begin
			wr_en[i] = WR_enable;
			din[i] = in_data [i*(DW)+: DW] ;
			if(i==ram_select) begin
				rd_en[i] = RA_enable;
			end
			else begin
				rd_en[i] = 0;
			end
		end
	end
	
	always@(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			
				rd_en_r <='d0;
				valid_out <='d0;
			
		end
		else begin
				rd_en_r <=rd_en;
				valid_out <= ram_select;
			

		end
	end

	

	genvar m;


generate

	for(m=0; m <=RAM_NUM-1; m = m+1) begin : gen_ram_fc
		ram_new #(
     .DW (DW),          // 数据宽度
          // 行数
     .ADDR_DW  (8),     // 地址宽度
     .RAM_SIZE  (RAM_SIZE)  // 内存行数
   
) 

u_ram_new(
     .clk	 (clk),                 // 时钟信号
               // 写使能信号
    .WRenable	(wr_en[m]),            // 读使能信号
    .RAenable	(rd_en[m]),
             // 初始化信号
    .din        (din[m]),
    .addr_w     (addr_w_rom),    // 地址总线
    .addr_r	(addr_r),
   
         // 数据输入总线
     // 写完成信号
     .dout        (dout[m]) // 数据输出总线
  
);
end
endgenerate 

endmodule
	 
		