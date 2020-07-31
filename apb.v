module apb(pclk,pwrite,reset,psel,penable,pready,paddr,pwdata,prdata);            
  input pclk;
  input pwrite;
  input reset;
  input psel;  
  input penable;
  input pready;
  input [7:0] paddr;
  input[31:0] pwdata;
  output reg [31:0]prdata;

reg [0:31] memory[0:255];

reg [1:0] state;

parameter  SETUP = 2'b00,  ACCESS = 2'b01;

always @(negedge reset,posedge pclk) begin
  if (reset == 0)
    begin
     state <= 0; 
    end

  else begin
	case (state)
		SETUP : begin
		           prdata <= 0;
        	           if (psel) 
                             begin

        	               if (psel && !penable) 
                                 begin
          		            if(pwrite) 
                                      begin			
         			        memory[paddr] <= pwdata;
       	                                state <= SETUP;
      			              end
			            else 
				      begin
          		  	        state <= ACCESS;
        		              end
			            end
		                 end
        	         end

     		ACCESS : begin
          			prdata <= memory[paddr];
        			state <= SETUP;
     			 end
		default: prdata<=0;//IDLE
        endcase
  end
end 
endmodule


module apb_test;

  reg         pclk;
  reg         reset;
  reg [7:0]   paddr;
  reg         pwrite;
  reg         psel;
  reg         pready;
  reg         penable;
  reg [31:0]  pwdata;
  wire[31:0] prdata;
  wire[0:31] memory[0:255];

 initial begin pclk = 0; forever #4 pclk = ~pclk;  end
 

 apb dut(.*);//

	initial begin 
	pwrite=0;reset=0;paddr=0;psel=0;penable=0;pready=1;pwdata=0;
	@(posedge pclk); reset=1;
	@(posedge pclk); pwrite=1; psel=1;paddr=8'h01;pwdata=32'h12153524;
	@(posedge pclk); penable=1;
	@(posedge pclk); penable=0;
	@(posedge pclk); pwrite=0;
	@(posedge pclk); penable=1;
	@(posedge pclk); penable=0;
	end
	initial begin
	#60 $finish();
	end
endmodule
 

