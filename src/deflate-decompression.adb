------------------------------------------------------------------------
--
--       Copyright (c) 2019, Hannu Örn
--       All rights reserved.
--
-- Author: Hannu Örn
--
------------------------------------------------------------------------

with Utility.Bit_Arrays;      use Utility.Bit_Arrays;


package body Deflate.Decompression is

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

end Deflate.Decompression;
