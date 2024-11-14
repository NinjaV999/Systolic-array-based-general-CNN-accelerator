



module weight_rom #(parameter DW=8, parameter ROM_NUM=6, parameter ROM_SIZE=25 ,
parameter ADDR_DW=5,parameter COLS = 8,  parameter ABS_ADDR_DW = 16, parameter KERNEL_ELEMENT = 15)

(input clk,
 input rst_n,
 input [15:0] KERNEL_NUM,
 input [15:0] addr_r,// ��cnt_kernel ����	   
 input [ABS_ADDR_DW-1:0] base_addr, //��Ϊ���kernel �����һ��rom������������¼ǰһ��kernel��ƫ�Ƶ�ַ   
 input [15:0] rom_select, //��folding_cols_cur����
 input data_out_valid,
 
 output reg [(DW)*COLS-1:0] data_out );

 reg [ROM_NUM-1:0] rd_en, rd_en_r;  //���ڵ�rom_num ���� cols



 wire [ABS_ADDR_DW-1:0] abs_addr;
 assign abs_addr = base_addr+addr_r;
 wire [DW-1:0] dout [ROM_NUM-1:0];



always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		
		rd_en_r<='d0;
	end
	else begin
		
		rd_en_r<=rd_en;
	end
	
end

integer i;
 
   always@(*)begin
	for(i=0;i<=ROM_NUM-1;i=i+1) begin //��һ����0��0 1 2 3, rdȫΪ1 �ڶ�����4 �� 45 Ϊ 1��67 Ϊ0 
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

			if(rd_en_r[j] == 1'b1) begin // 4+3 > 6 ��˴�0

				data_out  ={ data_out [(DW)*(COLS-1)-1: 0],dout [j]}; //���Ϊ�źžͻ�洢��data_out�ĵ�λ ���������źŻ��Զ���0
			end
			else begin
				data_out   ={ data_out [(DW)*(COLS-1)-1: 0], {(DW){1'b0}}};
			end
		end
	end
	



	  weight1_rom0 weight0 (
  .clka(clk),    // input wire clka
  .ena(rd_en[0]),      // input wire ena
  .addra(abs_addr),  // input wire [4 : 0] addra
  .douta(dout[0])  // output wire [15 : 0] douta

);

	  weight1_rom1 weight1 (
  .clka(clk),    // input wire clka
  .ena(rd_en[1]),      // input wire ena
  .addra(abs_addr),  // input wire [4 : 0] addra
  .douta(dout[1])  // output wire [15 : 0] douta

);
	
	
		  weight1_rom2 weight2 (
  .clka(clk),    // input wire clka
  .ena(rd_en[2]),      // input wire ena
  .addra(abs_addr),  // input wire [4 : 0] addra
  .douta(dout[2])  // output wire [15 : 0] douta

);

	
		  weight1_rom3 weight3 (
  .clka(clk),    // input wire clka
  .ena(rd_en[3]),      // input wire ena
  .addra(abs_addr),  // input wire [4 : 0] addra
  .douta(dout[3])  // output wire [15 : 0] douta

);

endmodule







module weight_rom2 #(parameter DW=8, parameter ROM_NUM=6, parameter ROM_SIZE=25 ,
parameter ADDR_DW=5,parameter COLS = 8,  parameter ABS_ADDR_DW = 16, parameter KERNEL_ELEMENT = 15)

(input clk,
 input rst_n,
 input [15:0] KERNEL_NUM,
 input [15:0] addr_r,// ��cnt_kernel ����	   
 input [ABS_ADDR_DW-1:0] base_addr, //��Ϊ���kernel �����һ��rom������������¼ǰһ��kernel��ƫ�Ƶ�ַ   
 input [15:0] rom_select, //��folding_cols_cur����,
 input data_out_valid,
 
 output reg [(DW)*COLS-1:0] data_out );

 reg [ROM_NUM-1:0] rd_en, rd_en_r;  //���ڵ�rom_num ���� cols



 wire [ABS_ADDR_DW-1:0] abs_addr;
 assign abs_addr = base_addr+addr_r;
 wire [DW-1:0] dout [ROM_NUM-1:0];


always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		
		rd_en_r<='d0;
	end
	else begin
		
		rd_en_r<=rd_en;
	end
	
end

integer i;
 
   always@(*)begin
	for(i=0;i<=ROM_NUM-1;i=i+1) begin //��һ����0��0 1 2 3, rdȫΪ1 �ڶ�����4 �� 45 Ϊ 1��67 Ϊ0 
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

			if(rd_en_r[j] == 1'b1) begin // 4+3 > 6 ��˴�0

				data_out  ={ data_out [(DW)*(COLS-1)-1: 0],dout [j]}; //���Ϊ�źžͻ�洢��data_out�ĵ�λ ���������źŻ��Զ���0
			end
			else begin
				data_out   ={ data_out [(DW)*(COLS-1)-1: 0], {(DW){1'b0}}};
			end
		end
	end
	



	  weight2_rom0 weight0 (
  .clka(clk),    // input wire clka
  .ena(rd_en[0]),      // input wire ena
  .addra(abs_addr),  // input wire [4 : 0] addra
  .douta(dout[0])  // output wire [15 : 0] douta

);

	  weight2_rom1 weight1 (
  .clka(clk),    // input wire clka
  .ena(rd_en[1]),      // input wire ena
  .addra(abs_addr),  // input wire [4 : 0] addra
  .douta(dout[1])  // output wire [15 : 0] douta

);
	
	
		  weight2_rom2 weight2 (
  .clka(clk),    // input wire clka
  .ena(rd_en[2]),      // input wire ena
  .addra(abs_addr),  // input wire [4 : 0] addra
  .douta(dout[2])  // output wire [15 : 0] douta

);

	
		  weight2_rom3 weight3 (
  .clka(clk),    // input wire clka
  .ena(rd_en[3]),      // input wire ena
  .addra(abs_addr),  // input wire [4 : 0] addra
  .douta(dout[3])  // output wire [15 : 0] douta

);

endmodule