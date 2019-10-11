------------------------------------------------------------------------
--
--       Copyright (c) 2019, Hannu Örn
--       All rights reserved.
--
-- Author: Hannu Örn
--
------------------------------------------------------------------------


------------------------------------------------------------------------
--
-- package Deflate
-- 
-- Implementation Notes:
--    Most of the code can be found in child packages.
--
------------------------------------------------------------------------

with Ada.Text_IO;                use Ada.Text_IO;
with Utility.Bit_Arrays;         use Utility.Bit_Arrays;
with Deflate.Demo;               use Deflate.Demo;
with Deflate.Huffman;
with Deflate.Fixed_Huffman;      use Deflate.Fixed_Huffman;


package body Deflate is

   procedure Run_Demo is
   
   begin
      Demo_Huffman_Tree_Building;
      Demo_Bit_Lengths_to_Huffman_Tree;
   end Run_Demo;
   
   
   procedure Make_Single_Block_With_Fixed_Huffman
     (Input             : in     Dynamic_Bit_Array;
      Output            : out    Dynamic_Bit_Array) is
      
      package Byte_Huffman is new Deflate.Huffman (Utility.Bit_Arrays.Byte);
      
      use Utility.Bit_Arrays.Dynamic_Bit_Arrays;
      use Utility;
      
      C_Input           : Natural_64 := Input.First;
      B                 : Byte;
      
   begin
      -- BFINAL = true
      -- BTYPE = fixed huffman
      -- block contents:
      -- don't bother trying to use length/distance,
      -- just use huffman literals.
      Output.Expect_Size(Input.Length);
      Add(Output, BFINAL_1);
      Add(Output, BTYPE_Fixed_Huffman);
      while C_Input <= Input.Last loop
         Read_Byte(Input, C_Input, B);
         Add(Output, Fixed_Huffman_Codewords(Literal_Length_Symbol(B)));
      end loop;
      Add(Output, Fixed_Huffman_Codewords(End_of_Block));
   end Make_Single_Block_With_Fixed_Huffman;
   
   
   procedure Compress
     (Input             : in     Dynamic_Bit_Array;
      Output            : out    Dynamic_Bit_Array) is
      
      use type Dynamic_Bit_Array;
      
   begin
      Demo_Huffman_Coding(Input);
      Make_Single_Block_With_Fixed_Huffman(Input, Output);
   end Compress;


   procedure Decode_Deflate_Block
     (Stream            : in     Dynamic_Bit_Array;
      Counter           : in out Natural_64;
      Output            : out    Dynamic_Bit_Array) is
   
      Header            : Dynamic_Bit_Array;
      BFINAL            : Bit;
      BTYPE             : BTYPE_Type;
      L                 : Literal_Length_Symbol;
      Found             : Boolean;

   begin
      Output.Set(Empty_Bit_Array);
      Read_Bit(Stream, Counter, BFINAL);
      Read(Stream, Counter, BTYPE);
      if BTYPE = BTYPE_No_Compression then
         -- not yet implemented
         --Skip_to_Next_Whole_Byte(Counter);
         --Read(Stream, Counter, 16, LEN);
         --Read(Stream, Counter, 16, NLEN);
         --copy LEN bytes o fdata to output
         null;
      else
         if BTYPE = BTYPE_Dynamic_Huffman then
            -- not yet implemented
            null;
         end if;
         loop
            Fixed_Huffman_Code.Find(Stream, Counter, Found, L);
            if Found then
               if L < 256 then
                  Output.Add(To_Bits(Byte(L)));
               elsif L = End_of_Block then
                  exit;
               else
                  -- length/distance not yet implemented
                  null;
               end if;
            end if;
         end loop;
      end if;
      if BFINAL = BFINAL_1 then
         Counter := Stream.Last + 1;
      end if;
   end Decode_Deflate_Block;
   
end Deflate;
