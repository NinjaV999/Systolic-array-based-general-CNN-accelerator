
module bias_rom #(parameter DW=8, parameter ROM_NUM_BIAS=6, parameter ROM_SIZE_BIAS=25 ,
parameter ADDR_DW=5,parameter COLS = 8 , parameter ADDR_DW_ROM = 8 )

(input clk,
 input rst_n,
 input [7:0] addr_r,// 与cnt_kernel 相连	      
input [15:0] KERNEL_NUM,
 input initial_sig,
 input data_out_valid,
 
 output reg [(DW)*COLS-1:0] data_out,
 output  mem_sig );

 reg [ROM_NUM_BIAS-1:0] rd_en;

 reg [ROM_NUM_BIAS-1:0] rd_en_r;

 wire [DW-1:0] dout [ROM_NUM_BIAS-1:0];
 wire mem_initial_sig [ROM_NUM_BIAS-1:0];

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

assign mem_sig = mem_initial_sig [0];
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

genvar m;


generate

	for(m=0; m <=ROM_NUM_BIAS-1; m = m+1) begin : gen_rom
rom #(
     .DW (DW),          // 数据宽度
          // 行数
     .ADDR_DW  (ADDR_DW_ROM),     // 地址宽度
     .ROM_SIZE  (ROM_SIZE_BIAS)  // 内存行数
   
) 
	
u_rom(
   .clk	(clk),                 // 时钟信号
               // 写使能信号
    .RAenable  (rd_en[m]),            // 读使能信号
    .initial_sig (initial_sig),         // 初始化信号
     .para (m),
    .addr (addr_r),    // 地址总线
   
         // 数据输入总线
     // 写完成信号
     .dout (dout[m]), // 数据输出总线
     .mem_initial_signal (mem_initial_sig [m])
);

end
	

	
endgenerate
endmodule


	
		
