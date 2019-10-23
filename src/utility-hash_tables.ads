with Ada.Finalization;
with Utility.Binary_Search_Trees;


generic
   
   type Hash_Key_Type is (<>);
   
   type Key_Type is private;
   type Element_Type is private;
   
   with function "<"
     (Left, Right       : in     Key_Type)
                          return Boolean;
   
   with function "="
     (Left, Right       : in     Key_Type)
                          return Boolean;

   with function Hash
     (Key               : in     Key_Type)
                          return Hash_Key_Type;


package Utility.Hash_Tables is

   type Hash_Table is tagged limited private;
   
   
   function Contains
     (This              : in out Hash_Table;
      Key               : in     Key_Type)
                          return Boolean;
                          
   function Get
     (This              : in out Hash_Table;
      Key               : in     Key_Type)
                          return Element_Type
      with
         Pre => This.Contains(Key);
         
   procedure Put
     (This              : in out Hash_Table;
      Key               : in     Key_Type;
      Value             : in     Element_Type)
      
      with
         Post => This.Contains(Key);
   
   procedure Remove
     (This              : in out Hash_Table;
      Key               : in     Key_Type)
      
      with
         Post => not This.Contains(Key);
   
private

   package Element_Binary_Trees is new Utility.Binary_Search_Trees
     (Key_Type, Element_Type, "<", "=");
   subtype Element_Binary_Tree is Element_Binary_Trees.Binary_Search_Tree;
   
   type Hash_Array is array (Hash_Key_Type) of Element_Binary_Tree;
   type Hash_Array_Access is access Hash_Array;
   
   type Hash_Table is new Ada.Finalization.Limited_Controlled with
      record
         Table          : Hash_Array_Access;
      end record;
      
      
   procedure Initialize
     (Object            : in out Hash_Table);

   procedure Finalize
     (Object            : in out Hash_Table);
         
end Utility.Hash_Tables;
