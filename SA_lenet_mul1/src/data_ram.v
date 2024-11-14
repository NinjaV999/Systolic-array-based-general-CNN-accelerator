

 module data_ram #(parameter DW=8, parameter RAM_NUM=32, parameter RAM_SIZE=32 ,
parameter ADDR_DW=5,parameter ROWS = 8)

(input clk,
 input rst_n,
 input [8:0] image_index,
 input [1:0]  STRIDE,
 input [7:0] addr_r_x,	      // 对有效信号进行移位起到了类似卷积窗口滑动的效果
 input [3:0] addr_r_y,	      // 确定一个卷积块中的列数
 input [ADDR_DW-1:0] ram_select_r_x, //用来索引哪几个ram 块 有效
 input [ADDR_DW-1:0] ram_select_r_y, // 考虑到当前的行折叠
 input [3:0] KERNEL_DIM,
 input data_out_valid,
 
 output reg [(DW)*ROWS-1:0] data_out
);
 reg [8:0] addr_r;

 reg [RAM_NUM-1:0] rd_en;
 reg [RAM_NUM-1:0] rd_en_r;

 reg [ADDR_DW-1:0] ram_select_r_x_r;
 reg [7:0] addr_r_x_r;
 
 wire  dout [RAM_NUM-1:0];


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
        
       
        
        addr_r = addr_r_y+ram_select_r_y+image_index;
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
				
				data_out = { data_out [(DW)*(ROWS-1)-1: 0],{ {(DW-1){1'b0}},{dout [ram_select_r_x_r+j*STRIDE+addr_r_x_r]}}};

			end
 			else begin
				data_out   ={ data_out [(DW)*(ROWS-1)-1: 0], {(DW){1'b0}}};
			end
		end
	end


data_rom0 data0 (
  .clka(clk),    // input wire clka
  .ena(rd_en[0]),      // input wire ena
  .addra(addr_r),  // input wire [4 : 0] addra
  .douta(dout[0])  // output wire [15 : 0] douta
);


data_rom1 data1 (
  .clka(clk),    // input wire clka
  .ena(rd_en[1]),      // input wire ena
  .addra(addr_r),  // input wire [4 : 0] addra
  .douta(dout[1])  
);


data_rom2 data2 (
  .clka(clk),    // input wire clka
  .ena(rd_en[2]),      // input wire ena
  .addra(addr_r),  // input wire [4 : 0] addra
  .douta(dout[2])  
);

data_rom3 data3 (
  .clka(clk),    // input wire clka
  .ena(rd_en[3]),      // input wire ena
  .addra(addr_r),  // input wire [4 : 0] addra
  .douta(dout[3])  
);

data_rom4 data4 (
  .clka(clk),    // input wire clka
  .ena(rd_en[4]),      // input wire ena
  .addra(addr_r),  // input wire [4 : 0] addra
  .douta(dout[4])  
);


data_rom5 data5 (
  .clka(clk),    // input wire clka
  .ena(rd_en[5]),      // input wire ena
  .addra(addr_r),  // input wire [4 : 0] addra
  .douta(dout[5])  
);

data_rom6 data6 (
  .clka(clk),    // input wire clka
  .ena(rd_en[6]),      // input wire ena
  .addra(addr_r),  // input wire [4 : 0] addra
  .douta(dout[6])  
);

data_rom7 data7 (
  .clka(clk),    // input wire clka
  .ena(rd_en[7]),      // input wire ena
  .addra(addr_r),  // input wire [4 : 0] addra
  .douta(dout[7])  
);

data_rom8 data8 (
  .clka(clk),    // input wire clka
  .ena(rd_en[8]),      // input wire ena
  .addra(addr_r),  // input wire [4 : 0] addra
  .douta(dout[8])  
);

data_rom9 data9 (
  .clka(clk),    // input wire clka
  .ena(rd_en[9]),      // input wire ena
  .addra(addr_r),  // input wire [4 : 0] addra
  .douta(dout[9])  
);

data_rom10 data10 (
  .clka(clk),    // input wire clka
  .ena(rd_en[10]),      // input wire ena
  .addra(addr_r),  // input wire [4 : 0] addra
  .douta(dout[10])  
);

data_rom11 data11 (
  .clka(clk),    // input wire clka
  .ena(rd_en[11]),      // input wire ena
  .addra(addr_r),  // input wire [4 : 0] addra
  .douta(dout[11])  
);

data_rom12 data12 (
  .clka(clk),    // input wire clka
  .ena(rd_en[12]),      // input wire ena
  .addra(addr_r),  // input wire [4 : 0] addra
  .douta(dout[12])  
);

data_rom13 data13 (
  .clka(clk),    // input wire clka
  .ena(rd_en[13]),      // input wire ena
  .addra(addr_r),  // input wire [4 : 0] addra
  .douta(dout[13])  
);

data_rom14 data14 (
  .clka(clk),    // input wire clka
  .ena(rd_en[14]),      // input wire ena
  .addra(addr_r),  // input wire [4 : 0] addra
  .douta(dout[14])  
);

data_rom15 data15 (
  .clka(clk),    // input wire clka
  .ena(rd_en[15]),      // input wire ena
  .addra(addr_r),  // input wire [4 : 0] addra
  .douta(dout[15])  
);

data_rom16 data16 (
  .clka(clk),    // input wire clka
  .ena(rd_en[16]),      // input wire ena
  .addra(addr_r),  // input wire [4 : 0] addra
  .douta(dout[16])  
);

data_rom17 data17 (
  .clka(clk),    // input wire clka
  .ena(rd_en[17]),      // input wire ena
  .addra(addr_r),  // input wire [4 : 0] addra
  .douta(dout[17])  
);

data_rom18 data18 (
  .clka(clk),    // input wire clka
  .ena(rd_en[18]),      // input wire ena
  .addra(addr_r),  // input wire [4 : 0] addra
  .douta(dout[18])  
);

data_rom19 data19 (
  .clka(clk),    // input wire clka
  .ena(rd_en[19]),      // input wire ena
  .addra(addr_r),  // input wire [4 : 0] addra
  .douta(dout[19])  
);

data_rom20 data20 (
  .clka(clk),    // input wire clka
  .ena(rd_en[20]),      // input wire ena
  .addra(addr_r),  // input wire [4 : 0] addra
  .douta(dout[20])  
);

data_rom21 data21 (
  .clka(clk),    // input wire clka
  .ena(rd_en[21]),      // input wire ena
  .addra(addr_r),  // input wire [4 : 0] addra
  .douta(dout[21])  
);

data_rom22 data22 (
  .clka(clk),    // input wire clka
  .ena(rd_en[22]),      // input wire ena
  .addra(addr_r),  // input wire [4 : 0] addra
  .douta(dout[22])  
);

data_rom23 data23 (
  .clka(clk),    // input wire clka
  .ena(rd_en[23]),      // input wire ena
  .addra(addr_r),  // input wire [4 : 0] addra
  .douta(dout[23])  
);

data_rom24 data24 (
  .clka(clk),    // input wire clka
  .ena(rd_en[24]),      // input wire ena
  .addra(addr_r),  // input wire [4 : 0] addra
  .douta(dout[24])  
);

data_rom25 data25 (
  .clka(clk),    // input wire clka
  .ena(rd_en[25]),      // input wire ena
  .addra(addr_r),  // input wire [4 : 0] addra
  .douta(dout[25])  
);

data_rom26 data26 (
  .clka(clk),    // input wire clka
  .ena(rd_en[26]),      // input wire ena
  .addra(addr_r),  // input wire [4 : 0] addra
  .douta(dout[26])  
);

data_rom27 data27 (
  .clka(clk),    // input wire clka
  .ena(rd_en[27]),      // input wire ena
  .addra(addr_r),  // input wire [4 : 0] addra
  .douta(dout[27])  
);

data_rom28 data28 (
  .clka(clk),    // input wire clka
  .ena(rd_en[28]),      // input wire ena
  .addra(addr_r),  // input wire [4 : 0] addra
  .douta(dout[28])  
);

data_rom29 data29 (
  .clka(clk),    // input wire clka
  .ena(rd_en[29]),      // input wire ena
  .addra(addr_r),  // input wire [4 : 0] addra
  .douta(dout[29])  
);

data_rom30 data30 (
  .clka(clk),    // input wire clka
  .ena(rd_en[30]),      // input wire ena
  .addra(addr_r),  // input wire [4 : 0] addra
  .douta(dout[30])  
);

data_rom31 data31 (
  .clka(clk),    // input wire clka
  .ena(rd_en[31]),      // input wire ena
  .addra(addr_r),  // input wire [4 : 0] addra
  .douta(dout[31])  
);

endmodule


	
		