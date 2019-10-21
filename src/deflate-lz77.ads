------------------------------------------------------------------------
--
--       Copyright (c) 2019, Hannu Örn
--       All rights reserved.
--
-- Author: Hannu Örn
--
------------------------------------------------------------------------

with Utility;                 use Utility;
with Utility.Binary_Search_Trees;
with Utility.Dynamic_Arrays;
with Utility.Controlled_Accesses;
with Deflate.Literal_Length_and_Distance;
use  Deflate.Literal_Length_and_Distance;


package Deflate.LZ77 is

   type Literal_Length_Distance (Is_Literal : Boolean := TRUE) is
      record
         case Is_Literal is
            when TRUE =>
               Literal              : Byte;
            when FALSE =>
               Length               : Deflate_Length;
               Distance             : Deflate_Distance;
         end case;
      end record;
   
   type LLD_Array is array (Natural_64 range <>) of Literal_Length_Distance;
   
   Empty_LLD_Array            : constant LLD_Array (1 .. 0) := 
     (others => (TRUE, 0));
   
   package Dynamic_LLD_Arrays is new Dynamic_Arrays
     (Component_Type    => Literal_Length_Distance,
      Index_Type        => Natural_64,
      Fixed_Array       => LLD_Array,
      Empty_Fixed_Array => Empty_LLD_Array,
      Initial_Size      => 16);
   
   subtype Dynamic_LLD_Array is Dynamic_LLD_Arrays.Dynamic_Array;

   
   procedure Compress
     (Input             : in     Dynamic_Byte_Array;
      Output            : out    Dynamic_LLD_Array);

   procedure Count_Weights
     (LLDs              : in     Dynamic_LLD_Array;
      LL_Weights        : out    Literal_Length_Huffman.Letter_Weights;
      Distance_Weights  : out    Distance_Huffman.Letter_Weights);

   procedure LLD_Array_to_Bit_Array
     (LLDs              : in     Dynamic_LLD_Array;
      LL_Code           : in     Literal_Length_Huffman.Huffman_Code;
      Distance_Code     : in     Distance_Huffman.Huffman_Code;
      Output            : in out Dynamic_Bit_Array);

   procedure LLD_Array_to_ASCII
     (LLDs              : in     Dynamic_LLD_Array;
      Input             : in     Dynamic_Byte_Array;
      Output            : out    Dynamic_Byte_Array);
   
end Deflate.LZ77;
