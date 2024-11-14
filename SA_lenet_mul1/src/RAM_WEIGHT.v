
module rom #(
    parameter DW = 8,          // 数据宽度
          // 行数
    parameter ADDR_DW =5,     // 地址宽度
    parameter ROM_SIZE = 32  // 内存行数
   
) (
    input clk,                 // 时钟信号
               // 写使能信号
    input rst_n,            // 读使能信号
    input RAenable,       // 初始化信号
   
    input [ADDR_DW-1:0] addr,    // 地址总线

         // 数据输入总线
     // 写完成信号
    output reg [DW:0] dout // 数据输出总线

);

    // 定义存储器的数组
    reg signed [DW:0] mem [ROM_SIZE-1:0];

    integer i, j;

    // 时钟上升沿时进行读写操作
    always @(posedge clk  or  negedge rst_n) begin
        if (! rst_n) begin
            for (i=0;i <=ROM_SIZE-1; i= i+1) begin
                mem[i] = i ;
               
              end

        end 
	
	else begin
	  
		// 没有一个写通道工作
		if(RAenable == 1'b1) begin
                    	dout<=   mem[addr];
		end
		else begin
			             dout <= 'd0;
		end
			
       		 
   	end
   end

	
endmodule