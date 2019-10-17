------------------------------------------------------------------------
--
--       Copyright (c) 2019, Hannu Örn
--       All rights reserved.
--
-- Author: Hannu Örn
--
------------------------------------------------------------------------

with Utility.Bit_Arrays;      use Utility.Bit_Arrays;
with Deflate.Literals_Only_Huffman;


package body Deflate.Decompression is


   procedure Decompress
     (Input             : in     Dynamic_Bit_Array;
      Output            : out    Dynamic_Bit_Array) is

   begin
      Deflate.Literals_Only_Huffman.Decompress_Single_Block(Input, Output);
   end Decompress;


end Deflate.Decompression;
