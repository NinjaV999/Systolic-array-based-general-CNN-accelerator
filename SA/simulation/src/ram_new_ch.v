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
 input [ADDR_DW-1:0] ram_select_r_x, //���������ļ���ram �� ��Ч
 input [ADDR_DW-1:0] ram_select_r_y,

 input [7:0] addr_r_x,	      // ����Ч�źŽ�����λ�������ƾ�����ڻ�����Ч��
 input [3:0] addr_r_y,	
 input [ADDR_DW-1:0] addr_w,

 input [DW-1:0] data_in,  //�����Ļ�����ÿ��ͨ��ÿ��ֻ����һ��������
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


//��
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)begin
		rd_en_r<='d0;
		addr_r_x_r <='d0;
		ram_select_r_x_r <='d0;
	end
	else begin
		rd_en_r<=rd_en;
		addr_r_x_r <= addr_r_x; //����������з����ƫ�Ƶ�ַ
		ram_select_r_x_r <= ram_select_r_x; //������ڵĻ���ַ
	end
end

 
  always@(*) begin
          for(i=0;i<=RAM_NUM_OUT-1;i=i+1) begin
                	rd_en[i] =1'b0;
		end
        for(i=0;i<=RAM_NUM_OUT-1;i=i+1) begin
                	
           	 	if(i*STRIDE>=ram_select_r_x && i*STRIDE<STRIDE*ROWS+ram_select_r_x && i*STRIDE <INFMAP_ROWS-KERNEL_DIM) begin //32-5 =27��
//�ڶ�fc��ʱ����ʼ�ձ�֤INFMAP-kernel dim =0������i��ֻ��ȡ0�������������ǣ�addr_r_x
                		rd_en[i*STRIDE+addr_r_x] = ch_enable_r;
         	  	 end
            
           	 	else begin
               		 	rd_en[i*STRIDE+addr_r_x] =1'b0;
            	 	end
	   	
	end
  
        addr_r = addr_r_y+ram_select_r_y; //��fc��ʱ����Ϊ��rows�ϲ��۵�ram_select_r_yҲΪ0
    end
		
		
    

	always@(*)begin // ��׼ + ��ͬ������+ƫ��
		for(j=ROWS-1; j>=0; j = j-1) begin
			//ȷ�����������磬����fc ����ǲ��ùܵģ����Ǹ���re_en �Ƿ�Ϊ1��������ƴ��
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
     .DW (DW),          // ���ݿ��
          // ����
     .ADDR_DW  (ADDR_DW),     // ��ַ���
     .RAM_SIZE  (RAM_SIZE_OUT)  // �ڴ�����
   
) 

u_ram_new(
     .clk	 (clk),                 // ʱ���ź�
               // дʹ���ź�
    .WRenable	(wr_en[m]),            // ��ʹ���ź�
    .RAenable	(rd_en[m]),
             // ��ʼ���ź�
    .din        (din[m]),
    .addr_w     (addr_w),    // ��ַ����
    .addr_r	(addr_r),
   
         // ������������
     // д����ź�
     .dout        (dout[m]) // �����������
  
);

end
	

	
endgenerate
endmodule
/*

����ram_out ģ��
1.������ ÿ���Ƕ�ȡrows��Ԫ�أ� ��ÿ�ζ�ȡrows��������ڵ�1��Ԫ��
2.����д����һ��дcols��Ԫ�أ���ÿ��дcols�����ͨ����һ��Ԫ��
3.Ҫ�����ö�дfc layer����������ʱ��Ӧ����ÿ�ζ�ȡ1��Ԫ�أ�����Ԫ�ؿ���Ϊ0����д��cols��Ԫ�أ����ǲ��ǽ���ЩԪ��д���ĸ�ͨ����������д��һ��ͨ����4����ַ

*/
module ram_out #(parameter DW=8,parameter RAM_CH_OUT=6, parameter RAM_NUM_OUT=32, parameter RAM_SIZE_OUT=32 ,parameter ADDR_DW=5,parameter ROWS = 8,parameter COLS =8)



(input clk,
 input rst_n,
 input [1:0]  STRIDE,
 input [3:0] KERNEL_DIM,
 input [15:0] KERNEL_NUM,
 input  [5:0] INFMAP_ROWS,
 input [3:0] ch_select_w, //�����ֵΪ0 ��8 ���Ƶ� ����0 ��ѡȡ0-7 ��ͨ��
 input [3:0] ch_select_r, //����Ϊʲô���Ӧ��ͨ������Ч
 input [ADDR_DW-1:0] addr_w,// ����д��ַ������Ϊ���������ͼ��������
 input [7:0] addr_r_x,	      // ����Ч�źŽ�����λ�������ƾ�����ڻ�����Ч��
 input [3:0] addr_r_y,
 input [(DW)*COLS-1:0] data_in,//ÿ����clk ѡ�ж��ͨ�� ÿ��ͨ������һ��ֵ
 output[(DW)*ROWS-1:0]data_out,//ÿһ��cycles ѡ��8��ͨ��ÿ��ѡȡһ��������
 input RAenable,//����Ч
 input WRenable,//д��Ч
 input [ADDR_DW-1:0] ram_select_r_x, //���������ļ���ram �� ��Ч
 input [ADDR_DW-1:0] ram_select_r_y,	
 input [ADDR_DW-1:0] ram_select_w) ; //��дһ�¶���ѡȡһ��



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
			if(i==ch_select_r)begin  //ѡ��һ����ͨ��

					ch_en_r[i] = RAenable;
					
			end
			else begin
					ch_en_r[i] = 'd0;
			end
		end


		
		for(i=0;i<=RAM_CH_OUT-1; i= i+1) begin
			if(i>=ch_select_w && i<ch_select_w+COLS && i<=KERNEL_NUM-1)begin //��һ���жϵ��ڱ�ʾiС�ڵ�ǰ�����ͨ����
//����Ϊ�˷�ֹ���������Ϊ�����ά�Ȳ�ͬ������ͨ����֮ǰmem��ͨ�����������ͨ���������mem��ͨ����Զ�����ܳ���
//���ͨ����������ƴ��֮����ܻ���֣�mem��ͨ��������������ǰ����洢�����ͨ������ͻᵼ�´�λ��д���������Ҫ
//дһ���ж�memͨ��������С�����ͨ��
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





		