with Ada.Text_IO;             use Ada.Text_IO;
with Utility.Test;            use Utility.Test;


package body Deflate.Literal_Length_and_Distance is



   procedure Length_Value_to_Code
     (Length            : in     Deflate_Length;
      Letter            : out    Length_Letter;
      Extra_Bits        : out    Dynamic_Bit_Array) is

      type Letter_and_Number_of_Extra_Bits is
         record
            L           : Length_Letter;
            EB          : Natural_64;
         end record;

      L_and_Extra       : Letter_and_Number_of_Extra_Bits;

   begin
      case Length is
         when           3        => L_and_Extra := (257, 0);
         when           4        => L_and_Extra := (258, 0);
         when           5        => L_and_Extra := (259, 0);
         when           6        => L_and_Extra := (260, 0);
         when           7        => L_and_Extra := (261, 0);
         when           8        => L_and_Extra := (262, 0);
         when           9        => L_and_Extra := (263, 0);
         when           10       => L_and_Extra := (264, 0);
         when     11 .. 12       => L_and_Extra := (265, 1);
         when     13 .. 14       => L_and_Extra := (266, 1);
         when     15 .. 16       => L_and_Extra := (267, 1);
         when     17 .. 18       => L_and_Extra := (268, 1);
         when     19 .. 22       => L_and_Extra := (269, 2);
         when     23 .. 26       => L_and_Extra := (270, 2);
         when     27 .. 30       => L_and_Extra := (271, 2);
         when     31 .. 34       => L_and_Extra := (272, 2);
         when     35 .. 42       => L_and_Extra := (273, 3);
         when     43 .. 50       => L_and_Extra := (274, 3);
         when     51 .. 58       => L_and_Extra := (275, 3);
         when     59 .. 66       => L_and_Extra := (276, 3);
         when     67 .. 82       => L_and_Extra := (277, 4);
         when     83 .. 98       => L_and_Extra := (278, 4);
         when     99 .. 114      => L_and_Extra := (279, 4);
         when    115 .. 130      => L_and_Extra := (280, 4);
         when    131 .. 162      => L_and_Extra := (281, 5);
         when    163 .. 194      => L_and_Extra := (282, 5);
         when    195 .. 226      => L_and_Extra := (283, 5);
         when    227 .. 257      => L_and_Extra := (284, 5);
         when           258      => L_and_Extra := (285, 0);
      end case;
      Letter := L_and_Extra.L;
      Extra_Bits :=
        To_Bits(N      => Natural_64(Length) - Natural_64(First_Length(L_and_Extra.L)),
                Length => L_and_Extra.EB);
   end Length_Value_to_Code;


   procedure Distance_Value_to_Code
     (Distance          : in     Deflate_Distance;
      Letter            : out    Distance_Letter;
      Extra_Bits        : out    Dynamic_Bit_Array) is

      type Letter_and_Number_of_Extra_Bits is
         record
            L           : Distance_Letter;
            EB          : Natural_64;
         end record;

      L_and_Extra       : Letter_and_Number_of_Extra_Bits;

   begin
      case Distance is
         when           1        => L_and_Extra := (0, 0);
         when           2        => L_and_Extra := (1, 0);
         when           3        => L_and_Extra := (2, 0);
         when           4        => L_and_Extra := (3, 0);
         when      5 .. 6        => L_and_Extra := (4, 1);
         when      7 .. 8        => L_and_Extra := (5, 1);
         when      9 .. 12       => L_and_Extra := (6, 2);
         when     13 .. 16       => L_and_Extra := (7, 2);
         when     17 .. 24       => L_and_Extra := (8, 3);
         when     25 .. 32       => L_and_Extra := (9, 3);
         when     33 .. 48       => L_and_Extra := (10, 4);
         when     49 .. 64       => L_and_Extra := (11, 4);
         when     65 .. 96       => L_and_Extra := (12, 5);
         when     97 .. 128      => L_and_Extra := (13, 5);
         when    129 .. 192      => L_and_Extra := (14, 6);
         when    193 .. 256      => L_and_Extra := (15, 6);
         when    257 .. 384      => L_and_Extra := (16, 7);
         when    385 .. 512      => L_and_Extra := (17, 7);
         when    513 .. 768      => L_and_Extra := (18, 8);
         when    769 .. 1024     => L_and_Extra := (19, 8);
         when   1025 .. 1536     => L_and_Extra := (20, 9);
         when   1537 .. 2048     => L_and_Extra := (21, 9);
         when   2049 .. 3072     => L_and_Extra := (22, 10);
         when   3073 .. 4096     => L_and_Extra := (23, 10);
         when   4097 .. 6144     => L_and_Extra := (24, 11);
         when   6145 .. 8192     => L_and_Extra := (25, 11);
         when   8193 .. 12288    => L_and_Extra := (26, 12);
         when  12289 .. 16384    => L_and_Extra := (27, 12);
         when  16385 .. 24576    => L_and_Extra := (28, 13);
         when  24577 .. 32768    => L_and_Extra := (29, 13);
            -- Deflate64
         when  32769 .. 49152    => L_and_Extra := (30, 14);
         when  49153 .. 65536    => L_and_Extra := (31, 14);
      end case;
      Letter := L_and_Extra.L;
      Extra_Bits :=
        To_Bits(N      => Natural_64(Distance) - Natural_64(First_Distance(L_and_Extra.L)),
                Length => L_and_Extra.EB);
   end Distance_Value_to_Code;


   Max_LLD_Code_Length     : constant := 15;
   Max_CL_Code_Length      : constant := 7;

   type LLD_Code_Length is new Natural range 0 .. Max_LLD_Code_Length;
   type Code_Length_Letter is range 0 .. 18;
   package Code_Length_Huffman is new Deflate.Huffman
     (Code_Length_Letter, Max_CL_Code_Length);


   procedure Read_Block_Header
     (Input                : in     Dynamic_Bit_Array;
      C                    : in out Natural_64;
      Literal_Length_Code  : out    Literal_Length_Huffman.Huffman_Code;
      Distance_Code        : out    Distance_Huffman.Huffman_Code) is

      use Code_Length_Huffman;

      CL_Lengths           : Code_Length_Huffman.Huffman_Lengths;
      CL_Code              : Code_Length_Huffman.Huffman_Code;
      HLIT                 : Bit_Array (1 .. 5);
      HDIST                : Bit_Array (1 .. 5);
      HCLEN                : Bit_Array (1 .. 4);
      B3                   : Bit_Array (1 .. 3);
      L                    : Code_Length_Letter;
      Found                : Boolean;
      LL_Lengths           : Literal_Length_Huffman.Huffman_Lengths;
      Dist_Lengths         : Distance_Huffman.Huffman_Lengths;
      Next_CL_Letter       : Code_Length_Letter;
      N                    : Natural_64;
      Number_of_CL_Codewords  : Natural_64;

   begin
      Input.Read(C, HLIT);
      Input.Read(C, HDIST);
      Input.Read(C, HCLEN);

      Next_CL_Letter := 16;
      N := 0;

      Number_of_CL_Codewords := To_Number(HCLEN) + 4;
      while N < Number_of_CL_Codewords loop
         N := N + 1;
         Input.Read(C, B3);
         CL_Lengths(Next_CL_Letter) := Huffman_Length(To_Number(B3));
         case Next_CL_Letter is
            when 16  => Next_CL_Letter := 17;
            when 17  => Next_CL_Letter := 18;
            when 18  => Next_CL_Letter := 0;
            when 0   => Next_CL_Letter := 8;
            when 8   => Next_CL_Letter := 7;
            when 7   => Next_CL_Letter := 9;
            when 9   => Next_CL_Letter := 6;
            when 6   => Next_CL_Letter := 10;
            when 10  => Next_CL_Letter := 5;
            when 5   => Next_CL_Letter := 11;
            when 11  => Next_CL_Letter := 4;
            when 4   => Next_CL_Letter := 12;
            when 12  => Next_CL_Letter := 3;
            when 3   => Next_CL_Letter := 13;
            when 13  => Next_CL_Letter := 2;
            when 2   => Next_CL_Letter := 14;
            when 14  => Next_CL_Letter := 1;
            when 1   => Next_CL_Letter := 15;
            when 15  => exit;
         end case;
      end loop;

      CL_Code.Build(CL_Lengths);

      Assert(To_Number(HLIT) + 257 = 286);
      for I in 0 .. To_Number(HLIT) + 257 - 1 loop
         CL_Code.Find(Input, C, Found, L);
         Assert(Found);
         -- Dummy interpretation of only 0 .. 15, repeat functions not used
         -- Therefore L is typecasted to Huffman_Length
         LL_Lengths(Literal_Length_Letter(I)) := Literal_Length_Huffman.Huffman_Length(L);
      end loop;
      
      for I in 0 .. To_Number(HDIST) + 1 - 1 loop
         CL_Code.Find(Input, C, Found, L);
         Dist_Lengths(Distance_Letter(I)) := Distance_Huffman.Huffman_Length(L);
      end loop;
      if To_Number(HDIST) + 1 = 1 and then L = 0 then
         Dist_Lengths := (others => 0);
      end if;
      
      Literal_Length_Code.Build(LL_Lengths);
      Distance_Code.Build(Dist_Lengths);
      
   end Read_Block_Header;


   procedure Write_Block_Header
     (Output               : out    Dynamic_Bit_Array;
      Literal_Length_Code  : in     Literal_Length_Huffman.Huffman_Code;
      Distance_Code        : in     Distance_Huffman.Huffman_Code) is

      use type Literal_Length_Huffman.Huffman_Length;
      use type Distance_Huffman.Huffman_Length;

      LL_Code_Lengths      : constant Literal_Length_Huffman.Huffman_Lengths
        := Literal_Length_Code.Get_Lengths;

      Dist_Code_Lengths    : constant Distance_Huffman.Huffman_Lengths
        := Distance_Code.Get_Lengths;

      Len_Counts           : Code_Length_Huffman.Letter_Weights;
      Len                  : Code_Length_Letter;
      CL_Code              : Code_Length_Huffman.Huffman_Code;
      CL_Codewords         : Code_Length_Huffman.Huffman_Codewords;
      CL_Lengths           : Code_Length_Huffman.Huffman_Lengths;
      HLIT_Value           : Natural_64;
      HDIST_Value          : Natural_64;
      HCLEN_Value          : Natural_64;

   begin
      -- Count code lenghts from both LL and distance codes
      for L in LL_Code_Lengths'Range loop
         Len := Code_Length_Letter(LL_Code_Lengths(L));
         Len_Counts(Len) := Len_Counts(Len) + 1;
      end loop;

      for L in Dist_Code_Lengths'Range loop
         Len := Code_Length_Letter(Dist_Code_Lengths(L));
         Len_Counts(Len) := Len_Counts(Len) + 1;
      end loop;

      -- 0 needs to be included in the code length code
      if Len_Counts(0) = 0 then
         Len_Counts(0) := 1;
      end if;

      -- Build the code length code
      CL_Code.Build_Length_Limited(Max_CL_Code_Length, Len_Counts);
      CL_Codewords := CL_Code.Get_Codewords;
      CL_Lengths := CL_Code.Get_Lengths;

      -- 5 Bits: HLIT, # of Literal/Length codes - 257 (257 - 286)
      -- HLIT_Value := Literal_Length_Code.Number_of_Codewords;
      
      -- For now, we include all letters
      HLIT_Value := 286;
      Output.Add(To_Bits(HLIT_Value - 257, 5));

      -- 5 Bits: HDIST, # of Distance codes - 1        (1 - 32)
      -- One distance code of zero bits means that there are no
      -- distance codes used at all (the data is all literals).

      if Distance_Code.Number_of_Codewords = 0 then
         HDIST_Value := 1;
      else
         HDIST_Value := Distance_Code.Number_of_Codewords;
      end if;
      
      -- For now, we include all letters
      HDIST_Value := 30;
      Output.Add(To_Bits(HDIST_Value - 1, 5));

      -- 4 Bits: HCLEN, # of Code Length codes - 4     (4 - 19)
      HCLEN_Value := CL_Code.Number_of_Codewords;
      -- For now, we include all letters
      HCLEN_Value := 19;

      Output.Add(To_Bits(HCLEN_Value - 4, 4));

      -- (HCLEN + 4) x 3 bits: code lengths for the code length
      --    alphabet given just above, in the order: 16, 17, 18,
      --    0, 8, 7, 9, 6, 10, 5, 11, 4, 12, 3, 13, 2, 14, 1, 15

      -- Codes 16, 17, 18 not in use => code lenghts 0
      Output.Add(To_Bits(0, 9));
      Output.Add(To_Bits(Natural_64(CL_Lengths(0)), 3));
      Output.Add(To_Bits(Natural_64(CL_Lengths(8)), 3));
      Output.Add(To_Bits(Natural_64(CL_Lengths(7)), 3));
      Output.Add(To_Bits(Natural_64(CL_Lengths(9)), 3));
      Output.Add(To_Bits(Natural_64(CL_Lengths(6)), 3));
      Output.Add(To_Bits(Natural_64(CL_Lengths(10)), 3));
      Output.Add(To_Bits(Natural_64(CL_Lengths(5)), 3));
      Output.Add(To_Bits(Natural_64(CL_Lengths(11)), 3));
      Output.Add(To_Bits(Natural_64(CL_Lengths(4)), 3));
      Output.Add(To_Bits(Natural_64(CL_Lengths(12)), 3));
      Output.Add(To_Bits(Natural_64(CL_Lengths(3)), 3));
      Output.Add(To_Bits(Natural_64(CL_Lengths(13)), 3));
      Output.Add(To_Bits(Natural_64(CL_Lengths(2)), 3));
      Output.Add(To_Bits(Natural_64(CL_Lengths(14)), 3));
      Output.Add(To_Bits(Natural_64(CL_Lengths(1)), 3));
      Output.Add(To_Bits(Natural_64(CL_Lengths(15)), 3));

      -- HLIT + 257 code lengths for the literal/length alphabet,
      --    encoded using the code length Huffman code

      for L in Literal_Length_Letter loop
         Assert(not CL_Codewords(Code_Length_Letter(LL_Code_Lengths(L))).Is_Empty);
         Output.Add(CL_Codewords(Code_Length_Letter(LL_Code_Lengths(L))));
      end loop;

      -- HDIST + 1 code lengths for the distance alphabet,
      --    encoded using the code length Huffman code

      -- One distance code of zero bits means that there are no
      -- distance codes used at all (the data is all literals).

      for L in Distance_Letter loop
         Output.Add(CL_Codewords(Code_Length_Letter(Dist_Code_Lengths(L))));
      end loop;

   end Write_Block_Header;

end Deflate.Literal_Length_and_Distance;
