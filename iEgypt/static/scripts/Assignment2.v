module Assignment2(out0, out1, reset_btn, hold_btn, Clk);
  // Declaring output
  output [6:0] out0;// first unit
  output [6:0] out1;// second unit
  reg[6:0] out0;
  reg[6:0] out1;

  // Declaring input
  input reset_btn, hold_btn, Clk;// 50MHz

  // Declaring counting variables
  reg[4:0] count0;
  reg[4:0] count1;

  // Declaring hold variable
  reg[1:0] hold;
  /*
  00 -> hold up and not holding
	01 -> hold up and holding
	10 -> hold down and not holding
	11 -> hold down and holding
  */

  //Accumulator for slow clock generation also the wire for the clock itself
  reg [23:0] accum = 0;
  wire slow_Clk = (accum == 0);

  //Initializing values for registers
  initial begin
    hold = 0;
	 count0 = 10;
	 count1 = 10;
  end

  //Dealing with button presses, counting and display
  always @ (posedge Clk) begin
    if(reset_btn == 0) begin // Reset button down
      count0 = 0;
      count1 = 0;
		  accum = 1;
    end
    else begin// Reset button up
      if(hold_btn == 0) begin// Hold button down
		    if(hold == 2'b00)// Hold is off
		      hold = 2'b11;// Hold is on
		    if(hold == 2'b01)// Hold is on
		      hold = 2'b10;// Hold is off
		  end
		  else begin// Hold button up
        if(hold == 2'b10)// Hold is off
		      hold = 2'b00;// Hold is off
		    if(hold == 2'b11)// Hold is on
		      hold = 2'b01;// Hold is on
		  end
	 end

	 if(hold == 00) begin// Hold is off
     //Generating slow_Clk
     accum = (accum == 12500000)? 0:accum+1;// 4Hz clock
	   if(slow_Clk) begin// Slow clock is at 0
	     count1 = (count0 >= 9)? ((count1 >= 9)? 0 : (count1 + 1)) : count1;
       count0 = (count0 >= 9)? 0 : count0 + 1;
		end
  end

    case(count0)// Displaying the count for the right segment
      1:out0=7'b1111001;
      2:out0=7'b0100100;
      3:out0=7'b0110000;
      4:out0=7'b0011001;
      5:out0=7'b0010010;
      6:out0=7'b0000010;
      7:out0=7'b1111000;
      8:out0=7'b0000000;
      9:out0=7'b0011000;
      default:out0=7'b1000000;
    endcase

    case(count1)// Displaying the count for the right segment
      1:out1=7'b1111001;
      2:out1=7'b0100100;
      3:out1=7'b0110000;
      4:out1=7'b0011001;
      5:out1=7'b0010010;
      6:out1=7'b0000010;
      7:out1=7'b1111000;
      8:out1=7'b0000000;
      9:out1=7'b0011000;
      default:out1=7'b1000000;
    endcase
  end
endmodule
