with Deflate.Huffman;


package Deflate.Fixed_Huffman is

   type Literal_Length_Alphabet is range 0 .. 287;
   subtype Literal_Length_Symbol is Literal_Length_Alphabet range 0 .. 285;
   
   package Literal_Length_Codes is new Deflate.Huffman(Literal_Length_Alphabet);
   use Literal_Length_Codes;
   
   
   -- RFC 3.2.5
   
   End_of_Block            : constant Literal_Length_Symbol := 256;
   
   Length_Extra_Bits       : constant Bit_Lengths (257 .. 285):=
     (257 .. 264  => 0,
      265 .. 268  => 1,
      269 .. 272  => 2,
      273 .. 276  => 3,
      277 .. 280  => 4,
      281 .. 284  => 5,
      285         => 0);
      
   First_Length            : constant Naturals (257 .. 285) := 
     (257 => 3,
      258 => 4,
      259 => 5,
      260 => 6,
      261 => 7,
      262 => 8,
      263 => 9,
      264 => 10,
      265 => 11,
      266 => 13,
      267 => 15,
      268 => 17,
      269 => 19,
      270 => 23,
      271 => 27,
      272 => 31,
      273 => 35,
      274 => 43,
      275 => 51,
      276 => 59,
      277 => 67,
      278 => 83,
      279 => 99,
      280 => 115,
      281 => 131,
      282 => 163,
      283 => 195,
      284 => 227,
      285 => 258);
      
   Distance_Extra_Bits     : constant Bit_Lengths (0 .. 29) :=
     ( 0 .. 3  => 0,
       4 .. 5  => 1,
       6 .. 7  => 2,
       8 .. 9  => 3,
      10 .. 11 => 4,
      12 .. 13 => 5,
      14 .. 15 => 6,
      16 .. 17 => 7,
      18 .. 19 => 8,
      20 .. 21 => 9,
      22 .. 23 => 10,
      24 .. 25 => 11,
      26 .. 27 => 12,
      28 .. 29 => 13);
      
   First_Distance          : constant Naturals (0 .. 29) :=
     ( 0 => 1,
       1 => 2,
       2 => 3,
       3 => 4,
       4 => 5,
       5 => 7,
       6 => 9,
       7 => 13,
       8 => 17,
       9 => 25,
      10 => 33,
      11 => 49,
      12 => 65,
      13 => 97,
      14 => 129,
      15 => 193,
      16 => 257,
      17 => 385,
      18 => 513,
      19 => 769,
      20 => 1025,
      21 => 1537,
      22 => 2049,
      23 => 3073,
      24 => 4097,
      25 => 6145,
      26 => 8193,
      27 => 12289,
      28 => 16385,
      29 => 24577);
       
       
   -- RFC 3.2.6
   
   Fixed_Huffman_Bit_Lengths  : constant Bit_Lengths(Literal_Length_Alphabet) :=
     (  0 .. 143  => 8,
      144 .. 255  => 9,
      256 .. 279  => 7,
      280 .. 287  => 8);
      
   Fixed_Huffman_Tree         : constant Huffman_Tree := 
                                    Build(Fixed_Huffman_Bit_Lengths);
   
   Fixed_Huffman_Dictionary   : constant Dictionary := 
                                    Get_Code_Values(Fixed_Huffman_Tree);

end Deflate.Fixed_Huffman;
