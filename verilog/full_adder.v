`timescale 1ns / 1ps

module full_adder(
   input in0, 
   input in1,
   input cin, 
   output out, 
   output cout
);

	assign out = in0 ^ in1 ^ cin;
	assign cout = ((in0 ^ in1) & cin) | (in0 & in1);
endmodule
