with Ada.Text_IO;                use Ada.Text_IO;
with Utility.Bit_Arrays;
with Utility.Dynamic_Arrays;
with Deflate.Huffman;


package body Deflate.Demo is

   procedure Demo_Huffman_Tree_Building is
   
      package Character_Huffman is new Deflate.Huffman(Character);
      use Character_Huffman;
      
      Message        : constant String :=
            "A_DEAD_DAD_CEDED_A_BAD_BABE_A_BEADED_ABACA_BED";
      D              : Dictionary;
      Freq           : Symbol_Frequencies(Character);
      HT             : Huffman_Tree;
      
   begin
      Put_Line("Message = """ & Message & """");
      Put_Line("");
      for I in Message'Range loop
         Freq(Message(I)) := Freq(Message(I)) + 1;
      end loop;
      Build(HT, Freq);
      D := Get_Code_Values(HT);
      Put_Line("Huffman codes:");
      for S in D'Range loop
         if Freq(S) > 0 then
            Put(Character(S));
            Put_Line(" = " & To_String(D(S)));
         end if;
      end loop;
      Put_Line("");
   end Demo_Huffman_Tree_Building;
   
   
   procedure Demo_Bit_Lengths_to_Huffman_Tree is
   
      type Natural_Array is array (Natural range <>) of Natural;
      Empty_Natural_Array : constant Natural_Array (1 .. 0) := (others => 0);
      
      package Dynamic_Natural_Arrays is new Utility.Dynamic_Arrays(
         Natural, Natural, Natural_Array, Empty_Natural_Array);

      type Characters_ABCDEFGH is new Character range 'A' .. 'H';
      package Character_Huffman is new Deflate.Huffman(Characters_ABCDEFGH);
      use Character_Huffman;
      
      DA	         : Dynamic_Natural_Arrays.Dynamic_Array;
      HC          : Huffman_Code;
      HT          : Huffman_Tree;
      D           : Dictionary;
      Found       : Boolean;
      S           : Characters_ABCDEFGH;

   begin
      Put_Line("Crunch");
      Put_Line("");
      Put_Line("Some dumb testing...");
      Put_Line("");
      Put_Line("Demonstrating RFC 3.2.2.");
      Put_Line("Alphabet is ABCDEFGH");
      Put_Line("Building Huffman tree from bit lengths (3, 3, 3, 3, 3, 2, 4, 4)");
      HT.Build(Lengths => (3, 3, 3, 3, 3, 2, 4, 4));
      Put_Line("Codes in the tree:");
      Put_Line("");
      D := Get_Code_Values(HT);
      for S in D'Range loop
         Put(Character(S));
         Put_Line(" = " & To_String(D(S)));
      end loop;
      Put_Line("");
      HC.Set((0, 1, 0, 1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1, 1, 1, 1,
              1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0));
      Put_Line("Coded bits = " & To_String(HC));
      Put("Decoded string: ");
      
      loop
         HT.Find(HC, Found, S);
         exit when not Found;
         Put(Character(S));
         declare
            B     : Bit_Array := HC.Get;
         begin
            HC.Set(B(B'First + Natural_64(D(S).Length) .. B'Last));
         end;
      end loop;
      Put_Line("");
   end Demo_Bit_Lengths_to_Huffman_Tree;


   procedure Demo_Huffman_Coding
     (Input             : in     Dynamic_Bit_Array) is
   
      package Byte_Huffman is new Deflate.Huffman (Utility.Bit_Arrays.Byte);
      use Byte_Huffman;
      
      use Utility.Bit_Arrays.Dynamic_Bit_Arrays;
      
      C                 : Natural_64 := Input.First;
      B                 : Byte;
      Freq              : Byte_Huffman.Symbol_Frequencies(Byte);
      HT                : Byte_Huffman.Huffman_Tree;
      D                 : Byte_Huffman.Dictionary;
      
   begin
      C := Input.First;
      while C <= Input.Last loop
         Read_Byte(Input, C, B);
         Freq(B) := Freq(B) + 1;
      end loop;
      Build(HT, Freq);
      
      D := Get_Code_Values(HT);
      Put_Line("Huffman codes:");
      for S in D'Range loop
         if Freq(S) > 0 then
            Put(Byte'Image(S) & " = '" & Character'Val(S) & "'");
            Put_Line(" = " & To_String(D(S)) & ", freq =" & 
                       Natural_64'Image(Freq(S)) & 
                    ", bit length = " & Natural_64'Image(D(S).Length));
         end if;
      end loop;
      Put_Line("");
   end Demo_Huffman_Coding;
   
end Deflate.Demo;
