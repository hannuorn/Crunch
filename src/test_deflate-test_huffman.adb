with Utility.Test;         use Utility.Test;
                           use Utility;
with Utility.Bit_Arrays;   use Utility.Bit_Arrays;
with Deflate.Huffman;


package body Test_Deflate.Test_Huffman is

   package Byte_Huffman is
         new Deflate.Huffman(Byte); use Byte_Huffman;
   package Character_Huffman is
         new Deflate.Huffman(Character); use Character_Huffman;
   
   
   procedure Test_Build_from_Frequencies is
   
      HT                : Byte_Huffman.Huffman_Tree;
      Freq              : Byte_Huffman.Symbol_Frequencies;
      Char_Freq         : Character_Huffman.Symbol_Frequencies;
      Char_Lengths      : Character_Huffman.Bit_Lengths(Character);
      Char_HT           : Character_Huffman.Huffman_Tree;
      Lengths           : Byte_Huffman.Bit_Lengths(Byte);
   
   begin
      Begin_Test("Build (from frequencies)");
      
      Char_Freq('A') := 5;
      Char_Freq('B') := 10;
      Char_Freq('C') := 15;
      Char_Freq('D') := 20;
      Char_Freq('E') := 20;
      Char_Freq('F') := 30;
      Build_Length_Limited(Char_Lengths, 3, Char_Freq);
      Print(Char_Lengths);
      Char_HT.Build(Char_Lengths);
      Print("3-BIT LIMITED CHARACTER CODE");
      Char_HT.Print;
      
      -- Extreme frequencies and differences between low and high frequencies.
      -- The highest frequency is (2**8 - 1)**6, approx. 2**48
      for I in Freq'Range loop
         Freq(I) := Natural_64(I)**6;
      end loop;
      HT.Build(Freq);
      Print("UNLIMITED-LENGTH CODE");
      HT.Print;
      Print("");
      Build_Length_Limited(Lengths, 15, Freq);
      Print(Lengths);
      Build(HT, Lengths);
      Print("LIMITED-LENGTH CODE");
      HT.Print;
      
      End_Test;
   end Test_Build_from_Frequencies;
   
   
   procedure Test is
   
   begin
      Begin_Test("Huffman");
      Test_Build_from_Frequencies;
      End_Test;
   end Test;

end Test_Deflate.Test_Huffman;
