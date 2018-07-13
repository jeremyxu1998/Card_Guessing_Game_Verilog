# Card_Guessing_Game_Verilog
This project is a card game that player can guess the relative high-low of two random generated poker cards, and could win or lose chips according to the result. This is a simple and interesting software game and we want to implement it in the form of Verilog hardware programming.

The game is implemented on DE1-SOC FPGA board. Players can make their choice during the game through keys and switches. Chip numbers are shown through the HEX displays, and images are displayed on a VGA display connected to FPGA.

For documenting reason, all .mif files and their .v initializing files are now stored in folders, but when creating them, mif directory setup in .v files were not done properly. So
just a reminder to myself, before compile, put all the files in the root folder.

Project worked by Jeremy Xu and Cynthia Lu