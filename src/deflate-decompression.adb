------------------------------------------------------------------------
--
--       Copyright (c) 2019, Hannu Örn
--       All rights reserved.
--
-- Author: Hannu Örn
--
------------------------------------------------------------------------

with Utility.Bits_and_Bytes;  use Utility.Bits_and_Bytes;
with Utility.Test;            use Utility.Test;
with Deflate.Literal_Length_and_Distance;
use  Deflate.Literal_Length_and_Distance;
with Deflate.Literals_Only_Huffman;


package body Deflate.Decompression is


   procedure Decompress
     (Input             : in     Dynamic_Bit_Array;
      Output            : out    Dynamic_Byte_Array) is

      C                 : Natural_64;
      BFINAL            : Bit;
      BTYPE             : BTYPE_Type;
      LL_Code           : Literal_Length_Huffman.Huffman_Code;
      Dist_Code         : Distance_Huffman.Huffman_Code;
      Found             : Boolean;
      L                 : Literal_Length_Letter;
      D                 : Distance_Letter;
      Length            : Deflate_Length;
      Distance          : Deflate_Distance;
      B                 : Byte;
      X                 : Natural_64;

   begin
      C := Input.First;

      Input.Read(C, BFINAL);
      Input.Read(C, BTYPE);
      Assert(BFINAL = 1);
      Assert(BTYPE = BTYPE_Dynamic_Huffman);

      Read_Block_Header(Input, C, LL_Code, Dist_Code);

      loop
         LL_Code.Find(Input, C, Found, L);
         Assert(Found);
         exit when L = End_of_Block;
         
         if L in Literal_Letter then
            Output.Add(Byte(L));
         else
            declare
               Extra_L_Bits         : Bit_Array (1 .. Length_Extra_Bits (L));
            begin
               Input.Read(C, Extra_L_Bits);
               Length := Deflate_Length
                  (Natural_64(First_Length(L)) + To_Number(Extra_L_Bits));
               Dist_Code.Find(Input, C, Found, D);
               declare
                  Extra_D_Bits      : Bit_Array (1 .. Distance_Extra_Bits(D));
               begin
                  Input.Read(C, Extra_D_Bits);
                  Distance := Deflate_Distance
                     (Natural_64(First_Distance(D)) + To_Number(Extra_D_Bits));
               end;
            end;
            for I in 0 .. Length - 1 loop
               X := Output.Last + 1 - Natural_64(Distance);
               B := Output.Get(X);
               Output.Add(B);
            end loop;
         end if;
      end loop;
   end Decompress;


end Deflate.Decompression;
