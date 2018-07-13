// This is the main part of the card game, see figure 2.2 for structure

// Overall module, using wires to connect between modules
module CardGameNeo(Clock, ResetN, go, load_bet, guess, load_input, bet_sw, continue, cont_key, Xout, Yout, Colourout, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, fixedNum, LEDR[9:0]);
	input Clock, ResetN, go, guess, load_bet, load_input, continue,cont_key;
	input [3:0] fixedNum;
	input [1:0] bet_sw;
	output [9:0] LEDR;
	output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output [7:0] Xout;
	output [6:0] Yout;
	output [8:0] Colourout;
	wire [4:0] current_state;
	wire [3:0] current_state_main;
	wire genfin, comparefin, gen, ch_bet, loadstart, compare, ld_faceup, ld_facedown, ld_highlow_fin, ld_input, do_compare, startPrintBackground, start_print_ch_bet, startPrintLeftCard, startPrintRightCard, startPrint_button, startPrint_label, regen, cal_chip;
	wire [3:0] RandomNum, Faceup, Facedown, staticCardNum, selectTest, Bet_D_Tens, Bet_D_Ones, Chip_D_Tens, Chip_D_Ones;
	wire [6:0] BetNum, ChipNum;
	wire result, trueResult, userGuess, printhigh, print_background_fin,dp_left_fin, dp_right_fin, ch_bet_fin, dp_highlow_label_fin, dp_highlow_button_fin, dp_compare_fin, flip_right_card, cont_ld_fin, chip_select_fin, bet_to_chip, stage_inside;
	
	MainControl maincontrol(Clock, ResetN, go, load_input, continue, result, ch_bet_fin, genfin, ld_highlow_fin, comparefin, cont_ld_fin, ch_bet, gen, loadstart, compare, regen, cal_chip, current_state_main);
	
	SignalControl signalcontrol(Clock, ResetN, load_bet, load_input, result, cont_key,
					 ch_bet, gen, loadstart, compare, regen, cal_chip,
					 print_background_fin, chip_select_fin, dp_left_fin, dp_right_fin, dp_highlow_label_fin, dp_highlow_button_fin, dp_compare_fin, animation_fin, continue_fin, 
					 ch_bet_fin, genfin, ld_highlow_fin, comparefin, cont_ld_fin, 
					ld_bet, ld_faceup, ld_facedown, ld_input, do_compare, ld_continue, bet_to_chip,
					startPrintBackground, start_print_ch_bet, startPrintLeftCard, startPrintRightCard, startPrint_highlow_label, flip_right_card, startPrint_button, startPrint_label, startPrint_card_animation, startPrintContinue, printhigh,
					current_state);
					
					
	LogicDatapath logicdatapath(
			Clock, ResetN,
			guess, ld_bet, ld_faceup, ld_facedown, ld_input, do_compare, bet_to_chip, 
			RandomNum, 
			bet_sw, 
			BetNum, ChipNum,
			Faceup, Facedown, 
			result, trueResult, userGuess 
			);
			
			
	DisplayDatapath displaydatapath(
			Clock, ResetN,
			bet_sw,
			Faceup, Facedown,
			startPrintBackground, start_print_ch_bet, startPrintLeftCard, startPrintRightCard, startPrint_button, 
					flip_right_card, startPrint_label, startPrint_card_animation, startPrintContinue, startPrint_highlow_label, result,
			printhigh,
			Xout,
			Yout,
			Colourout,
			print_background_fin,chip_select_fin, dp_left_fin, dp_right_fin, dp_highlow_label_fin, dp_highlow_button_fin, dp_compare_fin, animation_fin, continue_fin,stage_inside,
			staticCardNum, selectTest
	);
	
	
	FibonacciLFSR LFSR(Clock, ResetN, RandomNum);
	binary_to_dicimal c1({1'b0,BetNum[6:0]}, Bet_D_Tens, Bet_D_Ones);
	binary_to_dicimal c2({1'b0,ChipNum[6:0]}, Chip_D_Tens, Chip_D_Ones);
	hex_decoder hex5(Faceup, HEX5);
	hex_decoder hex4(Facedown, HEX4);
	hex_decoder hex3({1'b0,BetNum[6:4]}, HEX3);
	hex_decoder hex2(BetNum[3:0], HEX2);
	//hex_decoder(Chip_D_Tens, HEX1);
	//hex_decoder(Chip_D_Ones, HEX0);
	//hex_decoder(Bet_D_Tens, HEX3);//(RandomNum, HEX3);
	//hex_decoder(Bet_D_Ones, HEX2);//(staticCardNum, HEX2);
	hex_decoder hex1({1'b0,ChipNum[6:4]}, HEX1);
	hex_decoder hex0(ChipNum[3:0], HEX0);
	
	//assign LEDR[2] = trueResult;
	//assign LEDR[1] = highlowlabel_fin;//userGuess;
	// Use LED to show what state the program is currently in, useful skill for debugging
	assign LEDR[9:5] = current_state;
	assign LEDR[4:1] = current_state_main;
	//assign LEDR[1] = gen;
	//assign LEDR[2] = print_background_fin;
	assign LEDR[0] = stage_inside;
endmodule


// High level FSM for the game procedure
module MainControl(input Clock, ResetN,
					input go, load_input, continue, //from neo
					input result, //from logic dp
					input ch_bet_fin, genfin, ld_highlow_fin, comparefin, cont_ld_fin, //from signal control
					output reg ch_bet, gen, loadstart, compare, regen, cal_chip, //to display dp
					output [3:0] current_state_main);
	reg [3:0] current_state, next_state;
	
	assign current_state_main = current_state;
	
	localparam
	START_TEMP = 4'd0,
	START_WAIT_TEMP = 4'd1,
	CHOOSE_BET = 4'd8,
	RANDOM_GENERATE = 4'd2,
	LOAD_HIGHLOW = 4'd3,
	//LOAD_HIGHLOW_WAIT = 4'd4,
	COMPARING = 4'd5,
	COMPARING_WAIT = 4'd6,
	CONTINUE = 4'd7,
	CONTINUE_WAIT = 4'd12,
	RANDOM_GENERATE_STANDBY = 4'd9,
	CALCULATE_CHIP = 4'd10;
	
	always @(*)
    begin: state_table 
        case (current_state)
			START_TEMP: next_state = go ? START_WAIT_TEMP : START_TEMP;
			START_WAIT_TEMP: next_state = go ? START_WAIT_TEMP : CHOOSE_BET;
			CHOOSE_BET: next_state = ch_bet_fin ? RANDOM_GENERATE : CHOOSE_BET;
			RANDOM_GENERATE: next_state = genfin ? LOAD_HIGHLOW : RANDOM_GENERATE;
			LOAD_HIGHLOW: next_state = ld_highlow_fin ? COMPARING : LOAD_HIGHLOW;
			//LOAD_HIGHLOW: next_state = load ? LOAD_HIGHLOW_WAIT : LOAD_HIGHLOW;
			//LOAD_HIGHLOW_WAIT: next_state = load ? LOAD_HIGHLOW_WAIT : COMPARING;
			COMPARING: next_state = comparefin ? COMPARING_WAIT : COMPARING;
			COMPARING_WAIT: next_state = result ? CONTINUE : CALCULATE_CHIP;
			
			CONTINUE: next_state = cont_ld_fin ? CONTINUE_WAIT : CONTINUE;
			CONTINUE_WAIT: next_state = continue ? RANDOM_GENERATE_STANDBY : CALCULATE_CHIP;
			
			RANDOM_GENERATE_STANDBY: next_state = RANDOM_GENERATE;
			CALCULATE_CHIP: next_state = CHOOSE_BET;
		default: next_state = START_TEMP;
		endcase
	end
	
	always @(*)
    begin: enable_signals
		// By default make all our signals 0
		ch_bet = 1'b0;
		gen = 1'b0;
		loadstart = 1'b0;
		compare = 1'b0;
		regen = 1'b0;
		cal_chip = 1'b0;
		
		case (current_state)
			CHOOSE_BET: ch_bet = 1'b1;
			RANDOM_GENERATE: gen = 1'b1;
			LOAD_HIGHLOW: loadstart = 1'b1;
			COMPARING: compare = 1'b1;
			RANDOM_GENERATE_STANDBY: regen = 1'b1;
			CALCULATE_CHIP: cal_chip = 1'b1;
		endcase
	end
	
	always @(posedge Clock) begin
		if (!ResetN)
			current_state <= START_TEMP;
		else 
		    current_state <= next_state;
	end
endmodule


// Low level FSM for going through all the states, and for each state set all enable signals
module SignalControl(input Clock, ResetN, load_bet, load_input, result, cont_key,
					input ch_bet, gen, loadstart, compare, regen, cal_chip, //from maincontrol
					input print_background_fin, chip_select_fin, dp_left_fin, dp_right_fin, dp_highlow_label_fin, dp_highlow_button_fin, dp_compare_fin, animation_fin, continue_fin, //from display dp
					output reg ch_bet_fin, genfin, ld_highlow_fin, comparefin, cont_ld_fin, //to maincontrol
					output reg ld_bet, ld_faceup, ld_facedown, ld_input, do_compare, ld_continue, bet_to_chip, //to logic datapath
					output reg startPrintBackground, start_print_ch_bet, startPrintLeftCard, startPrintRightCard, startPrint_highlow_label, flip_right_card, startPrint_button, startPrint_label, startPrint_card_animation, startPrintContinue, printhigh, //to display dp
					output reg [4:0] current_state
					);
	
	reg [4:0] next_state;
	
	localparam
	START_TEMP = 5'd0,
	CHOOSE_BET_DP = 5'd1,
	CHOOSE_BET_LOAD = 5'd2,
	CHOOSE_BET_LOAD_WAIT = 5'd3,
	STUCK_IN = 5'd4,
	//CHOOSE_BET_HIGHLIGHT = 5'd11,
	RESTORE_BACKGROUND = 5'd5,
	LD_FACEUP = 5'd6,
	LD_FACEDOWN = 5'd7,
	LD_CARD_WAIT = 5'd8,
	LOAD_HIGHLOW_DP_LABEL = 5'd9,
	LOAD_HIGHLOW_DP_BUTTON = 5'd10,
	LOAD_HIGHLOW_LD = 5'd11,
	LOAD_HIGHLOW_LD_WAIT = 5'd12,
	LOAD_HIGHLOW_HIGHLIGHT = 5'd13,
	CARD_ANIMATION = 5'd14,
	FLIP_CARD = 5'd15,
	DO_COMPARE = 5'd16,
	//DO_COMPARE_WAIT = 5'd6,
	CONTINUE_DP_LABEL = 5'd17,
	CONTINUE_DP_BUTTON = 5'd18,
	CONTINUE_LOAD = 5'd19,
	CONTINUE_LOAD_WAIT = 5'd20,
	WAIT_NEXT_STEP = 5'd21,
	CALCULATE_CHIP = 5'd22;
	
	always @(*)
    begin: state_table 
        case (current_state)
			START_TEMP: next_state = ch_bet ? CHOOSE_BET_DP : START_TEMP;
			//START_TEMP: next_state = gen ? LD_FACEUP : START_TEMP;
			
			CHOOSE_BET_DP: next_state = chip_select_fin ? CHOOSE_BET_LOAD : CHOOSE_BET_DP;
			CHOOSE_BET_LOAD: next_state = load_bet ? CHOOSE_BET_LOAD_WAIT : CHOOSE_BET_LOAD;
			CHOOSE_BET_LOAD_WAIT: next_state = load_bet ? CHOOSE_BET_LOAD_WAIT : RESTORE_BACKGROUND;
			//CHOOSE_BET_HIGHLIGHT: next_state = (hl_ch_bet_fin && gen) ? RESTORE_BACKGROUND : CHOOSE_BET_HIGHLIGHT;
			STUCK_IN: next_state = STUCK_IN;
			
			RESTORE_BACKGROUND: next_state = (print_background_fin && gen) ? LD_FACEUP : RESTORE_BACKGROUND;
			LD_FACEUP: next_state = dp_left_fin ? LD_FACEDOWN : LD_FACEUP;
			LD_FACEDOWN: next_state = dp_right_fin ? LOAD_HIGHLOW_DP_LABEL : LD_FACEDOWN;
			//LD_CARD_WAIT: next_state = loadstart ? LOAD_HIGHLOW_DP_LABEL : LD_CARD_WAIT;
			
			LOAD_HIGHLOW_DP_LABEL: next_state = dp_highlow_label_fin ? LOAD_HIGHLOW_DP_BUTTON : LOAD_HIGHLOW_DP_LABEL;
			LOAD_HIGHLOW_DP_BUTTON: next_state = dp_highlow_button_fin ? LOAD_HIGHLOW_LD : LOAD_HIGHLOW_DP_BUTTON;
			LOAD_HIGHLOW_LD: next_state = load_input ? LOAD_HIGHLOW_LD_WAIT : LOAD_HIGHLOW_LD;
			LOAD_HIGHLOW_LD_WAIT: next_state = ((!load_input) && compare) ? CARD_ANIMATION : LOAD_HIGHLOW_LD_WAIT;// : LOAD_HIGHLOW_HIGHLIGHT;
			//LOAD_HIGHLOW_HIGHLIGHT: next_state = (dp_highlow_button_fin && compare) ? CARD_ANIMATION : LOAD_HIGHLOW_HIGHLIGHT;
			//LOAD_HIGHLOW: next_state = dp_highlow_fin ? LOAD_HIGHLOW_WAIT : LOAD_HIGHLOW;
			//LOAD_HIGHLOW_WAIT: next_state = compare ? DO_COMPARE : LOAD_HIGHLOW_WAIT;
			
			CARD_ANIMATION: next_state = animation_fin ? FLIP_CARD : CARD_ANIMATION;
			FLIP_CARD: next_state = dp_right_fin ? DO_COMPARE : FLIP_CARD;
			DO_COMPARE: begin//next_state = dp_compare_fin ? DO_COMPARE_WAIT : DO_COMPARE;
				if (dp_compare_fin)
					next_state = result ? CONTINUE_DP_LABEL : CALCULATE_CHIP;
				else next_state = DO_COMPARE;
			end
			
			CONTINUE_DP_LABEL: next_state = continue_fin ? CONTINUE_DP_BUTTON : CONTINUE_DP_LABEL;
			CONTINUE_DP_BUTTON: next_state = dp_highlow_button_fin ? CONTINUE_LOAD : CONTINUE_DP_BUTTON;
			CONTINUE_LOAD: next_state = cont_key ? CONTINUE_LOAD_WAIT : CONTINUE_LOAD;
			CONTINUE_LOAD_WAIT: next_state = cont_key ? CONTINUE_LOAD_WAIT : WAIT_NEXT_STEP;
			/*begin
				if (!cont_key)
					next_state = continue ? RESTORE_BACKGROUND : CALCULATE_CHIP;
				else
					next_state = CONTINUE_LOAD_WAIT;
			end*/
			
			WAIT_NEXT_STEP: begin
				if (gen) next_state = RESTORE_BACKGROUND;
				//else if (cal_chip) next_state = CALCULATE_CHIP;
				else next_state = CHOOSE_BET_DP;//WAIT_NEXT_STEP;
			end
			CALCULATE_CHIP: next_state = CHOOSE_BET_DP;
		default: next_state = START_TEMP;
		endcase
	end
	
	always @(*) begin: enable_signals
		// By default make all our signals 0
		//To logic dp
		ld_bet = 1'b0;
		ld_faceup = 1'b0;
		ld_facedown = 1'b0;
		ld_input = 1'b0;
		do_compare = 1'b0;
		ld_continue = 1'b0;
		bet_to_chip = 1'b0;
		
		//To display dp
		startPrintBackground = 1'b0;
		start_print_ch_bet = 1'b0;
		//start_highlight_ch_bet = 1'b0;
		startPrintLeftCard = 1'b0;
		startPrintRightCard = 1'b0;
		startPrint_highlow_label = 1'b0;
		//flip_right_card = 1'b1;//TODO
		startPrint_button = 1'b0;
		startPrint_label = 1'b0;
		startPrint_card_animation = 1'b0;
		startPrintContinue = 1'b0;
		printhigh = 1'b0;
		
		//back to maincontrol
		ch_bet_fin = 1'b0;
		genfin = 1'b0;
		ld_highlow_fin = 1'b0;
		comparefin = 1'b0;
		cont_ld_fin = 1'b0;
		
		case (current_state)
			START_TEMP: begin
				startPrintBackground = 1'b1;
				end
			CHOOSE_BET_DP: begin
				start_print_ch_bet = 1'b1;
				flip_right_card = 1'b0;
				end
			CHOOSE_BET_LOAD: begin
				ld_bet = 1'b1;
				end
			CHOOSE_BET_LOAD_WAIT: begin
				ch_bet_fin = 1'b1;
				end
			
			RESTORE_BACKGROUND: begin
				startPrintBackground = 1'b1;
				end
			LD_FACEUP: begin
				ld_faceup = 1'b1;
				startPrintLeftCard = 1'b1;
				end
			LD_FACEDOWN: begin
				ld_facedown = 1'b1;
				flip_right_card = 1'b0;
				startPrintRightCard = 1'b1;
				genfin = 1'b1;
				end
			LD_CARD_WAIT: begin
				genfin = 1'b1;
				end
			
			LOAD_HIGHLOW_DP_LABEL: begin
				startPrint_highlow_label = 1'b1;
				end
			LOAD_HIGHLOW_DP_BUTTON: begin
				startPrint_button = 1'b1;
				printhigh = 1'b1;
				end
			LOAD_HIGHLOW_LD: begin
				ld_input = 1'b1;
				ld_highlow_fin = 1'b1;
				end
			//LOAD_HIGHLOW_HIGHLIGHT: begin
			//	startPrint_highlow_label = 1'b1;
			//	ld_highlow_fin = 1'b1;
			//	end
			
			CARD_ANIMATION: begin
				startPrint_card_animation = 1'b1;
				end
			FLIP_CARD: begin
				startPrintRightCard = 1'b1;
				flip_right_card = 1'b1;
				end
			DO_COMPARE: begin
				do_compare = 1'b1;
				startPrint_label = 1'b1;
				comparefin = 1'b1;
				end
			
			CONTINUE_DP_LABEL: begin
				startPrintContinue = 1'b1;
				end
			CONTINUE_DP_BUTTON: begin
				startPrint_button = 1'b1;
				printhigh = 1'b0;
				end
			CONTINUE_LOAD: begin
				ld_continue = 1'b1;
				end
			CONTINUE_LOAD_WAIT: begin
				cont_ld_fin = 1'b1;
				end
			WAIT_NEXT_STEP: begin
				
				end
			CALCULATE_CHIP: begin
				bet_to_chip = 1'b1;
				end
		endcase
	end
	
	always @(posedge Clock) begin
		if (!ResetN)
			current_state = START_TEMP;
		else 
		   current_state = next_state;
	end
endmodule


// Module for all logical judgements, e.g. calculating chips, getting card number, doing comparison
module LogicDatapath(
			input Clock, ResetN,
			input guess, ld_bet, ld_faceup, ld_facedown, ld_input, do_compare, bet_to_chip, //from sigControl
			input [3:0] RandomNum, 
			input [1:0] bet_sw, //from maincontrol
			output reg [7:0] BetNum, ChipNum, //to main
			output reg [3:0] Faceup, Facedown, //to display dp
			output reg result, trueResult, userGuess //to main for testing
			);
	reg staticGetLeftValue, leftCardSet, rightCardSet, staticGetRightValue; 
	
	//Register loading
	always @(posedge Clock) begin
		if(!ResetN) begin
			Faceup = 4'd9;
			Facedown = 4'b0;
			result = 1'b0;
			trueResult = 1'b0;
			userGuess = 1'b0;
			BetNum = 7'd0;
			ChipNum = 7'd20;
			leftCardSet = 1'b0;
			staticGetLeftValue = 1'b0;
			rightCardSet = 1'b0;
			staticGetRightValue = 1'b0;
		end
		else begin
			if(ld_bet) begin
				case (bet_sw)
					2'b01: begin
						BetNum = 8'd5;
						ChipNum = {1'b0,ChipNum} - {1'b0,7'd5};
						end
					2'b10: begin
						BetNum = 7'd10;
						ChipNum = ChipNum - 7'd10;
						end
					2'b11: begin
						BetNum = 7'd20;
						ChipNum = ChipNum - 7'd20;
						end
				default: BetNum = 7'd0;
				endcase
			end
			if(ld_faceup) begin
				if(!leftCardSet && staticGetLeftValue) begin // leftCardSet is for not setting the card by random number again
					// staticGetLeftValue is for not setting the faceup as the initial value but a value from LFSR
					Faceup = RandomNum;
					leftCardSet = 1'b1;
				end
				staticGetLeftValue = 1'b1;
			end
			if(ld_facedown) begin
				if(!rightCardSet && staticGetRightValue) begin
					Facedown = RandomNum;
					rightCardSet = 1'b1;
				end
				staticGetRightValue = 1'b1;
				trueResult = (Facedown >= Faceup) ? 1 : 0;
			end
			if(ld_input) begin
				userGuess = guess;
				leftCardSet = 1'b0;
				staticGetLeftValue = 1'b0;
				rightCardSet = 1'b0;
				staticGetRightValue = 1'b0;
				end
			if(do_compare) begin
				result = (userGuess == trueResult) ? 1 : 0;
				BetNum = result ? BetNum * 2 : 7'b0;
			end
			if(bet_to_chip) begin
				ChipNum = ChipNum + BetNum;
				//TODO if ChipNum < 0
				BetNum = 7'b0;
			end
		end
	end
endmodule


// Datapath for displaying, input the current element we want to print
// Output printing coordinate and current colour to print from modules within print.v
module DisplayDatapath(
	input Clock, ResetN,
	input [1:0] bet_sw, //from main
	input [3:0] Faceup, Facedown, //from logic dp
	input startPrintBackground, start_print_ch_bet, startPrintLeftCard, startPrintRightCard, startPrint_button, 
	      flip_right_card, startPrint_label, startPrint_card_animation, startPrintContinue, startPrint_highlow_label, result,
              //form sig_contl
	input printhigh, //from sig_contl
	output reg [7:0] Xout,
	output reg [6:0] Yout,
	output reg [8:0] Colourout,
	output print_background_fin, chip_select_fin, dp_left_fin, dp_right_fin, highlowlabel_fin, dp_highlow_fin, dp_compare_fin, animation_fin, continue_fin,stage_inside,// to main
	output [3:0] staticCardNum, selectTest // to main for testing
	);

	wire [7:0] X_background, X_leftcard, X_rightcard, X_button, X_label, X_animation, X_chip_select, X_continue, X_highlowlabel;
	wire [6:0] Y_background, Y_leftcard, Y_rightcard, Y_button, Y_label, Y_animation, Y_chip_select, Y_continue, Y_highlowlabel;
	wire [8:0] Colour_background, Colour_leftcard, Colour_rightcard, Colour_button, Colour_label, Colour_animation, Colour_chip, Colour_continue, Colour_highlowlabel;

	background background(Clock, ResetN, startPrintBackground, X_background, Y_background, Colour_background, print_background_fin);
	leftcard leftcard(Clock, ResetN, startPrintLeftCard, Faceup, X_leftcard, Y_leftcard, Colour_leftcard, dp_left_fin, staticCardNum, selectTest);
	rightcard rightcard(Clock, ResetN, startPrintRightCard, flip_right_card, Facedown, X_rightcard, Y_rightcard, Colour_rightcard, dp_right_fin);
	button button(Clock, ResetN, startPrint_button, printhigh, X_button, Y_button, Colour_button, dp_highlow_fin);
	label label(Clock, ResetN, startPrint_label, result, X_label, Y_label, Colour_label, dp_compare_fin, stage_inside);

	card_animation card_animation(Clock, ResetN, startPrint_card_animation, X_animation, Y_animation, Colour_animation, animation_fin);
	chip_select chip_select(Clock, ResetN, start_print_ch_bet,bet_sw, X_chip_select, Y_chip_select, Colour_chip, chip_select_fin);
	continuelabel continuelabel(Clock, ResetN, startPrintContinue, X_continue, Y_continue, Colour_continue, continue_fin);
	highlow_label highlow_label(Clock, ResetN, startPrint_highlow_label, X_highlowlabel, Y_highlowlabel, Colour_highlowlabel, highlowlabel_fin);

	always @(*) begin
		if(startPrintBackground) begin
			Xout <= X_background;
			Yout <= Y_background;
			Colourout <= Colour_background;
		end
		if(startPrintLeftCard) begin
			Xout <= X_leftcard;
			Yout <= Y_leftcard;
			Colourout <= Colour_leftcard;
		end
		if(startPrintRightCard) begin
			Xout <= X_rightcard;
			Yout <= Y_rightcard;
			Colourout <= Colour_rightcard;
		end
		if(startPrint_button) begin
			Xout <= X_button;
			Yout <= Y_button;
			Colourout <= Colour_button;
		end
		if(startPrint_label) begin
			Xout <= X_label;
			Yout <= Y_label;
			Colourout <= Colour_label;
		end
		if(startPrint_card_animation) begin
			Xout <= X_animation;
			Yout <= Y_animation;
			Colourout <= Colour_animation;
		end
		if(start_print_ch_bet) begin
			Xout <= X_chip_select;
			Yout <= Y_chip_select;
			Colourout <= Colour_chip;
		end
		if(startPrintContinue) begin
			Xout <= X_continue;
			Yout <= Y_continue;
			Colourout <= Colour_continue;
		end
		if(startPrint_highlow_label) begin
			Xout <= X_highlowlabel;
			Yout <= Y_highlowlabel;
			Colourout <= Colour_highlowlabel;
		end 
	end
	
endmodule


// Random number generator (linear-feedback shift register), for generating cards
module FibonacciLFSR(Clock, ResetN, RandomNum);
	input Clock, ResetN;
	output [3:0] RandomNum;
	reg [15:0] ShiftReg;
	
	assign RandomNum = ShiftReg[10:7];
	
	always @(posedge Clock) begin
		if(!ResetN) begin
			ShiftReg <= 16'b1010110011100001;
		end
		else begin
			ShiftReg[15] <= ((ShiftReg[0]^ShiftReg[2])^ShiftReg[3])^ShiftReg[5];
			ShiftReg[14:0] <= ShiftReg[15:1];
		end
	end
endmodule

module binary_to_dicimal(
		input [7:0] binary,
		output reg [3:0] Tens,
		output reg [3:0] Ones);
	integer i;
	reg [3:0] Hundreds;
	
	always @(binary) begin
		Hundreds = 4'd0;
		Tens = 4'd0;
		Ones = 4'd0;
		for (i = 7; i >= 0; i = i - 1) begin
			if (Hundreds >= 4'd5)
				Hundreds <= Hundreds + 4'd3;
			if (Tens >= 4'd5)
				Tens <= Tens + 4'd3;
			if (Ones >= 4'd5)
				Ones <= Ones + 4'd3;
			
			Hundreds[3:1] <= Hundreds[2:0];
			Hundreds[0] <= Tens[3];
			Tens[3:1] <= Tens[2:0];
			Tens[0] <= Ones[3];
			Ones[3:1] <= Ones[2:0];
			Ones[0] <= binary[i];
		end
	end
endmodule

// Hex display module
module hex_decoder(hex_digit, segments);
    input [3:0] hex_digit;
    output reg [6:0] segments;
   
    always @(*)
        case (hex_digit)
            4'h0: segments = 7'b100_0000;
            4'h1: segments = 7'b111_1001;
            4'h2: segments = 7'b010_0100;
            4'h3: segments = 7'b011_0000;
            4'h4: segments = 7'b001_1001;
            4'h5: segments = 7'b001_0010;
            4'h6: segments = 7'b000_0010;
            4'h7: segments = 7'b111_1000;
            4'h8: segments = 7'b000_0000;
            4'h9: segments = 7'b001_1000;
            4'hA: segments = 7'b000_1000;
            4'hB: segments = 7'b000_0011;
            4'hC: segments = 7'b100_0110;
            4'hD: segments = 7'b010_0001;
            4'hE: segments = 7'b000_0110;
            4'hF: segments = 7'b000_1110;   
            default: segments = 7'h7f;
        endcase
endmodule