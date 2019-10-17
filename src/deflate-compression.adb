------------------------------------------------------------------------
--
--       Copyright (c) 2019, Hannu Örn
--       All rights reserved.
--
-- Author: Hannu Örn
--
------------------------------------------------------------------------

with Utility.Bit_Arrays;
with Deflate.Fixed_Huffman;   use Deflate.Fixed_Huffman;
with Deflate.Huffman;
with Deflate.Literals_Only_Huffman;


package body Deflate.Compression is

   package Byte_Huffman is new Deflate.Huffman (Utility.Bit_Arrays.Byte);



   procedure Make_Single_Block_With_Fixed_Huffman
     (Input             : in     Dynamic_Bit_Array;
      Output            : out    Dynamic_Bit_Array) is


      use Utility.Bit_Arrays.Dynamic_Bit_Arrays;
      use Utility;
      use Deflate.Fixed_Huffman.Literal_Length_Codes;

      C_Input           : Natural_64 := Input.First;
      B                 : Byte;
      FH                : Huffman_Code;
      FH_Codewords      : Huffman_Codewords;

   begin
      -- BFINAL = true
      -- BTYPE = fixed huffman
      -- block contents:
      -- don't bother trying to use length/distance,
      -- just use huffman literals.
      FH.Build(Fixed_Huffman_Bit_Lengths);
      FH_Codewords := FH.Get_Codewords;
      Output.Expect_Size(Input.Length);
      Add(Output, BFINAL_1);
      Add(Output, BTYPE_Fixed_Huffman);
      while C_Input <= Input.Last loop
         Read_Byte(Input, C_Input, B);
         Add(Output, FH_Codewords(Literal_Length_Symbol(B)));
      end loop;
      Add(Output, FH_Codewords(End_of_Block));
   end Make_Single_Block_With_Fixed_Huffman;


   procedure Compress
     (Input             : in     Dynamic_Bit_Array;
      Output            : out    Dynamic_Bit_Array) is

      use type Dynamic_Bit_Array;

   begin
      -- Demo_Huffman_Coding(Input);
      -- Make_Single_Block_With_Fixed_Huffman(Input, Output);
      -- Make_Single_Block_With_Optimal_Huffman(Input, Output);
      Deflate.Literals_Only_Huffman.Make_Single_Block(Input, Output);
   end Compress;

end Deflate.Compression;
