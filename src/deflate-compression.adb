------------------------------------------------------------------------
--
--       Copyright (c) 2019, Hannu Örn
--       All rights reserved.
--
-- Author: Hannu Örn
--
------------------------------------------------------------------------

with Ada.Text_IO;             use Ada.Text_IO;
with Utility.Bits_and_Bytes;
with Utility.Test;
with Deflate.Fixed_Huffman;   use Deflate.Fixed_Huffman;
with Deflate.Huffman;
with Deflate.Literals_Only_Huffman;
with Deflate.LZ77;


package body Deflate.Compression is

   package Byte_Huffman is new Deflate.Huffman (Utility.Bits_and_Bytes.Byte);



   procedure Make_Single_Block_With_Fixed_Huffman
     (Input             : in     Dynamic_Bit_Array;
      Output            : out    Dynamic_Bit_Array) is


      use Utility.Bits_and_Bytes.Dynamic_Bit_Arrays;
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

      -- Deco              : Dynamic_Bit_Array;
      -- C : Natural_64;
      -- B : Byte;

   begin
      Deflate.Literals_Only_Huffman.Make_Single_Block(Input, Output);
      
      -- Deflate.Literals_Only_Huffman.Decompress_Single_Block(Output, Deco);
      -- Put_Line("Originaalin koko: " & Natural_64'Image(Input.Length));
      -- Put_Line("Pakattu koko: " & Natural_64'Image(Output.Length));
      -- Put_Line("Purettu koko: " & Natural_64'Image(Deco.Length));
      -- if Input.Length = Deco.Length then
         -- for I in Input.First .. Input.Last loop
            -- if Input.Get(I) /= Deco.Get(I) then
               -- Put_Line("Bitti poikittain: " & Natural_64'Image(I));
            -- end if;
         -- end loop;
      -- end if;

   end Compress;

end Deflate.Compression;
