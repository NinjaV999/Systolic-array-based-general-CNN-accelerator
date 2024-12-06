



module weight_rom #(parameter DW=8, parameter ROM_NUM=6, parameter ROM_SIZE=25 ,
parameter ADDR_DW=5,parameter COLS = 8,  parameter ABS_ADDR_DW = 16, parameter KERNEL_ELEMENT = 15)

(input clk,
 input rst_n,
 input [15:0] KERNEL_NUM,
 input [15:0] addr_r,// 与cnt_kernel 相连	   
 input [ABS_ADDR_DW-1:0] base_addr, //因为多个kernel 存放在一个rom里，因此其用来记录前一个kernel的偏移地址   
 input [15:0] rom_select, //与folding_cols_cur相连
input initial_sig,
 input data_out_valid,
 
 output reg [(DW)*COLS-1:0] data_out,
 output  mem_sig );

 reg [ROM_NUM-1:0] rd_en;  //现在的rom_num 等于 cols

 reg  [7:0] rom_select_r;

 wire [ABS_ADDR_DW-1:0] abs_addr;
 assign abs_addr = base_addr+addr_r;
 wire [DW-1:0] dout [ROM_NUM-1:0];
 wire mem_initial_sig [ROM_NUM-1:0];
 assign mem_sig = mem_initial_sig [0];


always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		rom_select_r<='d0;
	end
	else begin
		rom_select_r <= rom_select;
	end
	
end

integer i;
 
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

	always@(*) begin
		
		for(j=COLS-1;j>=0; j=j-1) begin

			if(j+rom_select_r <= KERNEL_NUM-1) begin // 4+3 > 6 因此存0

				data_out  ={ data_out [(DW)*(COLS-1)-1: 0],dout [j]}; //最低为信号就会存储在data_out的低位 ，不够的信号会自动补0
			end
			else begin
				data_out   ={ data_out [(DW)*(COLS-1)-1: 0], {(DW){1'b0}}};
			end
		end
	end
	


genvar m;


generate

	for(m=0; m <=ROM_NUM-1; m = m+1) begin : gen_rom
		rom #(
     .DW (DW),          // 数据宽度
          // 行数
     .COLS (COLS),
     .ADDR_DW  (ABS_ADDR_DW),     // 地址宽度
     .ROM_SIZE  (ROM_SIZE),
     .KERNEL_ELEMENT (KERNEL_ELEMENT)  // 内存行数
   
) 
	
u_rom(
   .clk	(clk),                 // 时钟信号
               // 写使能信号
    .RAenable  (rd_en[m]),            // 读使能信号
    .initial_sig (initial_sig),         // 初始化信号
       .para (m),
    .addr (abs_addr),    // 地址总线
   
         // 数据输入总线
     // 写完成信号
     .dout (dout[m]), // 数据输出总线
     .mem_initial_signal (mem_initial_sig [m])
);

end
	

	
endgenerate
endmodule