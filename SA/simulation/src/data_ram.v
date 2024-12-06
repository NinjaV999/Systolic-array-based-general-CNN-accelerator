
module data_ram #(parameter DW=8, parameter RAM_NUM=32, parameter RAM_SIZE=32 ,
parameter ADDR_DW=5,parameter ROWS = 8)

(input clk,
 input rst_n,
 input initial_sig,
 input [1:0]  STRIDE,
 input [7:0] addr_r_x,	      // 对有效信号进行移位起到了类似卷积窗口滑动的效果
 input [3:0] addr_r_y,	      // 确定一个卷积块中的列数
 input [ADDR_DW-1:0] ram_select_r_x, //用来索引哪几个ram 块 有效
 input [ADDR_DW-1:0] ram_select_r_y, // 考虑到当前的行折叠
 input [3:0] KERNEL_DIM,
 input data_out_valid,
 
 output reg [(DW)*ROWS-1:0] data_out,
 output  mem_sig );
 reg [ADDR_DW-1:0] addr_r;

 reg [RAM_NUM-1:0] rd_en;
 reg [RAM_NUM-1:0] rd_en_r;

 reg [ADDR_DW-1:0] ram_select_r_x_r;
 reg [7:0] addr_r_x_r;
 
 wire [DW-1:0] dout [RAM_NUM-1:0];
 wire mem_initial_sig [RAM_NUM-1:0];
 assign mem_sig = mem_initial_sig [0];

always@(posedge clk or negedge rst_n) begin
	if(!rst_n)begin
		rd_en_r<='d0;
		addr_r_x_r <='d0;
		ram_select_r_x_r <='d0;
	end
	else begin
		rd_en_r<=rd_en;
		addr_r_x_r <= addr_r_x;
		ram_select_r_x_r <= ram_select_r_x;
	end
end

integer i;
// if stride =2
// 0 2 4 6 8 10 12 14
//1 3 5 7 9 11 13 15
//2 4 6 8 10
//16 18 20 22 24 26 28 30
//31
//32
//33
//34
     always@(*) begin
         for(i=0;i<=RAM_NUM-1;i=i+1) begin
                rd_en[i] =1'b0;
	end
        
        for(i=0;i<=RAM_NUM-1;i=i+1) begin
               
           	 	if(i*STRIDE>=ram_select_r_x && i*STRIDE<STRIDE*ROWS+ram_select_r_x && i*STRIDE<=RAM_NUM-KERNEL_DIM) begin //32-5 =27
                		rd_en[i*STRIDE+addr_r_x] = data_out_valid;
         	  	 end
            
           	 	else begin
               		 	rd_en[i*STRIDE+addr_r_x] =1'b0;
            	end
	   	
	   end
        
       
        
        addr_r = addr_r_y+ram_select_r_y;
    end

//24 25 26 27
//25 26 27 28
//26 27 28 29
//27 28 29 30
// 28 29 30 31

//如果stride 不为1则其可能存在使能信号位不连续有效的情况，由于存在重叠这与rom的读和ram的写并不相同，这二者不会对同一个地址重复的读
//0，2，4，6，8
	
	integer j; 
	always@(*)begin // 基准 + 不同行索引+偏移
		for(j=ROWS-1; j>=0; j = j-1) begin
			//确保索引不出界
			if(ram_select_r_x_r+j*STRIDE+addr_r_x_r <=RAM_NUM-1 &&	rd_en_r[ram_select_r_x_r+j*STRIDE+addr_r_x_r]== 1'b1)begin
				
				data_out = { data_out [(DW)*(ROWS-1)-1: 0], dout [ram_select_r_x_r+j*STRIDE+addr_r_x_r]};

			end
 			else begin
				data_out   ={ data_out [(DW)*(ROWS-1)-1: 0], {(DW){1'b0}}};
			end
		end
	end


genvar m;


generate

	for(m=0; m <=RAM_NUM-1; m = m+1) begin : gen_ram
		ram #(
     .DW (DW),          // 数据宽度
          // 行数
     .ADDR_DW  (ADDR_DW),     // 地址宽度
     .RAM_SIZE  (RAM_SIZE)  // 内存行数
   
) 

u_ram(
   .clk	(clk),                 // 时钟信号
               // 写使能信号
    .RAenable  (rd_en[m]),            // 读使能信号
    .initial_sig (initial_sig),         // 初始化信号
  
    .addr (addr_r),    // 地址总线
    .para (m),
         // 数据输入总线
     // 写完成信号
     .dout (dout[m]), // 数据输出总线
     .mem_initial_signal (mem_initial_sig [m])
);

end
	

	
endgenerate
endmodule


	
		