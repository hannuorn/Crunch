## Weekly report #6

25 hours.

Working with Huffman coding took longer than expected.
I realised that the basic code building routine developed last week
is more or less useless, because it creates arbitrarily long
codewords. I found the package-merge algorithm for building
length-limited codes (Sayood: Introduction to data compression).

Length-limited code building seems to be working now.
Next week I am hoping to finally be able to add actual functionality
to the program and compress files using dynamic Huffman coding.

Progress:
* Implemented length-limited Huffman code building algorithm
* Started unit testing on Huffman routines
* Improved code commenting, unit testing and program structure

Next week:
* Implement compression using dynamic Huffman codes
* Start working on length/distance compression
* Prepare to demonstrate the program next Monday
