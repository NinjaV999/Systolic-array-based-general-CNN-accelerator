module ram #(
    parameter DW = 8,          // 数据宽度
          // 行数
    parameter ADDR_DW =4,     // 地址宽度
    parameter RAM_SIZE = 32  // 内存行数
   
) (
    input clk,                 // 时钟信号
               // 写使能信号
    input RAenable,            // 读使能信号
    input initial_sig,         // 初始化信号
    input [31:0] para,
    input [ADDR_DW-1:0] addr,    // 地址总线
   
         // 数据输入总线
     // 写完成信号
    output reg [DW-1:0] dout, // 数据输出总线
    output reg mem_initial_signal
);

    // 定义存储器的数组
    reg signed [DW-1:0] mem [RAM_SIZE-1:0];

    integer i, j;

    // 时钟上升沿时进行读写操作
    always @(posedge clk) begin
        if (initial_sig == 1'b1) begin
           	mem_initial_signal <=1'b1;
                for (i = 0; i < RAM_SIZE; i = i + 1) begin
                     		
                           		 if (i% 3 == 0) begin
                              			  mem[i] <= (i*5 +para+ 1) % 5;
                           		 end 
					else begin
                               			 mem[i]<= -((i*3  +para+ 1)% 5);
                            		end
                        	
                    	
                
           
            	end
        end 
	
	else begin
	   	  mem_initial_signal <=1'b0;
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