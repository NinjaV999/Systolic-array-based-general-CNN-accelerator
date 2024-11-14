` timescale 1ns/1ps

module test_top;

	parameter DW=16;
	parameter ADDR_DW =5;
	parameter ADDR_DW_ROM = 8;
	parameter ABS_ADDR_DW =16;
	
	// kernel 84 10 

	
	
	
	parameter CNT_W=9;// ��������λ��

	parameter ROWS = 4;//8; //SA���е�����
	parameter COLS = 4;//8;//SA���е�����
	// 32 32 -> 14 14 6->5 5 16-> 1 1 120->1 1 84 -> 1 1 10
	parameter ROM_CH = 1;
	parameter ROM_SIZE = ROM_CH*25*2;//50;
	parameter ROM_NUM = COLS;//9;
	parameter KERNEL_ELEMENT = 25;

	parameter ROM_CH2 = 6;
	parameter ROM_SIZE2 = ROM_CH2*25*4;//600;
	parameter ROM_NUM2 =COLS;//9;
	parameter KERNEL_ELEMENT2 = 150;

	parameter ROM_NUM3 =COLS ;//9;
	parameter ROM_SIZE3 = 12000;
	

	parameter ROM_NUM4 =COLS ;//9;
	parameter ROM_SIZE4 = 2520 ;
	

	parameter ROM_NUM5 =COLS ;//9;
	parameter ROM_SIZE5 = 252;
	

	parameter RAM_SIZE = 32;//7;
	parameter RAM_NUM = 32;//7;

	parameter ROM_SIZE_BIAS = 2;//7;
	parameter ROM_SIZE_BIAS2= 4;//7;
	parameter ROM_SIZE_BIAS3= 100;//7;
	parameter ROM_SIZE_BIAS4=21;
	parameter ROM_SIZE_BIAS5=3;
	parameter ROM_NUM_BIAS = COLS;//7;
	

	parameter RAM_CH_OUT1 =6;// 9 
	parameter RAM_NUM_OUT1= 14; 
	parameter RAM_SIZE_OUT1 = 14;


	
	parameter RAM_CH_OUT2 =16;
	parameter RAM_NUM_OUT2= 5; 
	parameter RAM_SIZE_OUT2= 5;
	
	parameter RAM_NUM_FC1 =COLS;
	parameter RAM_SIZE_FC1 = 30;

	parameter RAM_NUM_FC2 =COLS;
	parameter RAM_SIZE_FC2 = 21;

	
// ��������
	


	//����fc�������Ҫ�洢��Ҫ���⴦��
	

	
	
	reg clk;
	reg rst_n;
	reg host2inMem_flag;
    reg [3:0] image_select;
    reg [8:0] image_index;
    reg start;
    wire key_out;
    key_filter kf(
     .clk (clk)     ,
    .rst_n (rst_n)   ,
    .key_in (start)  ,//���������ź�

   .key_out (key_out)   
);
	
	initial begin
			clk = 0;
			rst_n=1'b1;
			host2inMem_flag=0 ;
			start = 0;
			image_select='d7;
			#10 rst_n =1'b0;
			
			//state_flag=2'b01;
		#140 	rst_n=1'b1;
	
		#500000 rst_n = 1'b0;
		 image_select = 'd2;
		#140 rst_n =1'b1;
		
		       
		#200 start = 1'b0;
		  	
			
	end
	

	always begin
		#5	clk=~clk;
	end
    	always@(posedge clk )begin
        if(!rst_n) begin
                host2inMem_flag<=1'b1;
                image_index<= image_select * 6'b10_0000;
        end
        else begin
                 host2inMem_flag<=1'b0;
         end
   end
   

	reg [(DW)*ROWS-1:0] din_inf;
	wire [(DW)*ROWS-1:0] din_inf1,din_inf_out,din_inf_out2;
     wire [DW-1:0] out_data_fc1,out_data_fc2;
	 reg [(DW)*COLS-1:0] din_weight;
	wire [(DW)*COLS-1:0] din_weight1,din_weight2,din_weight3,din_weight4,din_weight5;
	 reg [(DW)*COLS-1:0] din_bias;
	wire [(DW)*COLS-1:0] din_bias1,din_bias2,din_bias3,din_bias4,din_bias5;
	wire [ABS_ADDR_DW-1:0] base_addr;
	wire[3:0] predict_index;
	
	
	 wire RA_enable;
	 wire RA_enable_bias;
	
	
	
	wire [3:0] KERNEL_DIM;
	wire [15:0] KERNEL_NUM;
	wire [1:0] STRIDE;

	wire [7:0] addr_inf_x;
	wire [3:0] addr_inf_y;
	wire [15:0] addr_weight;
	wire [7:0] addr_bias;
	wire [7:0] addr_w_fc;
	wire [15:0] rom_select;
	wire [3:0] ch_select;
	
	
	wire  [ADDR_DW-1:0] ram_select_x;
	wire [ADDR_DW-1:0] ram_select_y;
	wire WR_enable_out ;
	wire [ADDR_DW-1:0] addr_out_w;
	wire [ADDR_DW-1:0] ram_select_out_w;
	wire  [3:0] ch_out_w;

	wire [3:0] layer_index;
	wire [5:0] INFMAP_ROWS;
	
	wire [(DW)*COLS-1:0] output_data;
	
	
	reg clk_enable1,clk_enable2,clk_enable3,clk_enable4,clk_enable5;
	

	reg read_enable_1,read_enable_out1,write_enable_out1;
	reg read_enable_out2,write_enable_out2;
	//reg read_enable_out3, write_enable_out3;
	reg read_enable_fc1 , write_enable_fc1;
	reg read_enable_fc2, write_enable_fc2;
	
	
	always@(*) begin
		case (layer_index)
			4'b0001: begin clk_enable1 = 1'b1;
					clk_enable2 = 1'b0;
					clk_enable3 = 1'b0;
					clk_enable4=1'b0;
					clk_enable5 = 1'b0;

					read_enable_1 = 1'b1;
					read_enable_out1 = 1'b0;
					write_enable_out1 =1'b1;

					read_enable_out2 = 1'b0;
					write_enable_out2 =1'b0;

					read_enable_fc1 = 1'b0;
					write_enable_fc1 = 1'b0;

					read_enable_fc2 = 1'b0;
					write_enable_fc2 = 1'b0;

					din_inf = din_inf1;
					din_weight = din_weight1;
					din_bias = din_bias1;
				end



			4'b0010 : begin clk_enable1 = 1'b0;
					clk_enable2 = 1'b1;
					clk_enable3 = 1'b0;
					clk_enable4=1'b0;
					clk_enable5 = 1'b0;

					read_enable_1 = 1'b0;
					read_enable_out1 = 1'b1;
					write_enable_out1 =1'b0;

					read_enable_out2 = 1'b0;
					write_enable_out2 =1'b1;

					read_enable_fc1 = 1'b0;
					write_enable_fc1= 1'b0;

					read_enable_fc2 = 1'b0;
					write_enable_fc2 = 1'b0;

					din_inf = din_inf_out;
					din_weight = din_weight2;
					din_bias = din_bias2;
					
				 end
			4'b0011: begin

					clk_enable1 = 1'b0;
					clk_enable2 = 1'b0;
					clk_enable3 = 1'b1;
					clk_enable4=1'b0;
					clk_enable5 = 1'b0;

					read_enable_1 = 1'b0;
					read_enable_out1 = 1'b0;
					write_enable_out1 =1'b0;

					read_enable_out2 = 1'b1;
					write_enable_out2 =1'b0;

					read_enable_fc1= 1'b0;
					write_enable_fc1 = 1'b1;

					read_enable_fc2 = 1'b0;
					write_enable_fc2 = 1'b0;

					din_inf = din_inf_out2;
					din_weight = din_weight3;
					din_bias = din_bias3;
			
				end


			4'b0100: begin

					clk_enable1 = 1'b0;
					clk_enable2 = 1'b0;
					clk_enable3 = 1'b0;
					clk_enable4=1'b1;
					clk_enable5 = 1'b0;

					read_enable_1 = 1'b0;
					read_enable_out1 = 1'b0;
					write_enable_out1 =1'b0;

					read_enable_out2 = 1'b0;
					write_enable_out2 =1'b0;

					read_enable_fc1= 1'b1;
					write_enable_fc1 = 1'b0;

					read_enable_fc2 = 1'b0;
					write_enable_fc2 = 1'b1;

					din_inf = out_data_fc1;
					din_weight = din_weight4;
					din_bias = din_bias4;
			
				end

			4'b0101: begin

					clk_enable1 = 1'b0;
					clk_enable2 = 1'b0;
					clk_enable3 = 1'b0;
					clk_enable4=1'b0;
					clk_enable5 = 1'b1;

					read_enable_1 = 1'b0;
					read_enable_out1 = 1'b0;
					write_enable_out1 =1'b0;

					read_enable_out2 = 1'b0;
					write_enable_out2 =1'b0;

					read_enable_fc1= 1'b0;
					write_enable_fc1 = 1'b1;

					read_enable_fc2 = 1'b1;
					write_enable_fc2 = 1'b0;

					din_inf = out_data_fc2;
					din_weight = din_weight5;
					din_bias = din_bias5;
			
				end


			default : begin
					clk_enable1 = 1'b0;
					clk_enable2 = 1'b0;
					clk_enable3 = 1'b0;
					clk_enable4 = 1'b0;
					clk_enable5 = 1'b0;

					read_enable_1 = 1'b0;
					read_enable_out1 = 1'b0;
					write_enable_out1 =1'b0;

					read_enable_out2 = 1'b0;
					write_enable_out2 =1'b0;

					read_enable_fc1 = 1'b0;
					write_enable_fc1 = 1'b0;
			
					read_enable_fc2 = 1'b0;
					write_enable_fc2 = 1'b0;

					din_inf = 'd0;
					din_weight = 'd0;
					din_bias = 'd0;
				end
		endcase
	end
			
			
			



data_ram #( .DW (DW),  .RAM_NUM (RAM_NUM),  .RAM_SIZE (RAM_SIZE) ,
.ADDR_DW (ADDR_DW),.ROWS  (ROWS))
u_data_ram
( .clk (clk ),
  .rst_n (rst_n),
   .STRIDE (STRIDE),
  .image_index(image_index),
  .addr_r_x (addr_inf_x),	      // ����Ч�źŽ�����λ�������ƾ�����ڻ�����Ч��
  .addr_r_y (addr_inf_y),	      // ȷ��һ��������е�����
  .ram_select_r_x (ram_select_x), //���������ļ���ram �� ��Ч
  .ram_select_r_y (ram_select_y), // ���ǵ���ǰ�����۵�
  .KERNEL_DIM      (KERNEL_DIM),
   .data_out_valid  (RA_enable && read_enable_1),
 
  .data_out         (din_inf1)
);


weight_rom #( .DW (DW),  .ROM_NUM (ROM_NUM),  .ROM_SIZE (ROM_SIZE) ,
.ADDR_DW (ADDR_DW),.COLS  (COLS), .ABS_ADDR_DW(ABS_ADDR_DW), .KERNEL_ELEMENT (KERNEL_ELEMENT))
u_weight_rom
(.clk	(clk),
 .rst_n (rst_n),

 .KERNEL_NUM (KERNEL_NUM),
 .addr_r (addr_weight),// ��cnt_kernel ����	
 .base_addr (base_addr),        
 .rom_select  (rom_select), //��folding_cols_cur����

 .data_out_valid (RA_enable  && clk_enable1) ,
 
 .data_out  (din_weight1));


weight_rom2 #(.DW (DW),  .ROM_NUM (ROM_NUM2),  .ROM_SIZE (ROM_SIZE2) ,
.ADDR_DW (ADDR_DW),.COLS  (COLS) , .ABS_ADDR_DW(ABS_ADDR_DW), .KERNEL_ELEMENT (KERNEL_ELEMENT2))
u_weight_rom_2
(.clk	(clk ),
 .rst_n (rst_n),

   .KERNEL_NUM (KERNEL_NUM),
 .addr_r (addr_weight),// ��cnt_kernel ����	
 .base_addr (base_addr),        
 .rom_select  (rom_select), //��folding_cols_cur����initial_sig (host2inMem_flag),
 .data_out_valid (RA_enable && clk_enable2),
 
 .data_out  (din_weight2));


weight_rom_fc #(.DW (DW),  .ROM_NUM (ROM_NUM3),  .ROM_SIZE (ROM_SIZE3) ,
.ADDR_DW (ADDR_DW),.COLS  (COLS), .ABS_ADDR_DW  (ABS_ADDR_DW) )
u_weight_rom_3
(.clk	(clk ),
 .rst_n (rst_n),

   .KERNEL_NUM (KERNEL_NUM),
 .addr_r (addr_weight),// ��cnt_kernel ����	
 .base_addr (base_addr),      
 .rom_select  (rom_select), //��folding_cols_cur����initial_sig (host2inMem_flag),
 .data_out_valid (RA_enable && clk_enable3),
 
 .data_out  (din_weight3));


weight_rom_fc2 #(.DW (DW),  .ROM_NUM (ROM_NUM4),  .ROM_SIZE (ROM_SIZE4) ,
.ADDR_DW (ADDR_DW),.COLS  (COLS), .ABS_ADDR_DW  (ABS_ADDR_DW))
u_weight_rom_4
(.clk	(clk ),
 .rst_n (rst_n),

   .KERNEL_NUM (KERNEL_NUM),
 .addr_r (addr_weight),// ��cnt_kernel ����	
 .base_addr (base_addr),      
 .rom_select  (rom_select), //��folding_cols_cur����initial_sig (host2inMem_flag),
 .data_out_valid (RA_enable && clk_enable4),
 
 .data_out  (din_weight4));


weight_rom_fc3 #(.DW (DW),  .ROM_NUM (ROM_NUM5),  .ROM_SIZE (ROM_SIZE5) ,
.ADDR_DW (ADDR_DW),.COLS  (COLS), .ABS_ADDR_DW  (ABS_ADDR_DW))
u_weight_rom_5
(.clk	(clk ),
 .rst_n (rst_n),

   .KERNEL_NUM (KERNEL_NUM),
 .addr_r (addr_weight),// ��cnt_kernel ����	
 .base_addr (base_addr),      
 .rom_select  (rom_select), //��folding_cols_cur����initial_sig (host2inMem_flag),
 .data_out_valid (RA_enable && clk_enable5),
 
 .data_out  (din_weight5)
 );





bias_rom1 #( .DW (DW),  .ROM_NUM_BIAS (ROM_NUM_BIAS),  .ROM_SIZE_BIAS (ROM_SIZE_BIAS) ,
.ADDR_DW (ADDR_DW),.COLS  (COLS),.ADDR_DW_ROM (ADDR_DW_ROM))
u_bias_rom
(.clk	(clk  ),
 .rst_n  (rst_n),
 .KERNEL_NUM (KERNEL_NUM),
 .addr_r (addr_bias),// ��cnt_kernel ����	     

 .data_out_valid (1'b1  && clk_enable1),
 
 .data_out  (din_bias1)
);


bias_rom2 #( .DW (DW),  .ROM_NUM_BIAS (ROM_NUM_BIAS),  .ROM_SIZE_BIAS (ROM_SIZE_BIAS2) ,
.ADDR_DW (ADDR_DW),.COLS  (COLS),.ADDR_DW_ROM (ADDR_DW_ROM))
u_bias_rom2
(.clk	(clk ),
 .rst_n  (rst_n),

 .KERNEL_NUM (KERNEL_NUM),
 .addr_r (addr_bias),// ��cnt_kernel ����	      
 

 .data_out_valid (1'b1 && clk_enable2),
 
 .data_out  (din_bias2));


bias_rom3 #( .DW (DW),  .ROM_NUM_BIAS (ROM_NUM_BIAS),  .ROM_SIZE_BIAS (ROM_SIZE_BIAS3) ,
.ADDR_DW (ADDR_DW),.COLS  (COLS),.ADDR_DW_ROM (ADDR_DW_ROM))
u_bias_rom3
(.clk	(clk ),
 .rst_n  (rst_n),

 .KERNEL_NUM (KERNEL_NUM),
 .addr_r (addr_bias),// ��cnt_kernel ����	      
 

 .data_out_valid (1'b1 && clk_enable3),
 
 .data_out  (din_bias3));

bias_rom4 #( .DW (DW),  .ROM_NUM_BIAS (ROM_NUM_BIAS),  .ROM_SIZE_BIAS (ROM_SIZE_BIAS4) ,
.ADDR_DW (ADDR_DW),.COLS  (COLS),.ADDR_DW_ROM (ADDR_DW_ROM))
u_bias_rom4
(.clk	(clk ),
 .rst_n  (rst_n),
 .KERNEL_NUM (KERNEL_NUM),
 .addr_r (addr_bias),// ��cnt_kernel ����	      
 .data_out_valid (1'b1 && clk_enable4),
 .data_out  (din_bias4));


bias_rom5 #( .DW (DW),  .ROM_NUM_BIAS (ROM_NUM_BIAS),  .ROM_SIZE_BIAS (ROM_SIZE_BIAS5) ,
.ADDR_DW (ADDR_DW),.COLS  (COLS),.ADDR_DW_ROM (ADDR_DW_ROM))
u_bias_rom5
(.clk	(clk ),
 .rst_n  (rst_n),
 .KERNEL_NUM (KERNEL_NUM),
 .addr_r (addr_bias),// ��cnt_kernel ����	      
 .data_out_valid (1'b1 && clk_enable5),
 .data_out  (din_bias5));






 CNN_MODULE //���� ����SW_N > ROWS -1
	#( .DW (DW),
	 .ADDR_DW  (ADDR_DW),
	// kernel 84 10 

     .CNT_W  (CNT_W),// ��������λ��

	.ROWS  (ROWS), //SA���е�����
	.COLS   (COLS)//SA���е�����

	
	)
	u_cnn
	( .clk  (clk),
	  .rst_n (rst_n),
	  .mem_initial_sig (host2inMem_flag),
	  .kernel_dim (KERNEL_DIM),
      .kernel_num  (KERNEL_NUM),
	  .stride      (STRIDE),
     	  .layer_index (layer_index),
          .infmap_rows  (INFMAP_ROWS),
	
	  .RA_enable     (RA_enable),
	  .din_inf (din_inf),
	  .fold_rows_cur_o_x (ram_select_x),
	  .fold_rows_cur_o_y (ram_select_y),
	  .addr_inf_x (addr_inf_x), // 0-25
	  .addr_inf_y (addr_inf_y  ),


	  .din_weight (din_weight),
	  .addr_weight (addr_weight), //����ѡ��rom�ж�Ӧ��һ������ ����Ҫ���������Ƭѡ�źţ��ֱ���ѡ����һ��ͨ���Լ�ѡ����һ���۵���
	  .cols_num_cur_o (rom_select),//����ѡ�ж�Ӧ���۵�
	  .cols_num_cur_kernel_element_o (base_addr),
	 
	  .addr_bias (addr_bias),
	  .din_bias (din_bias),
	  .RA_enable_bias (RA_enable_bias),

	   .cnt_ch_o (ch_select), // ����ѡ�ж�Ӧ��ͨ����
	  .output_data (output_data),
	
	  .ch_out	(ch_out_w),
	 . ram_select_out	( ram_select_out_w),
	. addr_out (addr_out_w),
	 
	 .WR_enable_out (WR_enable_out),

	 .addr_out_fc (addr_w_fc)
//	 .predict_index_o (predict_index)
	
	   );

	
	
ram_out #(.DW (DW),.RAM_CH_OUT(RAM_CH_OUT1), .RAM_NUM_OUT (RAM_NUM_OUT1),  .RAM_SIZE_OUT (RAM_SIZE_OUT1),.ADDR_DW (ADDR_DW), .ROWS (ROWS), .COLS(COLS))

u_ram1_out

(.clk	(clk),
 .rst_n (rst_n),
 .STRIDE (STRIDE),
 .KERNEL_DIM (KERNEL_DIM),
 .INFMAP_ROWS (INFMAP_ROWS),
 .ch_select_w	(ch_out_w), //�����ֵΪ0 ��8 ���Ƶ� ����0 ��ѡȡ0-7 ��ͨ��
 .ch_select_r	(ch_select),
 .addr_w	(addr_out_w),// ����д��ַ������Ϊ���������ͼ��������
 .addr_r_x (addr_inf_x),	      // ����Ч�źŽ�����λ�������ƾ�����ڻ�����Ч��
  .addr_r_y (addr_inf_y),	
 .data_in	(output_data),//ÿ����clk ѡ�ж��ͨ�� ÿ��ͨ������һ��ֵ
 .data_out	(din_inf_out),//ÿһ��cycles ѡ��8��ͨ��ÿ��ѡȡһ��������
 .RAenable	(RA_enable && read_enable_out1),//����Ч
 .WRenable	(WR_enable_out && write_enable_out1),//д��Ч
       // ȷ��һ��������е�����
  .ram_select_r_x (ram_select_x), //���������ļ���ram �� ��Ч
  .ram_select_r_y (ram_select_y), 

 .ram_select_w	(ram_select_out_w)) ; 



ram_out #(.DW (DW),.RAM_CH_OUT(RAM_CH_OUT2), .RAM_NUM_OUT (RAM_NUM_OUT2),  .RAM_SIZE_OUT (RAM_SIZE_OUT2),.ADDR_DW (ADDR_DW), .ROWS (ROWS), .COLS(COLS))

u_ram2_out

(.clk	(clk),
 .rst_n (rst_n),
 .STRIDE (STRIDE),
 .KERNEL_DIM (KERNEL_DIM),
 .INFMAP_ROWS (INFMAP_ROWS),
 .ch_select_w	(ch_out_w), //�����ֵΪ0 ��8 ���Ƶ� ����0 ��ѡȡ0-7 ��ͨ��
 .ch_select_r	(ch_select),
 .addr_w	(addr_out_w),// ����д��ַ������Ϊ���������ͼ��������
 .addr_r_x (addr_inf_x),	      // ����Ч�źŽ�����λ�������ƾ�����ڻ�����Ч��
  .addr_r_y (addr_inf_y),	
 .data_in	(output_data),//ÿ����clk ѡ�ж��ͨ�� ÿ��ͨ������һ��ֵ
 .data_out	(din_inf_out2),//ÿһ��cycles ѡ��8��ͨ��ÿ��ѡȡһ��������
 .RAenable	(RA_enable && read_enable_out2),//����Ч
 .WRenable	(WR_enable_out && write_enable_out2),//д��Ч
       // ȷ��һ��������е�����
  .ram_select_r_x (ram_select_x), //���������ļ���ram �� ��Ч
  .ram_select_r_y (ram_select_y), 

 .ram_select_w	(ram_select_out_w)) ; 


	 
fc_ram #( .DW(DW) , .RAM_NUM(RAM_NUM_FC1) , .RAM_SIZE (RAM_SIZE_FC1), .ADDR_DW(ADDR_DW)) 
u_fc_ram1
	(
		.clk (clk),
		.rst_n (rst_n),
		.WR_enable (WR_enable_out && write_enable_fc1 ),
		.RA_enable (RA_enable && read_enable_fc1),
		.addr_w (addr_w_fc),
		.in_data (output_data),
		.ram_select (addr_inf_y),
		.addr_r (addr_inf_x),
		.out_data (out_data_fc1)
		

	);


fc_ram #( .DW(DW) , .RAM_NUM(RAM_NUM_FC2) , .RAM_SIZE (RAM_SIZE_FC2), .ADDR_DW(ADDR_DW)) 
u_fc_ram2
	(
		.clk (clk),
		.rst_n (rst_n),
		.WR_enable (WR_enable_out && write_enable_fc2 ),
		.RA_enable (RA_enable && read_enable_fc2),
		.addr_w (addr_w_fc),
		.in_data (output_data),
		.ram_select (addr_inf_y),
		.addr_r (addr_inf_x),
		.out_data (out_data_fc2)
		

	);


	


	
endmodule
