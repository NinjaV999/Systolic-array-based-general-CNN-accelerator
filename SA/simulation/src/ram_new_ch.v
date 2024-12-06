module out_ram_ch #(parameter DW=8, parameter RAM_NUM_OUT=32, parameter RAM_SIZE_OUT=32 ,
parameter ADDR_DW=5,parameter ROWS = 8)

(input clk,
 
 input rst_n,
 input [1:0]  STRIDE,
 input [3:0] KERNEL_DIM,
 input [5:0] INFMAP_ROWS,
 input ch_enable_w,
 input ch_enable_r,
 input [ADDR_DW-1:0] ram_select_w,
 input [ADDR_DW-1:0] ram_select_r_x, //用来索引哪几个ram 块 有效
 input [ADDR_DW-1:0] ram_select_r_y,

 input [7:0] addr_r_x,	      // 对有效信号进行移位起到了类似卷积窗口滑动的效果
 input [3:0] addr_r_y,	
 input [ADDR_DW-1:0] addr_w,

 input [DW-1:0] data_in,  //这样的话就是每个通道每次只存入一个数据了
 output reg [(DW)*ROWS-1:0] data_out
 );

 reg [RAM_NUM_OUT-1:0] wr_en;
 reg [RAM_NUM_OUT-1:0] rd_en_r;
 reg [RAM_NUM_OUT-1:0] rd_en;
 reg [ADDR_DW-1:0] addr_r;
 
 reg[DW-1:0] din [RAM_NUM_OUT-1:0] ;
 reg [ADDR_DW-1:0] ram_select_r_x_r;
 reg [7:0] addr_r_x_r;
 integer i,j;
 wire [DW-1:0] dout [RAM_NUM_OUT-1:0];


//读
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)begin
		rd_en_r<='d0;
		addr_r_x_r <='d0;
		ram_select_r_x_r <='d0;
	end
	else begin
		rd_en_r<=rd_en;
		addr_r_x_r <= addr_r_x; //卷积窗口向行方向的偏移地址
		ram_select_r_x_r <= ram_select_r_x; //卷积窗口的基地址
	end
end

 
  always@(*) begin
          for(i=0;i<=RAM_NUM_OUT-1;i=i+1) begin
                	rd_en[i] =1'b0;
		end
        for(i=0;i<=RAM_NUM_OUT-1;i=i+1) begin
                	
           	 	if(i*STRIDE>=ram_select_r_x && i*STRIDE<STRIDE*ROWS+ram_select_r_x && i*STRIDE <INFMAP_ROWS-KERNEL_DIM) begin //32-5 =27，
