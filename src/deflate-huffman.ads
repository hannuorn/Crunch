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
   Max_Bit_Length       : Natural := 16;
   
   
package Deflate.Huffman is

   subtype Huffman_Code is Dynamic_Bit_Array;
   type Dictionary is array (Symbol) of Huffman_Code;
   type Bit_Length is new Natural range 0 .. Max_Bit_Length;
   type Bit_Lengths is array (Symbol range <>) of Bit_Length;
   type Naturals is array (Symbol range <>) of Natural;
   type Symbol_Frequencies is array (Symbol range <>) of Natural_64
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
   
--   procedure Find
--     (HT                : in     Huffman_Tree;
--      Code              : in     Huffman_Code;
--      Found             : out    Boolean;
--      S                 : out    Symbol);
      
   procedure Find
     (Tree              : in     Huffman_Tree;
      Stream            : in     Huffman_Code;
      Counter           : in out Natural_64;
      Found             : out    Boolean;
      S                 : out    Symbol);
      
   procedure Build
     (Tree              : out    Huffman_Tree;
      Lengths           : in     Bit_Lengths);
      
   function Build
     (Lengths           : in     Bit_Lengths)
                          return Huffman_Tree;

   function Get_Bit_Lengths
     (Tree              : in     Huffman_Tree)
                          return Bit_Lengths;

   function Get_Code_Values
     (Tree              : in     Huffman_Tree)
                          return Dictionary;

   procedure Build
     (Tree              : out    Huffman_Tree;
      Frequencies       : in     Symbol_Frequencies);
   
   
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
      end record;
      
   procedure Initialize
     (Object            : in out Huffman_Tree);
      
   procedure Adjust
     (Object            : in out Huffman_Tree);
      

   procedure Finalize
     (Object            : in out Huffman_Tree);
      

end Deflate.Huffman;
