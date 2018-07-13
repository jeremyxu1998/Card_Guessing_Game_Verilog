// This file contains all the picture printing modules to VGA
// The idea is: all the colours are calculated, and use a big mux to choose which colour to send back to display datapath

module background(Clock, ResetN, startPrintBackground, X, Y, Colourout,finish);
	input Clock, ResetN, startPrintBackground;
	output [8:0] Colourout;
	output reg [7:0] X;
	output reg [6:0] Y;
	output reg finish;
	reg start;
	wire [14:0] bg_address;
	
	always @(posedge Clock) begin
		if(!ResetN) begin
			start <= 1'b0;
			X <= 8'b0;
			Y <= 7'b0;
			finish <= 1'b0;
		end
		else if(finish == 1) begin
			finish <= 0;
		end
		else begin
			if(startPrintBackground)
				start <= 1'b1;
			if(start) begin
				X <= X + 1'b1;
				if(X == 159 && Y != 119) begin
					X <= 8'b0;
					Y <= Y + 1'b1;
				end
				if(X == 159 && Y == 119) begin
					start <= 1'b0;
					X <= 8'b0;
					Y <= 7'b0;
					finish <= 1'b1;
				end
			end
		end
	end
	
	assign bg_address = {1'b0, Y*160} + {1'b0, X};

	background_ u0(bg_address, Clock, Colourout);
endmodule

module leftcard(Clock, ResetN, startPrintLeftCard, select, X, Y, Colourout, finish, staticCardNum, selectTest);
	
	input Clock, ResetN, startPrintLeftCard;
	input [3:0] select;
	output reg [8:0] Colourout;
	output reg [7:0] X;
	output reg [6:0] Y;
	output reg finish;
	output [3:0] selectTest;
	reg start, cardSet, staticGetValue;
	output reg [3:0] staticCardNum;
	wire [10:0] the_address;
	wire [8:0]  Colourout1,
					Colourout2,
					Colourout3,
					Colourout4,
					Colourout5,
					Colourout6,
					Colourout7,
					Colourout8,
					Colourout9,
					Colourout10,
					Colourout11,
					Colourout12,
					Colourout13;
	
	assign selectTest = select;
	
	always @(posedge Clock) begin
		if(!ResetN) begin
			start <= 1'b0;
			X <= 8'd18;
			Y <= 7'd37;
			finish <= 1'b0;
		end
		else if(finish == 1) begin
			finish <= 0;
		end
		else begin
			if(startPrintLeftCard)
				start <= 1'b1;
			if(start) begin
				X <= X + 1'b1;
				if(X == 47 && Y != 78) begin
					X <= 8'd18;
					Y <= Y + 1'b1;
				end
				if(X == 47 && Y == 78) begin
					start <= 1'b0;
					X <= 8'd18;
					Y <= 7'd37;
					finish <= 1'b1;
				end
			end
		end
	end
	
//	always@(posedge Clock) begin
//		if(!ResetN) begin
//			cardSet <= 1'b0;
//			staticCardNum <= 4'd10;
//			staticGetValue <= 1'b0;
//		end
//		if(startPrintLeftCard) begin
//			staticGetValue <= 1'b1;
//		end
//		if(!cardSet && staticGetValue) begin
//			staticCardNum <= select;
//			cardSet <= 1'b1;
//		end
//	end
	
	assign the_address = {1'b0, (Y-7'd37)*30} + {1'b0, X-8'd18};
	
	
	one u1(the_address, Clock, Colourout1);
	two u2(the_address, Clock, Colourout2);
	three u3(the_address, Clock, Colourout3);
	four u4(the_address, Clock, Colourout4);
	five u5(the_address, Clock, Colourout5);
	six u6(the_address, Clock, Colourout6);
	seven u7(the_address, Clock, Colourout7);
	eight u8(the_address, Clock, Colourout8);
	nine u9(the_address, Clock, Colourout9);
	ten u10(the_address, Clock, Colourout10);
	eleven u11(the_address, Clock, Colourout11);
	twelve u12(the_address, Clock, Colourout12);
	thirteen u13(the_address, Clock, Colourout13);
	
	
	always@(*)
	begin
		case (select)
			4'b0000: Colourout = Colourout1;
			4'b0001: Colourout = Colourout1;
			4'b0010: Colourout = Colourout2;
			4'b0011: Colourout = Colourout3;
			4'b0100: Colourout = Colourout4;
			4'b0101: Colourout = Colourout5;
			4'b0110: Colourout = Colourout6;
			4'b0111: Colourout = Colourout7;
			4'b1000: Colourout = Colourout8;
			4'b1001: Colourout = Colourout9;
			4'b1010: Colourout = Colourout10;
			4'b1011: Colourout = Colourout11;
			4'b1100: Colourout = Colourout12;
			4'b1101: Colourout = Colourout13;
			4'b1110: Colourout = Colourout12;
			4'b1111: Colourout = Colourout13;
		endcase
	end