//在读fc的时候我始终保证INFMAP-kernel dim =0，这样i就只能取0，读数依靠的是，addr_r_x
                		rd_en[i*STRIDE+addr_r_x] = ch_enable_r;
         	  	 end
            
           	 	else begin
               		 	rd_en[i*STRIDE+addr_r_x] =1'b0;
            	 	end
	   	
	end
  
        addr_r = addr_r_y+ram_select_r_y; //在fc的时候因为在rows上不折叠ram_select_r_y也为0
    end
		
		
    

	always@(*)begin // 基准 + 不同行索引+偏移
		for(j=ROWS-1; j>=0; j = j-1) begin
			//确保索引不出界，对于fc 这个是不用管的，就是根据re_en 是否为1进行数据拼接
			if(ram_select_r_x_r+j*STRIDE+addr_r_x_r <=RAM_NUM_OUT-1 && rd_en_r[ram_select_r_x_r+j*STRIDE+addr_r_x_r]== 1'b1)begin
				
				data_out = { data_out [(DW)*(ROWS-1)-1: 0], dout [ram_select_r_x_r+j*STRIDE+addr_r_x_r]};

			end
 			else begin
				data_out   ={ data_out [(DW)*(ROWS-1)-1: 0], {(DW){1'b0}}};
			end
		end
	end
	



   always@(*) begin
        for(i=0;i<=RAM_NUM_OUT-1;i=i+1) begin
           	 if(i == ram_select_w   ) begin //32-5 =27
                	wr_en[i] = ch_enable_w ;
			din[i]= data_in;		
				
         	 end		            
           	 else begin
			din[i] = 'd0;
               		wr_en[i] =1'b0;
				
            	 end
	   	
	end
        
    end	


genvar m;


generate

	for(m=0; m <=RAM_NUM_OUT-1; m = m+1) begin : gen_ram
		ram_new #(
     .DW (DW),          // 数据宽度
          // 行数
     .ADDR_DW  (ADDR_DW),     // 地址宽度
     .RAM_SIZE  (RAM_SIZE_OUT)  // 内存行数
   
) 

u_ram_new(
     .clk	 (clk),                 // 时钟信号
               // 写使能信号
    .WRenable	(wr_en[m]),            // 读使能信号
    .RAenable	(rd_en[m]),
             // 初始化信号
    .din        (din[m]),
    .addr_w     (addr_w),    // 地址总线
    .addr_r	(addr_r),
   
         // 数据输入总线
     // 写完成信号
     .dout        (dout[m]) // 数据输出总线
  
);

end
	

	
endgenerate
endmodule
/*

对于ram_out 模块
1.读过程 每次是读取rows个元素， 即每次读取rows个卷积窗口的1个元素
2.对于写过程一次写cols个元素，即每次写cols个输出通道的一个元素
3.要将其用读写fc layer的输入和输出时候，应该是每次读取1个元素，其余元素可以为0，此写入cols个元素，但是不是将这些元素写入四个通道而是连续写入一个通道的4个地址

*/
module ram_out #(parameter DW=8,parameter RAM_CH_OUT=6, parameter RAM_NUM_OUT=32, parameter RAM_SIZE_OUT=32 ,parameter ADDR_DW=5,parameter ROWS = 8,parameter COLS =8)



(input clk,
 input rst_n,
 input [1:0]  STRIDE,
 input [3:0] KERNEL_DIM,
 input [15:0] KERNEL_NUM,
 input  [5:0] INFMAP_ROWS,
 input [3:0] ch_select_w, //输入的值为0 ，8 类似的 输入0 则选取0-7 个通道
 input [3:0] ch_select_r, //输入为什么则对应的通道就有效
 input [ADDR_DW-1:0] addr_w,// 输入写地址，可认为是输出特征图的列索引
 input [7:0] addr_r_x,	      // 对有效信号进行移位起到了类似卷积窗口滑动的效果
 input [3:0] addr_r_y,
 input [(DW)*COLS-1:0] data_in,//每个人clk 选中多个通道 每个通道存入一个值
 output[(DW)*ROWS-1:0]data_out,//每一个cycles 选中8个通道每个选取一个数存入
 input RAenable,//读有效
 input WRenable,//写有效
 input [ADDR_DW-1:0] ram_select_r_x, //用来索引哪几个ram 块 有效
 input [ADDR_DW-1:0] ram_select_r_y,	
 input [ADDR_DW-1:0] ram_select_w) ; //读写一致都是选取一行



reg [RAM_CH_OUT-1:0] ch_en_r;
reg [RAM_CH_OUT-1:0] ch_en_w;
reg [DW-1:0] din [RAM_CH_OUT-1:0];
reg [3:0] ch_select_r_r;

wire [(DW)*ROWS-1:0] dout[RAM_CH_OUT-1:0];

assign data_out = dout[ch_select_r_r];


always@(posedge clk or negedge rst_n)begin

	if(!rst_n) begin
		ch_select_r_r <='d0;
	end
	else begin
		ch_select_r_r<=ch_select_r;
	end
end
		

	
integer i;

 	always@(*) begin

		for(i=0;i<=RAM_CH_OUT-1; i= i+1) begin
			if(i==ch_select_r)begin  //选中一个读通道

					ch_en_r[i] = RAenable;
					
			end
			else begin
					ch_en_r[i] = 'd0;
			end
		end


		
		for(i=0;i<=RAM_CH_OUT-1; i= i+1) begin
			if(i>=ch_select_w && i<ch_select_w+COLS && i<=KERNEL_NUM-1)begin //加一个判断调节表示i小于当前的输出通道数
//这是为了防止在这里可能为组合上维度不同的其他通道，之前mem的通道数就是输出通道数，因此mem的通道永远不可能超过
//输出通道，但现在拼接之后可能会出现，mem的通道索引，超过当前所需存储的输出通道，这就会导致错位的写，因此我们要
//写一个判断mem通道的索引小于输出通道
					ch_en_w[i] = WRenable;
					din[i] = data_in[(i-ch_select_w)*(DW)+:DW];
					
					
			end
			else begin
					ch_en_w[i] = 'd0;
					din[i]='d0;
					
					
			end
		end
	end

	


genvar m;

generate

	for(m=0; m <=RAM_CH_OUT-1; m = m+1) begin : gen_ram


	out_ram_ch #( .DW(DW), .RAM_NUM_OUT(RAM_NUM_OUT),  .RAM_SIZE_OUT (RAM_SIZE_OUT),
.ADDR_DW (ADDR_DW),.ROWS (ROWS))
u_ram_out_ch1
( .clk	(clk),
 
 .rst_n (rst_n),
 .STRIDE (STRIDE),
 .KERNEL_DIM (KERNEL_DIM),
 .INFMAP_ROWS (INFMAP_ROWS),
 .ch_enable_w    (ch_en_w[m]),
 .ch_enable_r    (ch_en_r[m]),
 .ram_select_w  (ram_select_w),
 .ram_select_r_x (ram_select_r_x),
 .ram_select_r_y (ram_select_r_y),
 .addr_r_x    (addr_r_x),
 .addr_r_y     (addr_r_y),
 .addr_w	(addr_w),

 .data_in	(din[m]),
 .data_out	(dout[m])
 );
end
 




	
endgenerate

endmodule





		