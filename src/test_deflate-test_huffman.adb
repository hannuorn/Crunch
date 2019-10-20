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

   
   procedure Test_Case_1 is
      
      type Deflate_Bit_Len is range 0 .. 18;
      package CL_Huffman is new Deflate.Huffman(Deflate_Bit_Len);
      Weights           : CL_Huffman.Letter_Weights;
      CL                : CL_Huffman.Huffman_Code;
      CL_Codewords      : CL_Huffman.Huffman_Codewords;

   begin
      Begin_Test("Test_Case_1");
      Weights :=
        (0  => 21,
         1  => 2,
         2  => 0,
         3  => 2,
         4  => 1,
         5  => 4,
         6  => 2,
         7  => 7,
         8  => 39,
         9  => 99,
         10 => 132,
         11 => 2,
         12 => 2,
         13 => 3,
         14 => 2,
         15 => 0,
         others => 0);
      
      CL.Build_Length_Limited(7, Weights);
      CL_Codewords := CL.Get_Codewords;
      if CL_Codewords(10).Get_Array = (1 => 0) then
         Print("Codeword for letter 10 is 0. All other codewords must start with 1.");
         for I in Deflate_Bit_Len'Range loop
            declare
               Bits     : Bit_Array := CL_Codewords(I).Get_Array;
            begin
               if I /= 10 and Bits'Length > 0 then
                  Assert_Equals
                    (Bits(Bits'First) = 0, FALSE, 
                     "First bit is 0. (Code for letter " & 
                       Deflate_Bit_Len'Image(I) & 
                       " is " & CL_Huffman.To_String(CL_Codewords(I)) & ")");
               end if;
            end;
         end loop;
      end if;
      
      CL.Print;
      
      End_Test;
   end Test_Case_1;
   

   procedure Basic_Test is

      Weights           : Byte_Huffman.Letter_Weights;
      Lengths           : Byte_Huffman.Huffman_Lengths;
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
      Test_Case_1;
      
      End_Test;
   end Test;

end Test_Deflate.Test_Huffman;
