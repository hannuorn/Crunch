------------------------------------------------------------------------
--
--       Copyright (c) 2019, Hannu Örn
--       All rights reserved.
--
-- Author: Hannu Örn
--
------------------------------------------------------------------------

with Ada.Finalization;


generic
   
   type Element_Type is private;
   
   
package Utility.Linked_Lists is

   type Linked_List is tagged limited private;

   type Linked_List_Node is private;
   
   function Size
     (This              : in     Linked_List)
                          return Natural_64;

   function Is_Empty
     (This              : in     Linked_List)
                          return Boolean
                          
      with
         Post => Is_Empty'Result = (This.Size = 0);

   function Is_Null
     (This              : in     Linked_List_Node)
                          return Boolean;

   function Value
     (This              : in     Linked_List_Node)
                          return Element_Type;

   function Next
     (This              : in     Linked_List_Node)
                          return Linked_List_Node;
                          
   function Previous
     (This              : in     Linked_List_Node)
                          return Linked_List_Node;
                          
   function First
     (This              : in     Linked_List)
                          return Linked_List_Node;
                          
   function Last
     (This              : in     Linked_List)
                          return Linked_List_Node;
                          
   procedure Add_First
     (This              : in out Linked_List;
      Value             : in     Element_Type);
      
   procedure Add_Last
     (This              : in out Linked_List;
      Value             : in     Element_Type);


   procedure Get_First
     (This              : in     Linked_List;
      Found             : out    Boolean;
      Value             : out    Element_Type);
      
   procedure Get_and_Remove_First
     (This              : in out Linked_List;
      Found             : out    Boolean;
      Value             : out    Element_Type);
      
   procedure Get_Last
     (This              : in     Linked_List;
      Found             : out    Boolean;
      Value             : out    Element_Type);
      
   procedure Get_and_Remove_Last
     (This              : in out Linked_List;
      Found             : out    Boolean;
      Value             : out    Element_Type);
      
   procedure Remove_First
     (This              : in out Linked_List);
     
   procedure Remove_Last
     (This              : in out Linked_List);

   
private

   type LL_Node;
   type LL_Node_Access is access LL_Node;
   type LL_Node is
      record
         Previous       : LL_Node_Access;
         Next           : LL_Node_Access;
         Value          : Element_Type;
      end record;
   
   type Linked_List is new Ada.Finalization.Limited_Controlled with
      record
         First                : LL_Node_Access;
         Last                 : LL_Node_Access;
         Count                : Natural_64 := 0;
      end record;
   
   type Linked_List_Node is
      record
         Node                 : LL_Node_Access;
      end record;

      
   procedure Initialize
     (Object            : in out Linked_List);
   
   procedure Finalize
     (Object            : in out Linked_List);

end Utility.Linked_Lists;