endmodule


module  rightcard(Clock, ResetN, startPrintRightCard, flip_right_card, select, X, Y, Colourout, finish);
	input Clock, ResetN, startPrintRightCard, flip_right_card;
	input [3:0] select;
	output reg [8:0] Colourout;
	output reg finish;
	output reg [7:0] X;
	output reg [6:0] Y;
	reg start;
//	wire printback;
	wire [10:0] the_address;
	wire [8:0]	Colourout0,
					Colourout1,
					Colourout2,
					Colourout3,
					Colourout4,
					Colourout5,
					Colourout6,
					Colourout7,
					Colourout8,
					Colourout9,
					Colourout10,
					Colourout11,
					Colourout12,
					Colourout13;
	
	always @(posedge Clock) begin
		if(!ResetN) begin
			start <= 1'b0;
			X <= 8'd57;
			Y <= 7'd39;
			finish <= 1'b0;
		end
		else if(finish == 1) begin
			finish <= 0;
		end
		else begin
			if(startPrintRightCard)
				start <= 1'b1;
			if(start) begin
				X <= X + 1'b1;
				if(X == 86 && Y != 78) begin
					X <= 8'd57;
					Y <= Y + 1'b1;
				end
				if(X == 85 && Y == 77) begin
					start <= 1'b0;
					X <= 8'd57;
					Y <= 7'd37;
					finish <= 1'b1;
				end
			end
		end
	end
	
	assign the_address = {1'b0, (Y-7'd36)*30} + {1'b0, (X-8'd56)};
//	assign printback = flip_right_card;
	
	back u0(the_address, Clock, Colourout0);
	one u1(the_address, Clock, Colourout1);
	two u2(the_address, Clock, Colourout2);
	three u3(the_address, Clock, Colourout3);
	four u4(the_address, Clock, Colourout4);
	five u5(the_address, Clock, Colourout5);
	six u6(the_address, Clock, Colourout6);
	seven u7(the_address, Clock, Colourout7);
	eight u8(the_address, Clock, Colourout8);
	nine u9(the_address, Clock, Colourout9);
	ten u10(the_address, Clock, Colourout10);
	eleven u11(the_address, Clock, Colourout11);
	twelve u12(the_address, Clock, Colourout12);
	thirteen u13(the_address, Clock, Colourout13);
	
	
	always@(*) begin
		if (!flip_right_card)
			Colourout = Colourout0;
		else begin
			case (select)
				4'b0000: Colourout = Colourout1;
				4'b0001: Colourout = Colourout1;
				4'b0010: Colourout = Colourout2;
				4'b0011: Colourout = Colourout3;
				4'b0100: Colourout = Colourout4;
				4'b0101: Colourout = Colourout5;
				4'b0110: Colourout = Colourout6;
				4'b0111: Colourout = Colourout7;
				4'b1000: Colourout = Colourout8;
				4'b1001: Colourout = Colourout9;
				4'b1010: Colourout = Colourout10;
				4'b1011: Colourout = Colourout11;
				4'b1100: Colourout = Colourout12;
				4'b1101: Colourout = Colourout13;
				4'b1110: Colourout = Colourout12;
				4'b1111: Colourout = Colourout13;
			endcase
		end
	end
	
