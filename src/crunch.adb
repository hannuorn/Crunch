pragma Assertion_Policy(Check);

with Test_Utility.Test_Dynamic_Arrays;
with Deflate; use Deflate;
with Deflate.Huffman;
with Deflate.Fixed_Huffman;
with Utility.Dynamic_Arrays;
with Ada.Text_IO; use Ada.Text_IO;


   procedure Crunch is
   
      procedure Test_Crunch is
      
      begin
         Put_Line("Test_Crunch...");
         Test_Utility.Test_Dynamic_Arrays.Test;
      end Test_Crunch;
   
   
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
      Test_Crunch;
      Put_Line("");
      Put_Line("Demonstrating RFC 3.2.2.");
      Put_Line("Alphabet is ABCDEFGH");
      Put_Line("Building Huffman tree from bit lengths (3, 3, 3, 3, 3, 2, 4, 4)");
      HT.Build((3, 3, 3, 3, 3, 2, 4, 4));
      Put_Line("Codes in the tree:");
      Put_Line("");
      D := Code_Values(HT);
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
            HC.Set(B(B'First + D(S).Length .. B'Last));
         end;
      end loop;
      Put_Line("");
      Put_Line("");
      Put_Line("Brilliant!");
      Put_Line("Goodbye.");
   end Crunch;
