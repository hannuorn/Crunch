------------------------------------------------------------------------
--
--       Copyright (c) 2019, Hannu Örn
--       All rights reserved.
--
-- Author: Hannu Örn
--
------------------------------------------------------------------------

with Ada.Unchecked_Deallocation;


package body Utility.Hash_Tables is


   procedure Initialize
     (Object            : in out Hash_Table) is
     
   begin
      Object.Table := new Hash_Array;
   end Initialize;
   

   procedure Finalize
     (Object            : in out Hash_Table) is
     
     procedure Free is new Ada.Unchecked_Deallocation
       (Hash_Array, Hash_Array_Access);
       
   begin
      Free(Object.Table);
   end Finalize;
   
   
   function Contains
     (This              : in out Hash_Table;
      Key               : in     Key_Type)
                          return Boolean is

   begin
      return This.Table (Hash(Key)).Contains(Key);
   end Contains;
   
   
   function Get
     (This              : in out Hash_Table;
      Key               : in     Key_Type)
                          return Element_Type is

   begin
      return This.Table (Hash(Key)).Get(Key);
   end Get;


   procedure Put
     (This              : in out Hash_Table;
      Key               : in     Key_Type;
      Value             : in     Element_Type) is
      
   begin
      This.Table (Hash(Key)).Put(Key, Value);
   end Put;


   procedure Remove
     (This              : in out Hash_Table;
      Key               : in     Key_Type) is
      
   begin
      This.Table (Hash(Key)).Remove(Key);
   end Remove;

end Utility.Hash_Tables;
