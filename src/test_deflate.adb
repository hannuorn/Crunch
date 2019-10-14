------------------------------------------------------------------------
--
--       Copyright (c) 2019, Hannu �rn
--       All rights reserved.
--
-- Author: Hannu �rn
--
------------------------------------------------------------------------

with Utility.Test; use Utility.Test;
with Test_Deflate.Test_Huffman;


package body Test_Deflate is

   procedure Test is
   
   begin
      Begin_Test("Deflate");
      
      Test_Deflate.Test_Huffman.Test;
      
      End_Test;
   end Test;
   
end Test_Deflate;