endmodule



module button(Clock, ResetN, startPrintKey, printhigh, X, Y, Colourout, finish);
	input Clock, ResetN, startPrintKey, printhigh;
	output reg [8:0] Colourout;
	output reg [7:0] X;
	output reg [6:0] Y;
	output reg finish;
	reg start;
	wire [11:0] switch_address;
					
	wire [8:0] w1, w2;
	//YES_HIGH
	always @(posedge Clock) begin
		if(!ResetN) begin
			start <= 1'b0;
			X <= 8'd110;
			Y <= 7'd35;
			finish <= 1'b0;
		end
		else if(finish == 1) begin
			finish <= 0;
		end
		else begin
			if(startPrintKey)
				start <= 1'b1;
			if(start) begin
				X <= X + 1'b1;
				if(X == 156 && Y != 89) begin
					X <= 8'd110;
					Y <= Y + 1'b1;
				end
				if(X == 156 && Y == 89) begin
					start <= 1'b0;
					X <= 8'd110;
					Y <= 8'd35;
					finish <= 1'b1;
				end
			end
		end
	end
	
	assign switch_address = {1'b0, (Y-8'd35)*47} + {1'b0, X-8'd110};
	
	yes_no f0(switch_address, Clock, w2);
	high_low f1(switch_address, Clock, w1);
	
	always@(*)
	begin
		if(printhigh) 
			Colourout <= w1;
		else 
			Colourout <= w2;
	end
	
endmodule

