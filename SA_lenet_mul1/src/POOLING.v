
	

module  POOLING #(parameter DW=8
		  		   )//一个窗口得到的是一个像素点
	(
	input clk,
	input rst_n,
	input  mode, //用来确定是是最大池化还是平均池化
	input en,
	input input_flag,
	input [2:0] POOLING_KERNEL_DIM2,
	
	input  signed [2*DW-1:0] data_in,
	output reg output_flag,
	output [2*DW-1:0] data_out);
	
	localparam AVG_POOLING = 1'b0;
	localparam MAX_POOLING = 1'b1;
//输出特征图的像素数就是进行处理的窗口数，每一个要处理窗口的元素个数就是POOLING KERNEL DIM
	reg [3:0] cnt ;
	reg signed [2*DW-1:0] temp0;
	assign data_out = temp0;


	always@(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			cnt<='d0;
		end
		else begin
			if(cnt == POOLING_KERNEL_DIM2-1 && input_flag == 1'b1) begin
				cnt<='d0;
			end
			else if(input_flag == 1'b1) begin
				cnt <=cnt+1'b1;
			end
		end
	end
				
	
	
		
	always@(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			
				temp0 <=0;
		end
			
		else begin
			if(en==1'b1) begin
				
					if(input_flag ==1'b1) begin
					
						if(cnt==0) begin
							temp0<=data_in;
							
						end
						else begin
							
							if(data_in > temp0) begin
								temp0<=data_in;
							end
							else begin
								temp0<=temp0;
							end
						end
					
					end
					else begin
						temp0<=0;
					end
				
				
				
			end
			else begin
			 	
				temp0<=0;
				
			end	
		end
	end
	

	always@(posedge clk or negedge rst_n) begin
		if(!rst_n)begin

			output_flag<=0;
			
		end
		else begin
			if(en==1'b1) begin
				if(cnt==POOLING_KERNEL_DIM2-1 && input_flag ==1'b1) begin
					output_flag<=1'b1;
					
				end
				else begin
					output_flag<=1'b0;
					
				end
			end
			else begin
				output_flag<=1'b0;
				
			end
		end
	end

	
	
endmodule

			
			
	