------------------------------------------------------------------------
--
--       Copyright (c) 2019, Hannu Örn
--       All rights reserved.
--
-- Author: Hannu Örn
--
------------------------------------------------------------------------

with Utility.Test;            use Utility.Test;
                              use Utility;
with Utility.Bits_and_Bytes;  use Utility.Bits_and_Bytes;
with Deflate.Huffman;


package body Test_Deflate.Test_Huffman is

   package Byte_Huffman is
         new Deflate.Huffman(Byte); use Byte_Huffman;
   package Character_Huffman is
         new Deflate.Huffman(Character); use Character_Huffman;


   procedure Basic_Test is

      Weights           : Byte_Huffman.Letter_Weights;
      Lengths           : Byte_Huffman.Huffman_Lengths(Byte);
      Codewords         : Byte_Huffman.Huffman_Codewords;
      HC                : Byte_Huffman.Huffman_Code;
      
   begin
      Begin_Test("Basic_Test");
      
      -- Even distribution should make every codeword 8 bits long.
      Weights := (others => 1);
      HC.Build(Weights);
      Lengths := HC.Get_Lengths;
      Codewords := HC.Get_Codewords;
      for L in Lengths'Range loop
         Assert_Equals(Natural(Lengths(L)), 8, "Lengths(L), L = " & Byte'Image(L));
         Assert_Equals(Codewords(L).Length, 8, "Codewords(L).Length, " &
                         "Codeword = """ & Byte_Huffman.To_String(Codewords(L)) &
                       """");
         declare
            S        : String := Byte_Huffman.To_String(Codewords(L));
         begin
            Assert(S'Length = 8, "To_String'Length = 8, S = """ & S & """");
         end;
      end loop;

      -- Same thing with a limited length 8 code.
      HC.Build_Length_Limited(Length_Max => 8, Weights => Weights);
      Lengths := HC.Get_Lengths;
      Codewords := HC.Get_Codewords;
      for L in Lengths'Range loop
         Assert_Equals(Natural(Lengths(L)), 8, "Lengths(L), L = " & Byte'Image(L));
         Assert_Equals(Codewords(L).Length, 8, "Codewords(L).Length, " &
                         "Codeword = """ & Byte_Huffman.To_String(Codewords(L)) &
                       """");
         declare
            S        : String := Byte_Huffman.To_String(Codewords(L));
         begin
            Assert(S'Length = 8, "To_String'Length = 8, S = """ & S & """");
         end;
      end loop;
      
      -- Same thing with a code built using codeword lengths.
      HC := Build(Lengths);
      Lengths := HC.Get_Lengths;
      Codewords := HC.Get_Codewords;
      for L in Lengths'Range loop
         Assert_Equals(Natural(Lengths(L)), 8, "Lengths(L), L = " & Byte'Image(L));
         Assert_Equals(Codewords(L).Length, 8, "Codewords(L).Length, " &
                         "Codeword = """ & Byte_Huffman.To_String(Codewords(L)) &
                       """");
         declare
            S        : String := Byte_Huffman.To_String(Codewords(L));
         begin
            Assert(S'Length = 8, "To_String'Length = 8, S = """ & S & """");
         end;
      end loop;

      End_Test;
   end Basic_Test;
   
   
   procedure Test is
   
   begin
      Begin_Test("Huffman");
      
      Basic_Test;
      
      End_Test;
   end Test;

end Test_Deflate.Test_Huffman;
