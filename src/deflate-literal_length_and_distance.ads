------------------------------------------------------------------------
--
--       Copyright (c) 2019, Hannu Örn
--       All rights reserved.
--
-- Author: Hannu Örn
--
------------------------------------------------------------------------


------------------------------------------------------------------------
--
-- package Deflate.Literal_Length_and_Distance
--
-- Purpose:
--    Definitions of the fixed Huffman code.
--    Refer to RFC 1951, 3.2.5 and 3.2.6.
--
------------------------------------------------------------------------

with Deflate.Huffman;


package Deflate.Literal_Length_and_Distance is

   type Deflate_Length is range 3 .. 258;
   --   type Deflate_Distance is range 1 .. 32768;
   -- Deflate64:
   type Deflate_Distance is range 1 .. 65536;

   type Literal_Length_Alphabet is range 0 .. 287;
   subtype Literal_Length_Letter is Literal_Length_Alphabet range 0 .. 285;
   subtype Literal_Letter is Literal_Length_Letter range 0 .. 255;
   subtype Length_Letter is Literal_Length_Letter range 257 .. 285;

   -- type Distance_Letter is range 0 .. 29;
   -- Deflate64:
   type Distance_Letter is range 0 .. 31;

   package Literal_Length_Huffman is new Deflate.Huffman
     (Letter_Type    => Literal_Length_Alphabet,
      Max_Bit_Length => 15);

   package Distance_Huffman is new Deflate.Huffman
     (Letter_Type    => Distance_Letter,
      Max_Bit_Length => 15);


   procedure Length_Value_to_Code
     (Length            : in     Deflate_Length;
      Letter            : out    Length_Letter;
      Extra_Bits        : out    Dynamic_Bit_Array);

   procedure Distance_Value_to_Code
     (Distance          : in     Deflate_Distance;
      Letter            : out    Distance_Letter;
      Extra_Bits        : out    Dynamic_Bit_Array);

   procedure Read_Block_Header
     (Input                : in     Dynamic_Bit_Array;
      C                    : in out Natural_64;
      Literal_Length_Code  : out    Literal_Length_Huffman.Huffman_Code;
      Distance_Code        : out    Distance_Huffman.Huffman_Code);

   procedure Write_Block_Header
     (Output               : out    Dynamic_Bit_Array;
      Literal_Length_Code  : in     Literal_Length_Huffman.Huffman_Code;
      Distance_Code        : in     Distance_Huffman.Huffman_Code);


   -- RFC 3.2.5

   End_of_Block            : constant Literal_Length_Letter := 256;

   Length_Extra_Bits       : constant
     Literal_Length_Huffman.Huffman_Naturals (Length_Letter):=

     (257 .. 264  => 0,
      265 .. 268  => 1,
      269 .. 272  => 2,
      273 .. 276  => 3,
      277 .. 280  => 4,
      281 .. 284  => 5,
      285         => 0);


   First_Length            : constant array (Length_Letter) of Deflate_Length :=

     (257 => 3,
      258 => 4,
      259 => 5,
      260 => 6,
      261 => 7,
      262 => 8,
      263 => 9,
      264 => 10,
      265 => 11,
      266 => 13,
      267 => 15,
      268 => 17,
      269 => 19,
      270 => 23,
      271 => 27,
      272 => 31,
      273 => 35,
      274 => 43,
      275 => 51,
      276 => 59,
      277 => 67,
      278 => 83,
      279 => 99,
      280 => 115,
      281 => 131,
      282 => 163,
      283 => 195,
      284 => 227,
      285 => 258);

   Distance_Extra_Bits     : constant
     Distance_Huffman.Huffman_Naturals (Distance_Letter) :=

     ( 0 .. 3  => 0,
       4 .. 5  => 1,
       6 .. 7  => 2,
       8 .. 9  => 3,
      10 .. 11 => 4,
      12 .. 13 => 5,
      14 .. 15 => 6,
      16 .. 17 => 7,
      18 .. 19 => 8,
      20 .. 21 => 9,
      22 .. 23 => 10,
      24 .. 25 => 11,
      26 .. 27 => 12,
      28 .. 29 => 13,
      30 .. 31 => 14);

   --   Max_Distance            : constant := 32768;
   -- Deflate64:
   Max_Distance            : constant := 65536;

   First_Distance          : constant array (Distance_Letter) of Deflate_Distance :=

     ( 0 => 1,
       1 => 2,
       2 => 3,
       3 => 4,
       4 => 5,
       5 => 7,
       6 => 9,
       7 => 13,
       8 => 17,
       9 => 25,
      10 => 33,
      11 => 49,
      12 => 65,
      13 => 97,
      14 => 129,
      15 => 193,
      16 => 257,
      17 => 385,
      18 => 513,
      19 => 769,
      20 => 1025,
      21 => 1537,
      22 => 2049,
      23 => 3073,
      24 => 4097,
      25 => 6145,
      26 => 8193,
      27 => 12289,
      28 => 16385,
      29 => 24577,
      30 => 32769,
      31 => 49153);


   -- RFC 3.2.6

   Fixed_Huffman_Bit_Lengths  : constant
     Literal_Length_Huffman.Huffman_Lengths :=

     (  0 .. 143  => 8,
      144 .. 255  => 9,
      256 .. 279  => 7,
      280 .. 287  => 8);

end Deflate.Literal_Length_and_Distance;
