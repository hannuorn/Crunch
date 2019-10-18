with Deflate.Huffman;


private package Deflate.Literals_Only_Huffman is

   type Literals_Only_Alphabet is range 0 .. 256;
   package Literals_Only_Huffman is new Deflate.Huffman(Literals_Only_Alphabet, 15);

   End_of_Block         : constant Literals_Only_Alphabet := 256;


   procedure Make_Single_Block
     (Input             : in     Dynamic_Bit_Array;
      Output            : out    Dynamic_Bit_Array);

   procedure Decompress_Single_Block
     (Input             : in     Dynamic_Bit_Array;
      Output            : out    Dynamic_Bit_Array);

end Deflate.Literals_Only_Huffman;
