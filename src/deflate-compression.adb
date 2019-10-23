------------------------------------------------------------------------
--
--       Copyright (c) 2019, Hannu Örn
--       All rights reserved.
--
-- Author: Hannu Örn
--
------------------------------------------------------------------------

with Utility.Bits_and_Bytes;
with Utility.Test;
with Deflate.Literal_Length_and_Distance;   
use  Deflate.Literal_Length_and_Distance;   
with Deflate.Huffman;
with Deflate.Literals_Only_Huffman;
with Deflate.LZ77;            use Deflate.LZ77;


package body Deflate.Compression is

   package Byte_Huffman is new Deflate.Huffman (Utility.Bits_and_Bytes.Byte);



   procedure Make_Single_Block_With_Fixed_Huffman
     (Input             : in     Dynamic_Bit_Array;
      Output            : out    Dynamic_Bit_Array) is


      use Utility.Bits_and_Bytes.Dynamic_Bit_Arrays;
      use Utility;
      use Literal_Length_Huffman;

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
         Add(Output, FH_Codewords(Literal_Length_Letter(B)));
      end loop;
      Add(Output, FH_Codewords(End_of_Block));
   end Make_Single_Block_With_Fixed_Huffman;


   procedure Compress
     (Input             : in     Dynamic_Byte_Array;
      Output            : out    Dynamic_Bit_Array) is

      use type Dynamic_Bit_Array;

      -- Deco              : Dynamic_Bit_Array;
      -- C : Natural_64;
      -- B : Byte;
      LLDs              : Dynamic_LLD_Array;
      LL_Weights        : Literal_Length_Huffman.Letter_Weights;
      Distance_Weights  : Distance_Huffman.Letter_Weights;
      LL_Code           : Literal_Length_Huffman.Huffman_Code;
      LL_Codewords      : Literal_Length_Huffman.Huffman_Codewords;
      Distance_Code     : Distance_Huffman.Huffman_Code;
      EOB               : Literal_Length_Huffman.Huffman_Codeword;
      Text_Output       : Dynamic_Byte_Array;

   begin
      LZ77.Compress(Input, LLDs);
      LZ77.Count_Weights(LLDs, LL_Weights, Distance_Weights);
      LL_Code.Build_Length_Limited(15, LL_Weights);
      LL_Codewords := LL_Code.Get_Codewords;
      Distance_Code.Build_Length_Limited(15, Distance_Weights);
      
      -- Demo
      -- LL_Code.Print;
      -- Literal_Length_Huffman.Print(LL_Codewords);
      
      -- write block header
      
      Output.Add((1 => BFINAL_1));
      Output.Add(BTYPE_Dynamic_Huffman);
      
      -- write code trees, encoding LL_Code and Distance_Code
      Write_Block_Header(Output, LL_Code, Distance_Code);
      
      LLD_Array_to_Bit_Array(LLDs, LL_Code, Distance_Code, Output);
      
      EOB := LL_Codewords (End_of_Block);
      Output.Add(EOB);

   end Compress;

   
   procedure Get_LZ_Text_Results
     (Input             : in     Dynamic_Byte_Array;
      Output            : out    Dynamic_Byte_Array) is

      LLDs              : Dynamic_LLD_Array;

   begin
      LZ77.Compress(Input, LLDs);
      LLD_Array_to_ASCII(LLDs, Input, Output);
   end Get_LZ_Text_Results;
   
   
end Deflate.Compression;
