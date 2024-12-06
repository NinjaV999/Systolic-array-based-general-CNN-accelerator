

module SA_OS # ( parameter DW=8 , parameter CNT_W=5, parameter ROWS = 3, parameter COLS = 3) (
	input clk,
	input rst_n,
	input en,
	input data_enable,
	input data_en_PE,
	input [DW*ROWS-1:0] in_data,
	input [DW*COLS-1 :0] in_weight,
	input [8:0] KERNEL_ELEMENT,
	output [2*DW*COLS-1:0] out_data, 
	output out_flag); 

wire [DW-1:0] din_data_r [ROWS-1:0] ;
wire [DW-1:0] din_weight_r [COLS-1:0];


reg [DW-1:0] in_data_temp1;
reg [DW*2-1:0] in_data_temp2;
reg [DW*3-1:0] in_data_temp3;
/*reg [DW*4-1:0] in_data_temp4;
reg [DW+*5-1:0] in_data_temp5;
reg [DW*6-1:0] in_data_temp6;
reg [DW*7-1:0] in_data_temp7;*/


reg [DW:0] in_weight_temp1;
reg [DW*2-1:0] in_weight_temp2;
reg [DW*3-1:0] in_weight_temp3;
/*reg [DW*4-1:0] in_weight_temp4;
reg [DW*5-1:0] in_weight_temp5;
reg [DW*6-1:0] in_weight_temp6;
reg [DW*7-1:0] in_weight_temp7;*/

            
 genvar m1;
 genvar n1;
    generate
        for (m1= 0; m1< ROWS; m1= m1+ 1) begin : gen_rows
	    assign din_data_r[m1] = in_data[m1*DW+:DW];
	    
	
        end

	 for (n1= 0; n1< COLS; n1= n1 + 1) begin : gen_cols
            assign din_weight_r[n1] = in_weight[n1*DW+:DW];
	    
	
        end
    endgenerate

reg [DW-1:0] in_data_r [ROWS-1:0] ;
reg [DW-1:0] in_weight_r [COLS-1:0];


reg [ROWS-1:0] en_PE_r ;
wire [DW-1:0] out_in_temp [ROWS-1:0] [COLS-1:0];
wire [DW-1:0] out_weight_temp [ROWS-1:0] [COLS-1:0];
//finish flag recomands when the pe get the final result ,if finish_Flag =1 the means output the calculate results
wire  finish_flag_temp [ROWS-1:0] [COLS-1:0];
wire [2*DW-1:0] out_data_temp [ROWS-1:0] [COLS-1:0];
wire en_PE_pre[ROWS-1:0][COLS-1:0];

reg  [COLS-1:0] en_cols;

reg [ROWS-1:0] sel_temp [COLS-1:0];

assign out_flag = finish_flag_temp[0][0];


