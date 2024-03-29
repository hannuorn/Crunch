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
     (Input             : in     Dynamic_Byte_Array;
      Output            : out    Dynamic_Bit_Array);

   procedure Get_LZ_Text_Results
     (Input             : in     Dynamic_Byte_Array;
      Output            : out    Dynamic_Byte_Array);

end Deflate.Compression;
