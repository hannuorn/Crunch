------------------------------------------------------------------------
--
--       Copyright (c) 2019, Hannu Örn
--       All rights reserved.
--
-- Author: Hannu Örn
--
------------------------------------------------------------------------

with Ada.Unchecked_Deallocation;


package body Utility.Linked_Lists is

   procedure Free is new Ada.Unchecked_Deallocation
     (LL_Node, LL_Node_Access);


   procedure Initialize
     (Object            : in out Linked_List) is
     
   begin
      null;
   end Initialize;
   
   
   procedure Finalize
     (Object            : in out Linked_List) is
     
      X, Y              : LL_Node_Access;
      
   begin
      X := Object.First;
      while X /= null loop
         Y := X;
         X := X.Next;
         Free(Y);
      end loop;
   end Finalize;


   function Size
     (This              : in     Linked_List)
                          return Natural_64 is

   begin
      return This.Count;
   end Size;


   function Is_Empty
     (This              : in     Linked_List)
                          return Boolean is

   begin
      return This.Count = 0;
   end Is_Empty;


   function Is_Null
     (This              : in     Linked_List_Node)
                          return Boolean is

   begin
      return This.Node = null;
   end Is_Null;
   

   function Value
     (This              : in     Linked_List_Node)
                          return Element_Type is

   begin
      return This.Node.Value;
   end Value;


   function Next
     (This              : in     Linked_List_Node)
                          return Linked_List_Node is

   begin
      return (Node => This.Node.Next);
   end Next;
   
                          
   function Previous
     (This              : in     Linked_List_Node)
                          return Linked_List_Node is

   begin
      return (Node => This.Node.Previous);
   end Previous;
     

   function First
     (This              : in     Linked_List)
                          return Linked_List_Node is

   begin
      return (Node => This.First);
   end First;
   
                          
   function Last
     (This              : in     Linked_List)
                          return Linked_List_Node is

   begin
      return (Node => This.Last);
   end Last;

     
   procedure Add_First
     (This              : in out Linked_List;
      Value             : in     Element_Type) is
      
      X                 : LL_Node_Access;
      
   begin
      X := new LL_Node;
      X.all :=
        (Previous    => null,
         Next        => This.First,
         Value       => Value);
      if This.First /= null then
         This.First.Previous := X;
      end if;
      This.First := X;
      if This.Last = null then
         This.Last := X;
      end if;
      This.Count := This.Count + 1;
   end Add_First;
         
      
   procedure Add_Last
     (This              : in out Linked_List;
      Value             : in     Element_Type) is
      
      X                 : LL_Node_Access;
      
   begin
      X := new LL_Node;
      X.all :=
        (Previous    => This.Last,
         Next        => null,
         Value       => Value);
      if This.Last /= null then
         This.Last.Next := X;
      end if;
      This.Last := X;
      if This.First = null then
         This.First := X;
      end if;
      This.Count := This.Count + 1;
   end Add_Last;


   procedure Get_First
     (This              : in     Linked_List;
      Found             : out    Boolean;
      Value             : out    Element_Type) is
      
   begin
      if This.First = null then
         Found := FALSE;
      else
         Found := TRUE;
         Value := This.First.Value;
      end if;
   end Get_First;
   
      
   procedure Get_and_Remove_First
     (This              : in out Linked_List;
      Found             : out    Boolean;
      Value             : out    Element_Type) is
      
      New_First         : LL_Node_Access;
      
   begin
      if This.First = null then
         Found := FALSE;
      else
         Found := TRUE;
         Value := This.First.Value;
         New_First := This.First.Next;
         if New_First = null then
            This.Last := null;
         else
            New_First.Previous := null;
         end if;
         This.Count := This.Count - 1;
         Free(This.First);
         This.First := New_First;
      end if;
   end Get_and_Remove_First;
   
      
   procedure Get_Last
     (This              : in     Linked_List;
      Found             : out    Boolean;
      Value             : out    Element_Type) is
      
   begin
      if This.Last = null then
         Found := FALSE;
      else
         Found := TRUE;
         Value := This.Last.Value;
      end if;
   end Get_Last;
   
   
   procedure Get_and_Remove_Last
     (This              : in out Linked_List;
      Found             : out    Boolean;
      Value             : out    Element_Type) is
      
      New_Last          : LL_Node_Access;
      
   begin
      if This.Last = null then
         Found := FALSE;
      else
         Found := TRUE;
         Value := This.Last.Value;
         New_Last := This.Last.Previous;
         if New_Last = null then
            This.First := null;
         else
            New_Last.Next := null;
         end if;
         Free(This.Last);
         This.Last := New_Last;
         This.Count := This.Count - 1;
      end if;
   end Get_and_Remove_Last;
      
      
   procedure Remove_First
     (This              : in out Linked_List) is
     
     New_First          : LL_Node_Access;
     
   begin
      if This.First /= null then
         New_First := This.First.Next;
         if New_First = null then
            This.Last := null;
         else
            New_First.Previous := null;
         end if;
         Free(This.First);
         This.First := New_First;
         This.Count := This.Count - 1;
      end if;
   end Remove_First;
   
   
   procedure Remove_Last
     (This              : in out Linked_List) is
        
      New_Last           : LL_Node_Access;
     
   begin
      if This.Last /= null then
         New_Last := This.Last.Previous;
         if New_Last = null then
            This.First := null;
         else
            New_Last.Next := null;
         end if;
         Free(This.Last);
         This.Last := New_Last;
         This.Count := This.Count - 1;
      end if;
   end Remove_Last;
   
end Utility.Linked_Lists;