module label(Clock, ResetN, startPrintLabel, stage, X, Y, Colourout, finish,stage_inside);
	input Clock, ResetN, startPrintLabel;
	input stage;
	output reg [8:0] Colourout;
	output reg [7:0] X;
	output reg [6:0] Y;
	output reg finish;
	reg [28:0] Q;
	reg print_finish, start;
	wire [9:0] label_address;
	wire [8:0] wire1, wire2;
	output stage_inside;
	assign stage_inside = stage;
			
	
	always @(posedge Clock) begin
		if(!ResetN) begin
			start <= 1'b0;
			X <= 8'd14;
			Y <= 8'd10;
			finish <= 1'b0;
			Q <= 'h5f5e100;
			print_finish<= 1'b0;
		end
		else if(finish == 1'b1) begin
			finish <= 1'b0;
			print_finish <= 1'b0;
		end
		else if(print_finish)begin
			if (Q == 28'b0) begin
				Q <= 'h5f5e100;
				finish <= 1'b1;
				end
			else begin
				Q <= Q - 1;
			end
		end
		else begin
			if(startPrintLabel)
				start <= 1'b1;
			if(start) begin
				X <= X + 1'b1;
				if(X == 92 && Y != 17) begin
					X <= 8'd14;
					Y <= Y + 1'b1;
				end
				if(X == 92 && Y == 17) begin
					start <= 1'b0;
					X <= 8'd14;
					Y <= 8'd10;
					print_finish <= 1'b1;
				end
			end
		end
		
		
	end
	assign label_address = {1'b0, (Y-8'd10)*79} + {1'b0, X-8'd14};
	
	youwin u0(label_address, Clock, wire1);
	youlose u1(label_address, Clock, wire2);

	always@(*)
	begin
		case (stage)
			1'b1: Colourout = wire1;
			1'b0: Colourout = wire2;
		endcase
	end
endmodule




module  card_animation(Clock, ResetN, startFlipLeftCard, X, Y, Colourout, finish_animation);
	
	input Clock, ResetN, startFlipLeftCard;
	//input [1:0] select;
	output reg [8:0] Colourout;
	output reg [7:0] X;
	output reg [6:0] Y;
	output reg  finish_animation;//finish,
	reg  cardSet, staticGetValue;
	
	wire [10:0] the_address;
	wire [8:0]  Colourout1,//25
					Colourout2,//50
					Colourout3;//75
	reg [27:0] Q;
	reg [1:0] flip_angle;
	
	reg print_card; 
	reg start;
	
	
	always @(posedge Clock) begin
		if(!ResetN) begin
			X <= 8'd57;
			Y <= 7'd39;
			flip_angle <= 2'b00;
			print_card <= 1'b0;
			Q <= 'hbebc20;
			finish_animation <= 1'b10;
		end
		else if(finish_animation == 1) begin
			finish_animation <= 0;
		end
		else begin
			if(startFlipLeftCard && Q== 28'b0 && flip_angle != 2'b11) begin
				flip_angle <= flip_angle + 1;
				print_card <= 1'b1;
			end
			else if(startFlipLeftCard && Q== 28'b0 && flip_angle == 2'b11) begin
				flip_angle <= 2'b00;
				print_card <= 1'b0;
				finish_animation <=1'b1;
			end
			if(print_card) begin
				X <= X + 1'b1;
				if(X == 85 && Y != 78) begin
					X <= 8'd57;
					Y <= Y + 1'b1;
				end
				if(X == 85 && Y == 78) begin
					start <= 1'b0;
					X <= 8'd57;
					Y <= 7'd39;
					print_card <= 1'b0;
				end
			end
			else if(!print_card)begin
				if (Q == 28'b0)
					Q <= 'hbebc20;
				else
					Q <= Q - 1;
			end
		end
	end
	
	
	assign the_address = {1'b0, (Y-7'd36)*30} + {1'b0, X-8'd56};
	
	
	right_25 u1(the_address, Clock, Colourout1);
	right_50 u2(the_address, Clock, Colourout2);
	right_75 u3(the_address, Clock, Colourout3);
	
	
	always@(*)
	begin
		case (flip_angle)
			2'b01: Colourout = Colourout1;
			2'b10: Colourout = Colourout2;
			2'b11: Colourout = Colourout3;
		endcase
	end
	
	
endmodule


module chip_select(Clock, ResetN, startPrintChip,chip_num, X, Y, Colourout, finish);
	input Clock, ResetN, startPrintChip;
	input [2:0] chip_num;
	output reg [8:0] Colourout;
	output reg [7:0] X;
	output reg [6:0] Y;
	output reg finish;
	reg start;
	wire [14:0] bg_address;
	wire [8:0] Colourout0,//before choose
				  Colourout1,//5 chip
				  Colourout2,//10 chip
				  Colourout3;// 20chip
				  
	always @(posedge Clock) begin
		if(!ResetN) begin
			start <= 1'b0;
			X <= 8'b0;
			Y <= 7'b0;
			finish <= 1'b0;
		end
		else if(finish == 1) begin
			finish <= 0;
		end
		else begin
			if(startPrintChip)
				start <= 1'b1;
			if(start) begin
				X <= X + 1'b1;
				if(X == 159 && Y != 119) begin
					X <= 8'b0;
					Y <= Y + 1'b1;
				end
				if(X == 159 && Y == 119) begin
					start <= 1'b0;
					X <= 8'b0;
					Y <= 7'b0;
					finish <= 1'b1;
				end
			end
		end
	end
	
	assign bg_address = {1'b0, Y*160} + {1'b0, X};
	
	chip0 u0(bg_address, Clock, Colourout0);
	chip5 u1(bg_address, Clock, Colourout1);
	chip10 u2(bg_address, Clock, Colourout2);
	chip20 u3(bg_address, Clock, Colourout3);
	
	always@(*)
	begin
		case (chip_num)
			2'b00: Colourout = Colourout0;
			2'b01: Colourout = Colourout1;
			2'b10: Colourout = Colourout2;
			2'b11: Colourout = Colourout3;
		endcase
	end
	
endmodule



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//module label(Clock, ResetN, startPrintLabel, stage, X, Y, Colourout, finish);
//	input Clock, ResetN, startPrintLabel;
//	input [1:0]stage;
//	output reg [8:0] Colourout;
//	output reg [7:0] X;
//	output reg [6:0] Y;
//	output reg finish, internal_finish;
//	reg start;
//	wire [9:0] label_address;
//	wire [8:0] wire1, wire2, wire3;
//	
//	reg [1:0] count;
//	
//	reg [27:0] Q;
//	reg [1:0] select;
//	
//	always @(posedge Clock) begin
//		if (Q == 28'b0 && internal_finish) begin
//			Q <= 'hbebc1ff;
//			finish <= 1'b1;
//			internal_finish <= 1'b0;
//		end
//		else if(internal_finish)
//			Q <= Q - 1;
//	end
//	
//	
//	always @(posedge Clock) begin
//		if(!ResetN) begin
//			start <= 1'b0;
//			X <= 8'd14;
//			Y <= 8'd10;
//			internal_finish <= 1'b0;
//		end
//		else begin
//			if(startPrintLabel && Q== 28'b0)
//				start <= 1'b1;
//			if(start) begin
//				X <= X + 1'b1;
//				if(X == 91 && Y != 17) begin
//					X <= 8'd14;
//					Y <= Y + 1'b1;
//				end
//				if(X == 91 && Y == 17) begin
//					start <= 1'b0;
//					X <= 8'd14;
//					Y <= 8'd10;
//					internal_finish <= 1'b1;
//				end
//			end
//		end
//	end
//	assign label_address = {1'b0, (Y-8'd10)*78} + {1'b0, X-8'd14};
//	win u0(label_address, Clock, wire1);
//	lose u1(label_address, Clock, wire2);
//	anotherround u2(label_address, Clock, wire3);
//
//	always@(*)
//	begin
//		case (stage)
//			2'b00: Colourout = wire1;
//			2'b01: Colourout = wire2;
//		endcase
//	end
//
//	always @(posedge Clock) begin
//		if(finish == 1) begin
//			finish <= 0;
//		end
//	end
//	
//endmodule



module continuelabel(Clock, ResetN, startPrintContinue, X, Y, Colourout, finish);
	input Clock, ResetN, startPrintContinue;
	output [8:0] Colourout;
	output reg [7:0] X;
	output reg [6:0] Y;
	output reg finish;
	reg start;
	wire [9:0] label_address;
	
	always @(posedge Clock) begin
		if(!ResetN) begin
			start <= 1'b0;
			X <= 8'd14;
			Y <= 8'd10;
			finish <= 1'b0;
		end
		else if(finish == 1) begin
			finish <= 0;
		end
		else begin
			if(startPrintContinue)
				start <= 1'b1;
			if(start) begin
				X <= X + 1'b1;
				if(X == 92 && Y != 17) begin
					X <= 8'd14;
					Y <= Y + 1'b1;
				end
				if(X == 92 && Y == 17) begin
					start <= 1'b0;
					X <= 8'd14;
					Y <= 8'd10;
					finish <= 1'b1;
				end
			end
		end
	end
	assign label_address = {1'b0, (Y-8'd10)*79} + {1'b0, X-8'd14};
	anotherround u0(label_address, Clock, Colourout);

endmodule



module highlow_label(Clock, ResetN, startPrinthighlowlabel, X, Y, Colourout, finish);
	input Clock, ResetN, startPrinthighlowlabel;
	output [8:0] Colourout;
	output reg [7:0] X;
	output reg [6:0] Y;
	output reg finish;
	reg start;
	wire [9:0] label_address;
	
	always @(posedge Clock) begin
		if(!ResetN) begin
			start <= 1'b0;
			X <= 8'd14;
			Y <= 8'd10;
			finish <= 1'b0;
		end
		else if(finish == 1) begin
			finish <= 0;
		end
		else begin
			if(startPrinthighlowlabel)
				start <= 1'b1;
			if(start) begin
				X <= X + 1'b1;
				if(X == 92 && Y != 17) begin
					X <= 8'd14;
					Y <= Y + 1'b1;
				end
				if(X == 92 && Y == 17) begin
					start <= 1'b0;
					X <= 8'd14;
					Y <= 8'd10;
					finish <= 1'b1;
				end
			end
		end
	end
	assign label_address = {1'b0, (Y-8'd10)*79} + {1'b0, X-8'd14};
	highlow u0(label_address, Clock, Colourout);

	
endmodule
