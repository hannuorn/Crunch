package body Deflate.Literals_Only_Huffman is


   procedure Count_Weights
     (Input             : in     Dynamic_Bit_Array;
      Weights           : out    Literals_Only_Huffman.Letter_Weights) is

      C                 : Natural_64;
      B                 : Byte;
      LO                : Literals_Only_Alphabet;

   begin
      C := Input.First;
      while C < Input.Last loop
         Read_Byte(Input, C, B);
         LO := Literals_Only_Alphabet(B);
         Weights(LO) := Weights(LO) + 1;
      end loop;
   end Count_Weights;


   procedure Add_Huffman_Code
     (Output            : in out Dynamic_Bit_Array;
      Counter           : in out Natural_64;
      Code              : in     Literals_Only_Huffman.Huffman_Code) is

      package Code_Length_Huffman is
        new Deflate.Huffman(Literals_Only_Huffman.Limited_Bit_Length);

      subtype Bits_3 is Bit_Array(1 .. 3);

      function CLC_Length_to_3_Bits
        (Length         : in     Code_Length_Huffman.Limited_Bit_Length)
                          return Bits_3 is

         use type Code_Length_Huffman.Bit_Length;

         Len            : Code_Length_Huffman.Limited_Bit_Length := Length;
         Res            : Bits_3;

      begin
         Res(1) := Bit(Len / 4);
         Len := Len mod 4;
         Res(2) := Bit(Len / 2);
         Len := Len mod 2;
         Res(3) := Bit(Len);
         return Res;
      end CLC_Length_to_3_Bits;

      use Dynamic_Bit_Arrays;

      Byte_Code_Lengths : Byte_Huffman.Huffman_Lengths := Code.Get_Lengths;
      Code_Len_Counts   : Code_Length_Huffman.Letter_Weights;
      Len               : Byte_Huffman.Limited_Bit_Length;
      CLC               : Code_Length_Huffman.Huffman_Code;
      CLC_Lengths       : Code_Length_Huffman.Huffman_Lengths(Byte_Huffman.Limited_Bit_Length);

   begin
      -- Count code lengths
      for B in Byte_Code_Lengths'Range loop
         Len := Byte_Code_Lengths(B);
         Code_Len_Counts(Len) := Code_Len_Counts(Len) + 1;
      end loop;
      CLC.Build_Length_Limited
        (Length_Max => 7, Weights => Code_Len_Counts);
      CLC_Lengths := CLC.Get_Lengths;

      -- HLIT = 257
      Dynamic_Bit_Arrays.Add(Output, (1 .. 5 => 0));
      -- HDIST = 1
      Add(Output, (1 .. 1 => 0));
      -- HCLEN = 19
      Add(Output, (1 .. 4 => 1));
      -- Code length 0 for 16, 17, 18
      Add(Output, (1 .. 3 * 3 => 0));
      -- RFC defines the order: 16, 17, 18,
      --    0, 8, 7, 9, 6, 10, 5, 11, 4, 12, 3, 13, 2, 14, 1, 15
      Add(Output, CLC_Length_to_3_Bits(CLC_Lengths(0)));
      Add(Output, CLC_Length_to_3_Bits(CLC_Lengths(8)));
      Add(Output, CLC_Length_to_3_Bits(CLC_Lengths(7)));
      Add(Output, CLC_Length_to_3_Bits(CLC_Lengths(9)));
      Add(Output, CLC_Length_to_3_Bits(CLC_Lengths(6)));
      Add(Output, CLC_Length_to_3_Bits(CLC_Lengths(10)));
      Add(Output, CLC_Length_to_3_Bits(CLC_Lengths(5)));
      Add(Output, CLC_Length_to_3_Bits(CLC_Lengths(11)));
      Add(Output, CLC_Length_to_3_Bits(CLC_Lengths(4)));
      Add(Output, CLC_Length_to_3_Bits(CLC_Lengths(12)));
      Add(Output, CLC_Length_to_3_Bits(CLC_Lengths(3)));
      Add(Output, CLC_Length_to_3_Bits(CLC_Lengths(13)));
      Add(Output, CLC_Length_to_3_Bits(CLC_Lengths(2)));
      Add(Output, CLC_Length_to_3_Bits(CLC_Lengths(14)));
      Add(Output, CLC_Length_to_3_Bits(CLC_Lengths(1)));
      Add(Output, CLC_Length_to_3_Bits(CLC_Lengths(15)));
   end Add_Huffman_Code;


   procedure Make_Single_Block
     (Input             : in     Dynamic_Bit_Array;
      Output            : out    Dynamic_Bit_Array) is

      use Literals_Only_Huffman;

      Weights           : Letter_Weights;
      HC                : Huffman_Code;
      HC_Codewords      : Huffman_Codewords;
      C                 : Natural_64;
      B                 : Byte;

   begin
      Output := Dynamic_Bit_Arrays.Empty_Dynamic_Array;
      Count_Weights(Input, Weights);
      Weights(256) := 1;
      Build_Length_Limited(HC, 15, Weights);
      HC_Codewords := HC.Get_Codewords;
      Print(HC_Codewords);
      Print(HC);

      Output.Expect_Size(Input.Length);
      C := Input.First;
      while C < Input.Last loop
         Read_Byte(Input, C, B);
         Output.Add(HC_Codewords(Literals_Only_Alphabet(B)));
      end loop;
   end Make_Single_Block;

end Deflate.Literals_Only_Huffman;
