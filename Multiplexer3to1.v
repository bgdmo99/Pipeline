


module Multiplexer3to1
#(
	parameter NBits=32
)
(
	input [1:0] Selector,
	input [NBits-1:0] MUX_Data0,
	input [NBits-1:0] MUX_Data1,
	input [NBits-1:0] MUX_Data2,

	
	output [NBits-1:0] MUX_Output

);

	assign MUX_Output = (Selector == 2'b00) ? MUX_Data0 : 
							  (Selector == 2'b01) ? MUX_Data1 : 
							  (Selector == 2'b10) ? MUX_Data2 : 0;
								
endmodule