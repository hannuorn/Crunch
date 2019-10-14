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

with Deflate.Demo;               use Deflate.Demo;


package body Deflate is

   procedure Run_Demo is
   
   begin
      Demo_Huffman_Tree_Building;
      Demo_Bit_Lengths_to_Huffman_Tree;
   end Run_Demo;
   
end Deflate;
