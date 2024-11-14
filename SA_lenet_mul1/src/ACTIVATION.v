




module ACTIVATION 
 #(parameter DW =32)
		 (
		
		input clk,
		input rst_n,
		input out_flag_pooling,
	
		input [1:0] acti_mode,
		input [3:0] layer_index,
		input  signed [2*DW-1: 0] data_in ,
		output reg [DW-1:0] data_out,
		output reg acti_finish_flag 
			);


	localparam IDLE = 2'b00;
	localparam RELU = 2'b01;
	localparam TANH = 2'b10;
	localparam SIGMOID = 2'b11;


	

	

	integer i;
	integer j;
	wire [13:0] temp;
	assign temp = data_in[13:0];
	reg signed [2*DW-1:0] data_in_temp, data_in_temp2;
	always@(*) begin
	    data_in_temp = (data_in>>>15);
	end
	/*always@(*) begin
	        data_in_temp2 = (data_in>>>15);
	       if(data_in[2*DW-1] == 0) begin
	           if(data_in[14] == 1'b1) begin
	                   data_in_temp = data_in_temp2+1'b1;
	            
	           end
	           else begin
	                   data_in_temp = data_in_temp2;
	           end
	       end
	       //(data_in[13]| data_in[12]| data_in[11]|data_in[10]|data_in[9]|data_in[8]|data_in[7]|data_in[6]|data_in[5]|data_in[4]|data_in[3]|data_in[2]|data_in[1]|data_in[0]) == 1'b1)
	       else begin
	           if(data_in[14] ==1'b1 && (|temp == 1'b1) ) begin   //��ȥ 11.1 11.11 -1.5 �� -1.25
	                   data_in_temp =data_in_temp2+1'b1;
	            end
	            else begin //1.01 -1.75 -2
	                   data_in_temp = data_in_temp2;
	             end
	        
	        end
    end
    */
  

	always@(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			data_out<=0;
			acti_finish_flag<=0;
		end
		else begin
			if(out_flag_pooling == 1'b1) begin
				if(acti_mode == IDLE  || layer_index==5) begin
					
					data_out<=data_in_temp;
					
					acti_finish_flag<=1'b1;
				end
				else if(acti_mode == RELU) begin
					if(data_in_temp[2*DW-1] == 1'b0 )  begin
						
						  data_out <= data_in_temp;
						

					end
					else begin
						data_out<=0;
					end
					
					acti_finish_flag<=1'b1;
				end

			end
			else begin
				data_out<=0;
				acti_finish_flag<=0;


			end
		end
	end

endmodule
				




					


					

