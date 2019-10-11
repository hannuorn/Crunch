------------------------------------------------------------------------
--
--       Copyright (c) 2019, Hannu Örn
--       All rights reserved.
--
-- Author: Hannu Örn
--
------------------------------------------------------------------------

with Ada.Text_IO;                use Ada.Text_IO;
with Utility.Bit_Arrays;
with Utility.Dynamic_Arrays;
with Deflate.Huffman;


package body Deflate.Demo is

   package Byte_Huffman is
         new Deflate.Huffman(Byte);

   package Character_Huffman is
         new Deflate.Huffman(Character);

   
   -- This example is from Wikipedia, Huffman coding, Basic technique.
   procedure Demo_Huffman_Tree_Building is
   
      use Character_Huffman;
   
      Message           : constant String :=
            "A_DEAD_DAD_CEDED_A_BAD_BABE_A_BEADED_ABACA_BED";
      CW                : Huffman_Codewords;
      Weights           : Letter_Weights;
      HC                : Huffman_Code;
      HT2               : Huffman_Code;
      Lens              : Huffman_Lengths(Character'Range);
      
   begin
      Put_Line("Message = """ & Message & """");
      Put_Line("");
      for I in Message'Range loop
         Weights(Message(I)) := Weights(Message(I)) + 1;
      end loop;
      Build(HC, Weights);
      
      CW := Get_Codewords(HC);
      Put_Line("Huffman codes:");
      for L in CW'Range loop
         if Weights(L) > 0 then
            Put(Character(L));
            Put_Line(" = " & To_String(CW(L)));
         end if;
      end loop;
      
      Put_Line("");
      
      Lens := HC.Get_Lengths;
      Put_Line("Lengths:");
      for L in Lens'Range loop
         if Lens(L) > 0 then
            Put_Line(L & " has length " & Bit_Length'Image(Lens(L)));
         end if;
      end loop;
      HT2.Build(Lens);
      
      CW := Get_Codewords(HT2);
      Put_Line("Huffman codes:");
      for L in CW'Range loop
         if Weights(L) > 0 then
            Put(Character(L));
            Put_Line(" = " & To_String(CW(L)));
         end if;
      end loop;
   end Demo_Huffman_Tree_Building;
   
   
   procedure Demo_Bit_Lengths_to_Huffman_Tree is
   
      -- type Natural_Array is array (Natural range <>) of Natural;
      -- Empty_Natural_Array : constant Natural_Array (1 .. 0) := (others => 0);
      
      -- package Dynamic_Natural_Arrays is new Utility.Dynamic_Arrays(
         -- Natural, Natural, Natural_Array, Empty_Natural_Array);

      -- type Characters_ABCDEFGH is new Character range 'A' .. 'H';
      -- package Character_Huffman is new Deflate.Huffman(Characters_ABCDEFGH);
      -- use Character_Huffman;
      
      -- DA	         : Dynamic_Natural_Arrays.Dynamic_Array;
      -- HC          : Huffman_Code;
      -- CW          : Huffman_Codewords;
      -- Found       : Boolean;
      -- L           : Characters_ABCDEFGH;

   begin
      null;
      -- Put_Line("Some dumb testing...");
      -- Put_Line("");
      -- Put_Line("Demonstrating RFC 3.2.2.");
      -- Put_Line("Alphabet is ABCDEFGH");
      -- Put_Line("Building Huffman tree from bit lengths (3, 3, 3, 3, 3, 2, 4, 4)");
      -- HC.Build(Lengths => (3, 3, 3, 3, 3, 2, 4, 4));
      -- Put_Line("Codes in the tree:");
      -- Put_Line("");
      -- CW := Get_Codewords(HC);
      -- for L in CW'Range loop
         -- Put(Character(L));
         -- Put_Line(" = " & To_String(CW(L)));
      -- end loop;
      -- Put_Line("");
      -- Codeword.Set((0, 1, 0, 1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1, 1, 1, 1,
                    -- 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0));
      -- Put_Line("Coded bits = " & To_String(Codeword));
      -- Put("Decoded string: ");
      
      -- loop
         -- HC.Find(Codeword, Found, L);
         -- exit when not Found;
         -- Put(Character(L));
         -- declare
            -- B     : Bit_Array := HC.Get;
         -- begin
            -- HC.Set(B(B'First + Natural_64(CW(L).Length) .. B'Last));
         -- end;
      -- end loop;
      -- Put_Line("");
      -- HC.Print;
   end Demo_Bit_Lengths_to_Huffman_Tree;


   procedure Demo_Huffman_Coding
     (Input             : in     Dynamic_Bit_Array) is
   
      package Byte_Huffman is new Deflate.Huffman (Utility.Bit_Arrays.Byte);
      use Byte_Huffman;
      
      use Utility.Bit_Arrays.Dynamic_Bit_Arrays;
      
      C                 : Natural_64 := Input.First;
      B                 : Byte;
      Weights           : Byte_Huffman.Letter_Weights;
      HC                : Byte_Huffman.Huffman_Code;
      CW                : Byte_Huffman.Huffman_Codewords;
      
   begin
      C := Input.First;
      while C <= Input.Last loop
         Read_Byte(Input, C, B);
         Weights(B) := Weights(B) + 1;
      end loop;
      Build(HC, Weights);
      
      CW := Get_Codewords(HC);
      Put_Line("Huffman codes:");
      for L in CW'Range loop
         if Weights(L) > 0 then
            Put(Byte'Image(L) & " = '" & Character'Val(L) & "'");
            Put_Line(" = " & To_String(CW(L)) & ", Weights =" & 
                       Natural_64'Image(Weights(L)) & 
                    ", bit length = " & Natural_64'Image(CW(L).Length));
         end if;
      end loop;
      Put_Line("");
   end Demo_Huffman_Coding;


   procedure Demo_Build_from_Frequencies is
   
      use Byte_Huffman;
      use Character_Huffman;
      
      HC                : Byte_Huffman.Huffman_Code;
      Weight            : Byte_Huffman.Letter_Weights;
      Char_Wt           : Character_Huffman.Letter_Weights;
      Char_Lengths      : Character_Huffman.Huffman_Lengths(Character);
      Char_HC           : Character_Huffman.Huffman_Code;
      Lengths           : Byte_Huffman.Huffman_Lengths(Byte);
   
   begin
      Char_Wt('A') := 5;
      Char_Wt('B') := 10;
      Char_Wt('C') := 15;
      Char_Wt('D') := 20;
      Char_Wt('E') := 20;
      Char_Wt('F') := 30;
      Build_Length_Limited(Char_HC, 3, Char_Wt);
      Char_Lengths := Char_HC.Get_Lengths;
      Print(Char_Lengths);
      Char_HC.Build(Char_Lengths);
      Put_Line("3-BIT LIMITED CHARACTER CODE");
      Char_HC.Print;
      
      for I in Weight'Range loop
         Weight(I) := Natural_64(I)**2 + 1;
      end loop;
      Weight(255) := 2**50;
      --HC.Build(Weight);
      --Print("UNLIMITED-LENGTH CODE");
      --HC.Print;
      Put_Line("");
      Build_Length_Limited(HC, 15, Weight);
      Lengths := HC.Get_Lengths;
      --Print(Lengths);
      Build(HC, Lengths);
      Put_Line("LIMITED-LENGTH CODE");
      Put_Line("");
      Print(HC.Get_Codewords);
      HC.Print;
   end Demo_Build_from_Frequencies;
   
end Deflate.Demo;