always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		in_data_temp1<=0;
 		in_data_temp2<=0;
 		in_data_temp3<=0;
		/*in_data_temp4<=0;
		in_data_temp5<=0;
 		in_data_temp6<=0;
 		in_data_temp7<=0;*/

		in_weight_temp1<=0;
 		in_weight_temp2<=0;
 		in_weight_temp3<=0;
		/*in_weight_temp4<=0;
		in_weight_temp5<=0;
 		in_weight_temp6<=0;
 		in_weight_temp7<=0;*/
	end
	else if(data_enable == 1'b1) begin
		in_data_temp1 <=din_data_r[1];
		in_data_temp2 <={din_data_r[2],in_data_temp2[(DW)*2-1:DW] };
		in_data_temp3 <={din_data_r[3],in_data_temp3[(DW)*3-1:DW]};
		/*in_data_temp4 <={in_data_temp[4] [DW:0],in_data_temp4[(DW)*4-1:DW]};
		in_data_temp5 <={in_data_temp[5] [DW:0],in_data_temp5[(DW)*5-1:DW]};
		in_data_temp6 <={in_data_temp[6] [DW:0],in_data_temp6[(DW)*6-1:DW]};
		in_data_temp7 <={in_data_temp[7] [DW:0],in_data_temp7[(DW)*7-1:DW]};*/

		in_weight_temp1 <=din_weight_r[1];
		in_weight_temp2 <={din_weight_r[2],in_weight_temp2[(DW)*2-1:DW] };
		in_weight_temp3 <={din_weight_r[3],in_weight_temp3[(DW)*3-1:DW]};
		/*in_weight_temp4 <={in_weight_temp[4] [DW:0],in_weight_temp4[(DW)*4-1:DW]};
		in_weight_temp5 <={in_weight_temp[5] [DW:0],in_weight_temp5[(DW)*5-1:DW]};
		in_weight_temp6 <={in_weight_temp[6] [DW:0],in_weight_temp6[(DW)*6-1:DW]};
		in_weight_temp7 <={in_weight_temp[7] [DW:0],in_weight_temp7[(DW)*7-1:DW]};*/
	end
//15 14 13 12 11 10 9 8 7 6 5 4 3 2 1 0 =16 -9= 7
//
	else begin
		in_data_temp1<=0;
		in_data_temp2<=0;
 		in_data_temp3<=0;
		/*in_data_temp4<=0;
		in_data_temp5<=0;
 		in_data_temp6<=0;
 		in_data_temp7<=0;*/

		in_weight_temp1<=0;
 		in_weight_temp2<=0;
 		in_weight_temp3<=0;
		/*in_weight_temp4<=0;
		in_weight_temp5<=0;
 		in_weight_temp6<=0;
 		in_weight_temp7<=0;*/
	end

//没必要在这里添加寄存器进行一次额外寄存，我直接输入到sa中就行了，理论上
end




//unrrolled input feature
integer k;
integer k1;

integer a ;
integer b;






// 由于
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		en_PE_r <=0;
		
	end
	else begin
		if(en==1'b1) begin
			
			en_PE_r[0] <= data_en_PE;

			for ( k=1; k <ROWS; k= k+1)  begin
				
				en_PE_r [k] <= en_PE_r[k-1];
					
			end
		end
		else  begin
			en_PE_r <=0;
		end
	end
end
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		
		for ( k=0; k <ROWS; k= k+1)  begin
				
			in_data_r[k] <= 0;
					
		end 

		for ( k1=0; k1 <COLS; k1= k1+1)  begin
				 
			in_weight_r[k1] <= 0;
					
		end 
		
	end
	
	else begin
		if(en==1'b1&& data_enable == 1'b1) begin
			in_data_r[0] <= din_data_r[0];
			in_data_r[1] <= in_data_temp1[DW-1:0];
			in_data_r[2] <= in_data_temp2[DW-1:0];
			in_data_r[3] <= in_data_temp3[DW-1:0];
			/*in_data_r[4] <= in_data_temp4[DW-1:0];
			in_data_r[5] <= in_data_temp5[DW-1:0];
			in_data_r[6] <= in_data_temp6[DW-1:0];
			in_data_r[7] <= in_data_temp7[DW-1:0];*/


			in_weight_r[0] <= din_weight_r[0];
			in_weight_r[1] <= in_weight_temp1[DW-1:0];
			in_weight_r[2] <= in_weight_temp2[DW-1:0];
			in_weight_r[3] <= in_weight_temp3[DW-1:0];
			/*in_weight_r[4] <= in_weight_temp4[DW:0];
			in_weight_r[5] <= in_weight_temp5[DW:0];
			in_weight_r[6] <= in_weight_temp6[DW:0];
			in_weight_r[7] <= in_weight_temp7[DW:0];*/
		end
	
		
		else  begin
			
			
			
			for ( k=0; k <ROWS; k= k+1)  begin
				
				in_data_r[k] <= 0;
					
			end 

			for ( k1=0; k1 <COLS; k1= k1+1)  begin
				 
				in_weight_r[k1] <= 0;
					
			end 
			
		end
		
	end
end
		
		
	


always @(posedge clk or negedge rst_n) begin
	if ( !rst_n) begin
		for ( a=0 ; a<COLS; a=a+1) begin
			
			sel_temp[a] <=0;
		end
			
		
	end
	else begin
		 for ( a=0 ; a<COLS; a=a+1) begin
			
			if (en_cols[a]== 1'b1) begin
				sel_temp[a]<= {{sel_temp[a][ROWS-2:0]}, {1'b1}} ;
			end
			else begin
				sel_temp[a] <= 0;
			end
		end
	end
end


reg [COLS-1:0] finish_flag_lastROW_r;
always @(posedge clk or negedge rst_n) begin

	if ( !rst_n) begin
		
			
			finish_flag_lastROW_r <=0;
			
		
	end
	else begin
		if (en==1'b1) begin
			for(b=0;b<COLS;b=b+1) begin
			
				finish_flag_lastROW_r[b] <=finish_flag_temp[ROWS-1][b];
			end
			
		end
		
		
		else begin
			finish_flag_lastROW_r <=0;
		end
	end
end


	
always @(posedge clk or negedge rst_n) begin
	if ( !rst_n) begin
		
		en_cols <=0;
				
	end

	else begin
		if (en==1'b1) begin

			for ( b=0 ; b<COLS; b=b+1) begin
				
				if (finish_flag_temp[0][b]== 1'b1) begin
					en_cols[b]<=1'b1 ;
					 
				end
				else if(finish_flag_lastROW_r[b] == 1'b1) begin

					en_cols[b]<=0;
					
				end
			
			end
		end

		else begin
			
			en_cols<=0 ;
			
			
		end
	end
end




genvar m , n;
generate
	for (m=0;m<ROWS;m=m+1) begin : SA_gen_rows
		 for (n=0;n < COLS; n=n+1) begin: SA_gen_cols
			if(m == 0 && n == 0) begin
				PE #(.DW(DW),  .CNT_W(CNT_W)) u_PE_cor (
							.clk	(clk),
							.rst_n	(rst_n),
							.sel 	(sel_temp[n][m]),      //the first row always select 1'b0, inorder to output psum							.in_data ( in_data_r[m]),
							.en_PE	(en_PE_r[m]),
							.en_synch  (en),
							.KERNEL_ELEMENT (KERNEL_ELEMENT ),
							.in_data    (in_data_r[m]),
							.in_weight (in_weight_r[n]),
							.in_pre    (0), 
							.out_data  (out_data_temp[m][n]),
							.out_in   (out_in_temp[m][n]),
							.out_weight(out_weight_temp[m][n]),
							.finish_flag (finish_flag_temp[m][n]),
							.en_PE_pre	( en_PE_pre[m][n])	);
			end

			else if ( m==0 && n !=0) begin 
				PE #(.DW(DW),  .CNT_W(CNT_W)) u_PE_row0 (
							.clk	(clk),
							.rst_n	(rst_n),
							.sel 	(sel_temp[n][m]),
							.en_PE	(en_PE_pre[m][n-1]),
							.en_synch  (en),
							.KERNEL_ELEMENT (KERNEL_ELEMENT ),
							.in_data (out_in_temp[m][n-1]), 
							.in_weight (in_weight_r[n]),
							.in_pre    (0),
							.out_data  (out_data_temp[m][n]),
							.out_in   (out_in_temp[m][n]),
							.out_weight(out_weight_temp[m][n]),
							. finish_flag (finish_flag_temp[m][n]),
							.en_PE_pre	( en_PE_pre[m][n]));
			end

			else if ( n==0 && m !=0 ) begin //???PE
				PE #(.DW(DW),  .CNT_W(CNT_W)) u_PE_col0 (
							.clk	(clk),
							.rst_n	(rst_n),
							.sel 	(sel_temp[n][m]),
							.en_PE	(en_PE_r[m]),
							.en_synch  (en),
							.KERNEL_ELEMENT (KERNEL_ELEMENT ),
							.in_data (in_data_r[m]),  
							.in_weight (out_weight_temp[m-1][n]),
							.in_pre    (out_data_temp[m-1][n]),
							.out_data  (out_data_temp[m][n]),
							.out_in   (out_in_temp[m][n]),
							.out_weight(out_weight_temp[m][n]),
							. finish_flag (finish_flag_temp[m][n]),
							.en_PE_pre	( en_PE_pre[m][n]));

			end
			else begin

				PE #(.DW(DW),  .CNT_W(CNT_W)) u_PE (
							.clk	(clk),
							.rst_n	(rst_n),
							.sel 	(sel_temp[n][m]),
							.en_PE	(en_PE_pre[m][n-1]),
							.en_synch  (en),
							.KERNEL_ELEMENT (KERNEL_ELEMENT ),
							.in_data (out_in_temp[m][n-1]),  
							.in_weight (out_weight_temp[m-1][n]), 
							.in_pre    (out_data_temp[m-1][n]),
							.out_data  (out_data_temp[m][n]),
							.out_in   (out_in_temp[m][n]),
							.out_weight(out_weight_temp[m][n]),
							. finish_flag (finish_flag_temp[m][n]),	
							.en_PE_pre	( en_PE_pre[m][n]));
			end
		end
	end
endgenerate


genvar c;
generate 
	for (c=0;c<COLS;c=c+1) begin : gen_output
		
			assign out_data[c*(2*DW)+2*DW-1:c*(2*DW)] = out_data_temp[ROWS-1][c];
			//输出每一列的最后一行结果
	end
endgenerate 


endmodule 
