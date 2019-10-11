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
with Utility.Bit_Arrays;         use Utility.Bit_Arrays;


generic

   type Symbol is (<>);
   Max_Bit_Length       : Natural := 60;
   
   
package Deflate.Huffman is

   subtype Huffman_Code is Dynamic_Bit_Array;
   type Dictionary is array (Symbol) of Huffman_Code;
   type Bit_Length is new Natural;-- range 0 .. Max_Bit_Length;
   subtype Limited_Bit_Length is Bit_Length range 0 .. Bit_Length(Max_Bit_Length);
   type Bit_Lengths is array (Symbol range <>) of Bit_Length
      with Default_Component_Value => 0;
   type Naturals is array (Symbol range <>) of Natural;
   type Symbol_Frequencies is array (Symbol) of Natural_64
      with Default_Component_Value => 0;

   type Huffman_Tree is tagged private;
   

   function To_String
     (Code              : in     Huffman_Code)
                          return String;
                          
   ---------------------------------------------------------------------
   -- To_Huffman_Code
   --
   -- Purpose:
   --    This function returns an image of code, e.g. "00101".
   ---------------------------------------------------------------------
--   function To_Huffman_Code
--     (N                 : in     Natural;
--      Length            : in     Bit_Length)
--                          return Huffman_Code;
   
   procedure Find
     (HT                : in     Huffman_Tree;
      Code              : in     Huffman_Code;
      Found             : out    Boolean;
      S                 : out    Symbol);
      
   ------------------------------------------------------------------------
   -- Find
   --
   -- Purpose:
   --    Read and decode the next code in a data stream.
   --    Increase the counter accordingly.
   ------------------------------------------------------------------------
   procedure Find
     (Tree              : in     Huffman_Tree;
      Stream            : in     Huffman_Code;
      Counter           : in out Natural_64;
      Found             : out    Boolean;
      S                 : out    Symbol);
      
   ------------------------------------------------------------------------
   -- Build
   --
   -- Purpose:
   --    Build the Huffman tree from an array of code lengths
   --    as per RFC 1951, 3.2.2.
   ------------------------------------------------------------------------
   procedure Build
     (Tree              : out    Huffman_Tree;
      Lengths           : in     Bit_Lengths);
      
   function Build
     (Lengths           : in     Bit_Lengths)
                          return Huffman_Tree;

   ------------------------------------------------------------------------
   -- Get_Bit_Lengths
   --
   -- Purpose:
   --    This function is the reverse of procedure Build above,
   --    returning an array of bit lengths given a Huffman Tree.
   ------------------------------------------------------------------------
   function Get_Bit_Lengths
     (Tree              : in     Huffman_Tree)
                          return Bit_Lengths;

   ------------------------------------------------------------------------
   -- Get_Code_Values
   --
   -- Purpose:
   --    This function returns the dictionary,
   --    an array describing a code for each symbol.
   ------------------------------------------------------------------------
   function Get_Code_Values
     (Tree              : in     Huffman_Tree)
                          return Dictionary;

   ------------------------------------------------------------------------
   -- Build
   --
   -- Purpose:
   --    This procedure builds an optimal Huffman code
   --    given the frequency of each symbol.
   ------------------------------------------------------------------------
   procedure Build
     (Tree              : out    Huffman_Tree;
      Frequencies       : in     Symbol_Frequencies);
   
   procedure Build_Length_Limited
     (Lengths           : out    Bit_Lengths;
      Length_Max        : in     Positive;
      Frequencies       : in     Symbol_Frequencies);
      
   procedure Print
     (Lengths           : in     Bit_Lengths);
     
   procedure Print
     (Tree              : in     Huffman_Tree);
   
   
private

   type Huffman_Tree_Node;
   type Huffman_Tree_Node_Access is access Huffman_Tree_Node;
   type Huffman_Tree_Node is
      record
         Is_Leaf           : Boolean;
         S                 : Symbol;
         Edge_0            : Huffman_Tree_Node_Access;
         Edge_1            : Huffman_Tree_Node_Access;
      end record;
      
   type Huffman_Tree is new Ada.Finalization.Controlled with
      record
         Root              : Huffman_Tree_Node_Access;
         Has_Frequencies   : Boolean := FALSE;
         Frequencies       : Symbol_Frequencies;
         Codes             : Dictionary;
      end record;
      
   procedure Initialize
     (Object            : in out Huffman_Tree);
      
   procedure Adjust
     (Object            : in out Huffman_Tree);
     
   procedure Finalize
     (Object            : in out Huffman_Tree);
      
end Deflate.Huffman;
