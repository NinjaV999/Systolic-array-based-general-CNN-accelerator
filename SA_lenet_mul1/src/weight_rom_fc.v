
/*
���ڲ������ã�
1.ROM_NUM �� COLS����һ�£�����Ϊ4����Ȼ���һ��rom �ʹ�0 -4 -8�⼸��kernel
�ڶ���ROM�ʹ�1-5-9��������
2.Ҫ��������һ������װ�ã�Ҫ����һ�����˵�ַ������rom_select��ֵ����ƫ�ƣ���rom select Ϊ0��ʱ��ƫ��Ϊ0��
��Ϊ1��ʱ�� ƫ�Ƶ�ַΪrom_select * һ��kernel��Ԫ������

3. ��ƫ�Ƶ�ַ�Ļ������ټ���addr_r ��Ϊ��һ��kernel��Ԫ������


*/
module weight_rom_fc #(parameter DW=8, parameter ROM_NUM=6, parameter ROM_SIZE=25 ,
parameter ADDR_DW=5,parameter COLS = 8,parameter ABS_ADDR_DW =16 )//��ʾһ��kernel��������Ԫ����

(input clk,
 input rst_n,
 input [15:0] KERNEL_NUM,
 input [15:0] addr_r,// ��cnt_kernel ����	      
 input [ABS_ADDR_DW-1:0] base_addr, //��folding_cols_cur����
 input [15:0] rom_select,
 input data_out_valid,
 
 output reg [(DW)*COLS-1:0] data_out );




 reg [ROM_NUM-1:0] rd_en,rd_en_r; //4��
 wire [ABS_ADDR_DW-1:0] abs_addr;
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
 

   assign abs_addr = base_addr+addr_r;

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
//����Ͳ���Ҫ�����ж��ˣ����ڳ�ʼ��mem��ʱ�򶼷�����ͬ�Ĵ洢�ռ䣬����������mem �� 0 ���ȥ
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
	

  weight3_rom0 weight0 (
  .clka(clk),    // input wire clka
  .ena(rd_en[0]),      // input wire ena
  .addra(abs_addr),  // input wire [4 : 0] addra
  .douta(dout[0])  // output wire [15 : 0] douta

);

	  weight3_rom1 weight1 (
  .clka(clk),    // input wire clka
  .ena(rd_en[1]),      // input wire ena
  .addra(abs_addr),  // input wire [4 : 0] addra
  .douta(dout[1])  // output wire [15 : 0] douta

);
	
	
		  weight3_rom2 weight2 (
  .clka(clk),    // input wire clka
  .ena(rd_en[2]),      // input wire ena
  .addra(abs_addr),  // input wire [4 : 0] addra
  .douta(dout[2])  // output wire [15 : 0] douta

);

	
		  weight3_rom3 weight3 (
  .clka(clk),    // input wire clka
  .ena(rd_en[3]),      // input wire ena
  .addra(abs_addr),  // input wire [4 : 0] addra
  .douta(dout[3])  // output wire [15 : 0] douta

);
endmodule



module weight_rom_fc2 #(parameter DW=8, parameter ROM_NUM=6, parameter ROM_SIZE=25 ,
parameter ADDR_DW=5,parameter COLS = 8,parameter ABS_ADDR_DW =16 )//��ʾһ��kernel��������Ԫ����

(input clk,
 input rst_n,
 input [15:0] KERNEL_NUM,
 input [15:0] addr_r,// ��cnt_kernel ����	      
 input [ABS_ADDR_DW-1:0] base_addr, //��folding_cols_cur����
 input [15:0] rom_select,
 input data_out_valid,
 
 output reg [(DW)*COLS-1:0] data_out );




 reg [ROM_NUM-1:0] rd_en,rd_en_r; //4��
 wire [ABS_ADDR_DW-1:0] abs_addr;
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
 

   assign abs_addr = base_addr+addr_r;

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
//����Ͳ���Ҫ�����ж��ˣ����ڳ�ʼ��mem��ʱ�򶼷�����ͬ�Ĵ洢�ռ䣬����������mem �� 0 ���ȥ
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
	

  weight4_rom0 weight0 (
  .clka(clk),    // input wire clka
  .ena(rd_en[0]),      // input wire ena
  .addra(abs_addr),  // input wire [4 : 0] addra
  .douta(dout[0])  // output wire [15 : 0] douta

);

	  weight4_rom1 weight1 (
  .clka(clk),    // input wire clka
  .ena(rd_en[1]),      // input wire ena
  .addra(abs_addr),  // input wire [4 : 0] addra
  .douta(dout[1])  // output wire [15 : 0] douta

);
	
	
		  weight4_rom2 weight2 (
  .clka(clk),    // input wire clka
  .ena(rd_en[2]),      // input wire ena
  .addra(abs_addr),  // input wire [4 : 0] addra
  .douta(dout[2])  // output wire [15 : 0] douta

);

	
		  weight4_rom3 weight3 (
  .clka(clk),    // input wire clka
  .ena(rd_en[3]),      // input wire ena
  .addra(abs_addr),  // input wire [4 : 0] addra
  .douta(dout[3])  // output wire [15 : 0] douta

);
endmodule


module weight_rom_fc3 #(parameter DW=8, parameter ROM_NUM=6, parameter ROM_SIZE=25 ,
parameter ADDR_DW=5,parameter COLS = 8,parameter ABS_ADDR_DW =16 )//��ʾһ��kernel��������Ԫ����

(input clk,
 input rst_n,
 input [15:0] KERNEL_NUM,
 input [15:0] addr_r,// ��cnt_kernel ����	      
 input [ABS_ADDR_DW-1:0] base_addr, //��folding_cols_cur����
 input [15:0] rom_select,
 input data_out_valid,
 
 output reg [(DW)*COLS-1:0] data_out );




 reg [ROM_NUM-1:0] rd_en,rd_en_r; //4��
 wire [ABS_ADDR_DW-1:0] abs_addr;
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
 

   assign abs_addr = base_addr+addr_r;

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
//����Ͳ���Ҫ�����ж��ˣ����ڳ�ʼ��mem��ʱ�򶼷�����ͬ�Ĵ洢�ռ䣬����������mem �� 0 ���ȥ
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
	

  weight5_rom0 weight0 (
  .clka(clk),    // input wire clka
  .ena(rd_en[0]),      // input wire ena
  .addra(abs_addr),  // input wire [4 : 0] addra
  .douta(dout[0])  // output wire [15 : 0] douta

);

	  weight5_rom1 weight1 (
  .clka(clk),    // input wire clka
  .ena(rd_en[1]),      // input wire ena
  .addra(abs_addr),  // input wire [4 : 0] addra
  .douta(dout[1])  // output wire [15 : 0] douta

);
	
	
		  weight5_rom2 weight2 (
  .clka(clk),    // input wire clka
  .ena(rd_en[2]),      // input wire ena
  .addra(abs_addr),  // input wire [4 : 0] addra
  .douta(dout[2])  // output wire [15 : 0] douta

);

	
		  weight5_rom3 weight3 (
  .clka(clk),    // input wire clka
  .ena(rd_en[3]),      // input wire ena
  .addra(abs_addr),  // input wire [4 : 0] addra
  .douta(dout[3])  // output wire [15 : 0] douta

);
endmodule
