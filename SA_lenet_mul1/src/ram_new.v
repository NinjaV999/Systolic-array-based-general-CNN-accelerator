module ram_new #(
    parameter DW = 8,          // 数据宽度
          // 行数
    parameter ADDR_DW =4,     // 地址宽度
    parameter RAM_SIZE = 32  // 内存行数
   
) (
    input clk,                 // 时钟信号
               // 写使能信号
    input WRenable,            // 读使能信号
    input RAenable,
             // 初始化信号
    input [DW-1:0] din,
    input [ADDR_DW-1:0] addr_w,    // 地址总线
    input [ADDR_DW-1:0] addr_r,
   
         // 数据输入总线
     // 写完成信号
    output reg [DW-1:0] dout // 数据输出总线
  
);

    // 定义存储器的数组
    reg signed [DW-1:0] mem [RAM_SIZE-1:0];

    // 时钟上升沿时进行读写操作
    always @(posedge clk) begin
       		if(WRenable == 1'b1) begin
			mem[addr_w]<=din;

		end

		else if(RAenable == 1'b1) begin
                    	dout<=   mem[addr_r];
		end	 
   	
   end

	
endmodule
