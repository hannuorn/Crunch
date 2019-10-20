------------------------------------------------------------------------
--
--       Copyright (c) 2019, Hannu �rn
--       All rights reserved.
--
-- Author: Hannu �rn
--
------------------------------------------------------------------------

package Deflate.Decompression is

   procedure Decompress
     (Input             : in     Dynamic_Bit_Array;
      Output            : out    Dynamic_Byte_Array);

end Deflate.Decompression;
