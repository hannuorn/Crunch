with Ada.Finalization;


generic

   type Symbol is (<>);
   
package Deflate.Huffman is

   subtype Huffman_Code is Dynamic_Bit_Arrays.Dynamic_Array;
   type Dictionary is array (Symbol) of Huffman_Code;
   type Bit_Length is new Natural range 0 .. 16;
   type Bit_Lengths is array (Symbol range <>) of Bit_Length;
   type Naturals is array (Symbol range <>) of Natural;
   type Huffman_Tree is private;
   

   function To_String
     (Code              : in     Huffman_Code)
                          return String;
                          
   function To_Huffman_Code
     (N                 : in     Natural;
      Length            : in     Bit_Length)
                          return Huffman_Code;
   
   procedure Find
     (HT                : in     Huffman_Tree;
      Code              : in     Huffman_Code;
      Found             : out    Boolean;
      S                 : out    Symbol);
      
   procedure Build
     (HT                : out    Huffman_Tree;
      BL                : in     Bit_Lengths);
      
   function Build
     (BL                : in     Bit_Lengths)
                          return Huffman_Tree;
                          
   function Code_Values
     (HT                : in     Huffman_Tree)
                          return Dictionary;
   
   
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
      

end Deflate.Huffman;
