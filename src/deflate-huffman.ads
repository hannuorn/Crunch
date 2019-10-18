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
-- package Deflate.Huffman
-- 
-- Purpose:
--    This generic package implements Huffman codes for 
--    a given alphabet.
--
------------------------------------------------------------------------

with Ada.Finalization;
with Utility.Bits_and_Bytes;     use Utility.Bits_and_Bytes;


generic

   type Letter is (<>);
   Max_Bit_Length       : Natural := 60;
   
   
package Deflate.Huffman is

   subtype Huffman_Codeword is Dynamic_Bit_Arrays.Dynamic_Array;
   type Huffman_Codewords is array (Letter) of Huffman_Codeword;
   type Bit_Length is new Natural;
   subtype Limited_Bit_Length is Bit_Length range 0 .. Bit_Length(Max_Bit_Length);
   type Huffman_Lengths is array (Letter range <>) of Bit_Length
      with Default_Component_Value => 0;
   type Huffman_Naturals is array (Letter range <>) of Natural;
   type Letter_Weights is array (Letter) of Natural_64
      with Default_Component_Value => 0;

   type Huffman_Code is tagged private;


   ------------------------------------------------------------------------
   -- Build
   --
   -- Purpose:
   --    This procedure builds an optimal Huffman code
   --    given the frequency of each letter.
   ------------------------------------------------------------------------
   procedure Build
     (Code              : out    Huffman_Code;
      Weights           : in     Letter_Weights);

   ------------------------------------------------------------------------
   -- Build
   --
   -- Purpose:
   --    This procedure builds an optimal Huffman code
   --    with a specified maximum codeword length.
   ------------------------------------------------------------------------
   procedure Build_Length_Limited
     (Code              : out    Huffman_Code;
      Length_Max        : in     Positive;
      Weights           : in     Letter_Weights);
   
   ------------------------------------------------------------------------
   -- Build
   --
   -- Purpose:
   --    Build the Huffman code from an array of code lengths
   --    as per RFC 1951, 3.2.2.
   ------------------------------------------------------------------------
   procedure Build
     (Code              : out    Huffman_Code;
      Lengths           : in     Huffman_Lengths);
      
   function Build
     (Lengths           : in     Huffman_Lengths)
                          return Huffman_Code;


   function To_String
     (Codeword          : in     Huffman_Codeword)
                          return String;
                          
   ------------------------------------------------------------------------
   -- Find
   --
   -- Purpose:
   --    Read and decode the next code in a data stream.
   --    Increase the counter accordingly.
   ------------------------------------------------------------------------
   procedure Find
     (Code              : in     Huffman_Code;
      Stream            : in     Dynamic_Bit_Array;
      Counter           : in out Natural_64;
      Found             : out    Boolean;
      L                 : out    Letter);
      
 
   function Get_Lengths
     (Code              : in     Huffman_Code)
                          return Huffman_Lengths;

   function Get_Codewords
     (Code              : in     Huffman_Code)
                          return Huffman_Codewords;

   procedure Print
     (Lengths           : in     Huffman_Lengths);
     
   procedure Print
     (Codewords         : in     Huffman_Codewords);
     
   procedure Print
     (Code              : in     Huffman_Code);

   
private

   type Huffman_Tree_Node;
   type Huffman_Tree_Node_Access is access Huffman_Tree_Node;
   type Huffman_Tree_Node is
      record
         Is_Leaf           : Boolean;
         L                 : Letter;
         Edge_0            : Huffman_Tree_Node_Access;
         Edge_1            : Huffman_Tree_Node_Access;
      end record;
      
   type Huffman_Code is new Ada.Finalization.Controlled with
      record
         Has_Weights       : Boolean := FALSE;
         Weights           : Letter_Weights;
         Lengths           : Huffman_Lengths(Letter);
         Codewords         : Huffman_Codewords;
         Tree              : Huffman_Tree_Node_Access;
      end record;

   procedure Initialize
     (Object            : in out Huffman_Code);
      
   procedure Adjust
     (Object            : in out Huffman_Code);
     
   procedure Finalize
     (Object            : in out Huffman_Code);
      
end Deflate.Huffman;
