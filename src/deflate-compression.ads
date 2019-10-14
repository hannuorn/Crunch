------------------------------------------------------------------------
--
--       Copyright (c) 2019, Hannu �rn
--       All rights reserved.
--
-- Author: Hannu �rn
--
------------------------------------------------------------------------

package Deflate.Compression is

   procedure Compress
     (Input             : in     Dynamic_Bit_Array;
      Output            : out    Dynamic_Bit_Array);

end Deflate.Compression;
