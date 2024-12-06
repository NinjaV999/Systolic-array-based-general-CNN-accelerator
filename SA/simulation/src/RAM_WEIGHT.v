
module rom #(
    parameter DW = 8,          // 数据宽度
          // 行数
    parameter COLS = 8,
    parameter ADDR_DW =5,     // 地址宽度
    parameter ROM_SIZE = 32,  // 内存行数
    parameter KERNEL_ELEMENT = 25
	
   
) (
    input clk,                 // 时钟信号
               // 写使能信号
    input RAenable,            // 读使能信号
    input initial_sig,         // 初始化信号
   
    input [ADDR_DW-1:0] addr,    // 地址总线
    input [31:0] para,
         // 数据输入总线
     // 写完成信号
    output reg [DW-1:0] dout, // 数据输出总线
    output reg mem_initial_signal
);

    // 定义存储器的数组
    reg signed [DW-1:0] mem [ROM_SIZE-1:0];

    integer i ;

    // 时钟上升沿时进行读写操作
    always @(posedge clk) begin
        if (initial_sig == 1'b1) begin
           	mem_initial_signal <=1'b1;
		for (i=0;i <=ROM_SIZE-1; i =i+1) begin
				
		
					if(((i%KERNEL_ELEMENT)%25)%2==0) begin	
						mem[i] <=  (((i%KERNEL_ELEMENT)%25 +para+ (i/KERNEL_ELEMENT)*COLS+ 1) % 3);
					end
					else begin
						mem[i] <=-((2*((i%KERNEL_ELEMENT)%25)+para+ (i/KERNEL_ELEMENT)*COLS+ 1) % 3);
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