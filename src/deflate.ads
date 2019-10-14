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
-- Purpose:
--    Deflate compression.
--
------------------------------------------------------------------------

with Utility;                    use Utility;
with Utility.Bit_Arrays;         use Utility.Bit_Arrays;


package Deflate is

   BFINAL_0                : constant Bit := 0;
   BFINAL_1                : constant Bit := 1;

   subtype BTYPE_Type is Bit_Array (0 .. 1);
   BTYPE_No_Compression    : constant BTYPE_Type := (0, 0);
   BTYPE_Fixed_Huffman     : constant BTYPE_Type := (0, 1);
   BTYPE_Dynamic_Huffman   : constant BTYPE_Type := (1, 0);

   procedure Run_Demo;

end Deflate;
