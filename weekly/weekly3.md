## Weekly report #3

During the 3rd week I spent about 16 hours working on the project. 
I developed the basics of Huffman routines and got started on unit testing
and code commenting. I feel the project is lagging behind slightly at this stage,
since the program cannot actually do much yet. Next week's plan is to achieve
as much progress as possible on implementing the actual Deflate compression/decompression.


### Monday

4 hours. Started writing code. Created the class Dynamic_Array, similar to Java's ArrayList.


### Tuesday & Wednesday

6 hours. Basic Huffman code handling implemented. The routines are now able
to build a Huffman tree from an input of bit lengths as described in 
RFC 1951 3.2.2. Simple decoding of a bit stream is also working.

Tomorrow's plan is to look into unit testing and finding / developing a systematic
way of commenting code.

Here you can enjoy an example of what the program can do at the moment.

    Some dumb testing...
    Demonstrating RFC 3.2.2.
    Alphabet is ABCDEFGH
    Building Huffman tree from bit lengths (3, 3, 3, 3, 3, 2, 4, 4)
    Codes in the tree:
    
    A = 010
    B = 011
    C = 100
    D = 101
    E = 110
    F = 00
    G = 1110
    H = 1111
    
    Some coded bits = 01010010110011011111111110111111000
    Decoded string: ACDCEHHEHEF
    
    Brilliant!
    Goodbye.


### Thursday & Friday

6 hours. Reformatted the source code in package Utility.Dynamic_Arrays so
as to conform to [Ada Style Guide](https://en.wikibooks.org/wiki/Ada_Style_Guide),
including standardized comments on function specifications.

I also wrote some unit tests for the same package using "pragma Assert".
Assert throws exception Assertion_Error if the condition is false.
