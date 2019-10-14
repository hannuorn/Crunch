------------------------------------------------------------------------
--
--       Copyright (c) 2019, Hannu �rn
--       All rights reserved.
--
-- Author: Hannu �rn
--
------------------------------------------------------------------------

------------------------------------------------------------------------
--
-- package Deflate.Demo
-- 
-- Purpose:
--    Routines for testing and demonstration purposes.
--
------------------------------------------------------------------------

private package Deflate.Demo is

   procedure Demo_Huffman_Tree_Building;
   
   procedure Demo_Bit_Lengths_to_Huffman_Tree;
   
   procedure Demo_Huffman_Coding
     (Input             : in     Dynamic_Bit_Array);

end Deflate.Demo;
