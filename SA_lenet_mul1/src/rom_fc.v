

module rom_fc #(
    parameter DW = 8,          // ���ݿ��
          // ����
    parameter ADDR_DW =5,     // ��ַ���
    parameter ROM_SIZE = 32  // �ڴ�����
   
) (
    input clk,                 // ʱ���ź�
               // дʹ���ź�
    input RAenable,            // ��ʹ���ź�
    input initial_sig,         // ��ʼ���ź�
   
    input [ADDR_DW-1:0] addr,    // ��ַ����
    input [31:0] para,
         // ������������
     // д����ź�
    output reg [DW-1:0] dout, // �����������
    output reg mem_initial_signal
);

    // ����洢��������
    reg signed [DW-1:0] mem [ROM_SIZE-1:0];

    integer i, j;

    // ʱ��������ʱ���ж�д����
    always @(posedge clk) begin
        if (initial_sig == 1'b1) begin
           	mem_initial_signal <=1'b1;
		for (i=0;i <=ROM_SIZE-1; i =i+1) begin
	
					if(i%2==0) begin	
						mem[i] <=  (((i)%25+para + 1+i/400) % 4);
					end
					else begin
						mem[i] <=-((2*((i)%25)+para+ 1+i/400) % 4);
					end
	
		end

        end 
	
	else begin
	   	  mem_initial_signal <=1'b0;
		// û��һ��дͨ������
		if(RAenable == 1'b1) begin
                    	dout<=   mem[addr];
		end
		else begin
			dout <= 'd0;
		end
			
       		 
   	end
   end

	
endmodule