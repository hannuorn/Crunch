with Ada.Assertions;
with Ada.Text_IO;       use Ada.Text_IO;
with Utility.Test;      use Utility.Test;


package body Deflate.Literals_Only_Huffman is

   package Code_Length_Huffman is
         new Deflate.Huffman(Literals_Only_Huffman.Limited_Bit_Length, 7);



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



   procedure Encode_Huffman_Code
     (Output            : in out Dynamic_Bit_Array;
      Code              : in     Literals_Only_Huffman.Huffman_Code) is

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

      LO_Code_Lengths   : Literals_Only_Huffman.Huffman_Lengths := Code.Get_Lengths;
      Code_Len_Counts   : Code_Length_Huffman.Letter_Weights;
      Len               : Literals_Only_Huffman.Limited_Bit_Length;
      CLC               : Code_Length_Huffman.Huffman_Code;
      CLC_Codewords     : Code_Length_Huffman.Huffman_Codewords;
      CLC_Lengths       : Code_Length_Huffman.Huffman_Lengths
                              (Literals_Only_Huffman.Limited_Bit_Length);

   begin
      -- Count code lengths
      for B in LO_Code_Lengths'Range loop
         Len := LO_Code_Lengths(B);
         Code_Len_Counts(Len) := Code_Len_Counts(Len) + 1;
      end loop;
      -- 0 needs to be included in the alphabet
      if Code_Len_Counts(0) = 0 then
         Code_Len_Counts(0) := 1;
      end if;

      CLC.Build_Length_Limited
        (Length_Max => 7, Weights => Code_Len_Counts);
      CLC_Codewords := CLC.Get_Codewords;
      CLC_Lengths := CLC.Get_Lengths;


      -- HLIT = 0  (257)
      Output.Add((1 .. 5 => 0));
      -- HDIST = 0  (1)
      Output.Add((1 .. 5 => 0));
      -- HCLEN = 15  (19)
      Output.Add((1 .. 4 => 1));
      -- Code length 0 for 16, 17, 18
      Output.Add((1 .. 3 * 3 => 0));
      -- RFC defines the order: 16, 17, 18,
      --    0, 8, 7, 9, 6, 10, 5, 11, 4, 12, 3, 13, 2, 14, 1, 15
      Output.Add(CLC_Length_to_3_Bits(CLC_Lengths(0)));
      Output.Add(CLC_Length_to_3_Bits(CLC_Lengths(8)));
      Output.Add(CLC_Length_to_3_Bits(CLC_Lengths(7)));
      Output.Add(CLC_Length_to_3_Bits(CLC_Lengths(9)));
      Output.Add(CLC_Length_to_3_Bits(CLC_Lengths(6)));
      Output.Add(CLC_Length_to_3_Bits(CLC_Lengths(10)));
      Output.Add(CLC_Length_to_3_Bits(CLC_Lengths(5)));
      Output.Add(CLC_Length_to_3_Bits(CLC_Lengths(11)));
      Output.Add(CLC_Length_to_3_Bits(CLC_Lengths(4)));
      Output.Add(CLC_Length_to_3_Bits(CLC_Lengths(12)));
      Output.Add(CLC_Length_to_3_Bits(CLC_Lengths(3)));
      Output.Add(CLC_Length_to_3_Bits(CLC_Lengths(13)));
      Output.Add(CLC_Length_to_3_Bits(CLC_Lengths(2)));
      Output.Add(CLC_Length_to_3_Bits(CLC_Lengths(14)));
      Output.Add(CLC_Length_to_3_Bits(CLC_Lengths(1)));
      Output.Add(CLC_Length_to_3_Bits(CLC_Lengths(15)));

      for I in LO_Code_Lengths'Range loop
         Output.Add(CLC_Codewords(LO_Code_Lengths(I)));
      end loop;

      -- One distance code of zero bits (means no distance codes used)
      Output.Add(CLC_Codewords(0));
   end Encode_Huffman_Code;


   procedure Make_Single_Block
     (Input             : in     Dynamic_Bit_Array;
      Output            : out    Dynamic_Bit_Array) is

      use Literals_Only_Huffman;
      use Dynamic_Bit_Arrays;

      Weights           : Letter_Weights;
      HC                : Huffman_Code;
      HC_Codewords      : Huffman_Codewords;
      C                 : Natural_64;
      B                 : Byte;

   begin
      Count_Weights(Input, Weights);
      Weights(End_of_Block) := 1;
      Build_Length_Limited(HC, 15, Weights);
      HC_Codewords := HC.Get_Codewords;

      -- Block header: BFINAL = 1, BTYPE = 10  (dynamic Huffman)
      Output.Add(BFINAL_1);
      Output.Add(BTYPE_Dynamic_Huffman);

      Encode_Huffman_Code(Output, HC);

      Output.Expect_Size(Input.Length);
      C := Input.First;
      while C < Input.Last loop
         Read_Byte(Input, C, B);
         Output.Add(HC_Codewords(Literals_Only_Alphabet(B)));
      end loop;

      Output.Add(HC_Codewords(End_of_Block));
   end Make_Single_Block;


   procedure Decompress_Single_Block
     (Input             : in     Dynamic_Bit_Array;
      Output            : out    Dynamic_Bit_Array) is

      use Dynamic_Bit_Arrays;

      subtype Bits_3 is Bit_Array (1 .. 3);

      function Bits_3_to_CLC_Length
        (B3                : in     Bits_3)
         return Code_Length_Huffman.Limited_Bit_Length is

         use Code_Length_Huffman;
      begin
         return
               4 * Bit_Length(B3 (1)) +
               2 * Bit_Length(B3 (2)) +
               1 * Bit_Length(B3 (3));
      end Bits_3_to_CLC_Length;

      use Literals_Only_Huffman;

      C                 : Natural_64;
      B1                : Bit;
      B2                : Bit_Array (1 .. 2);
      B3                : Bits_3;
      B4                : Bit_Array (1 .. 4);
      B5                : Bit_Array (1 .. 5);
      CLC_Lengths       : Code_Length_Huffman.Huffman_Lengths
                              (Literals_Only_Huffman.Limited_Bit_Length);
      CLC               : Code_Length_Huffman.Huffman_Code;
      Found             : Boolean;
      L                 : Literals_Only_Huffman.Limited_Bit_Length;
      Lengths           : Literals_Only_Huffman.Huffman_Lengths(Literals_Only_Alphabet);
      HC                : Literals_Only_Huffman.Huffman_Code;
      LO                : Literals_Only_Alphabet;
      X                 : Natural_64;

   begin
      Output := Dynamic_Bit_Arrays.Empty_Dynamic_Array;
      C := Input.First;

      Input.Read(C, B1);
      Assert(B1 = BFINAL_1);

      Input.Read(C, B2);
      Assert(B2 = BTYPE_Dynamic_Huffman);

      -- HLIT = 0
      Input.Read(C, B5);
      Assert(B5 = (1 .. 5 => 0));

      -- HDIST = 0
      Input.Read(C, B5);
      Assert(B5 = (1 .. 5 => 0));

      -- HCLEN = 15
      Input.Read(C, B4);
      Assert(B4 = (1 .. 4 => 1));

      -- 16, 17, 18
      Input.Read(C, B3);
      Assert(B3 = (1 .. 3 => 0));
      Input.Read(C, B3);
      Assert(B3 = (1 .. 3 => 0));
      Input.Read(C, B3);
      Assert(B3 = (1 .. 3 => 0));

      -- 0, 8, 7, 9, 6, 10, 5, 11, 4, 12, 3, 13, 2, 14, 1, 15
      Input.Read(C, B3);
      CLC_Lengths(0) := Bits_3_to_CLC_Length(B3);
      Input.Read(C, B3);
      CLC_Lengths(8) := Bits_3_to_CLC_Length(B3);
      Input.Read(C, B3);
      CLC_Lengths(7) := Bits_3_to_CLC_Length(B3);
      Input.Read(C, B3);
      CLC_Lengths(9) := Bits_3_to_CLC_Length(B3);
      Input.Read(C, B3);
      CLC_Lengths(6) := Bits_3_to_CLC_Length(B3);
      Input.Read(C, B3);
      CLC_Lengths(10) := Bits_3_to_CLC_Length(B3);
      Input.Read(C, B3);
      CLC_Lengths(5) := Bits_3_to_CLC_Length(B3);
      Input.Read(C, B3);
      CLC_Lengths(11) := Bits_3_to_CLC_Length(B3);
      Input.Read(C, B3);
      CLC_Lengths(4) := Bits_3_to_CLC_Length(B3);
      Input.Read(C, B3);
      CLC_Lengths(12) := Bits_3_to_CLC_Length(B3);
      Input.Read(C, B3);
      CLC_Lengths(3) := Bits_3_to_CLC_Length(B3);
      Input.Read(C, B3);
      CLC_Lengths(13) := Bits_3_to_CLC_Length(B3);
      Input.Read(C, B3);
      CLC_Lengths(2) := Bits_3_to_CLC_Length(B3);
      Input.Read(C, B3);
      CLC_Lengths(14) := Bits_3_to_CLC_Length(B3);
      Input.Read(C, B3);
      CLC_Lengths(1) := Bits_3_to_CLC_Length(B3);
      Input.Read(C, B3);
      CLC_Lengths(15) := Bits_3_to_CLC_Length(B3);

      CLC.Build(CLC_Lengths);

      for I in Literals_Only_Alphabet'Range loop
         CLC.Find(Input, C, Found, L);
         Assert(Found);
         Lengths(I) := L;
      end loop;

      HC.Build(Lengths);

      -- One distance code of zero
      CLC.Find(Input, C, Found, L);
      Assert(Found);
      Assert(L = 0);

      -- data
      X := 0;
      loop
         HC.Find(Input, C, Found, LO);
         Assert(Found);
         if LO = End_of_Block then
            exit;
         else
            Add(Output, Byte(LO));
            X := X + 1;
         end if;
      end loop;


   exception
      when Ada.Assertions.Assertion_Error =>
         Put_Line("Decompress assertion error...");

   end Decompress_Single_Block;

end Deflate.Literals_Only_Huffman;

