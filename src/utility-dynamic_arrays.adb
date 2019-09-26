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
-- package Utility.Dynamic_Arrays
-- 
-- Implementation Notes:
--    This package is a very simple implementation of a variable-length
--    array. It stores the array in the heap and doubles its capacity
--    whenever more space is needed. Ada.Finalization is used to
--    handle copying and finalizing. 
--
------------------------------------------------------------------------


with Ada.Unchecked_Deallocation;


package body Utility.Dynamic_Arrays is

   procedure Free is new Ada.Unchecked_Deallocation
      (Fixed_Array, Fixed_Array_Access);


   ---------------------------------------------------------------------
   -- Initialize
   --
   -- Implementation Notes:
   --    This is an override for Ada.Finalization.
   --    An initial heap storage is allocated for the array.
   --    Please note that the initial size of the array can be 0.
   ---------------------------------------------------------------------
   procedure Initialize
     (Object            : in out Dynamic_Array) is
      
   begin
      Object.Data := new Fixed_Array
        (Index_Type'First .. Index_Type'Val
           (Index_Type'Pos(Index_Type'First) + Initial_Size - 1));
      Object.Length := 0;
   end Initialize;


   ---------------------------------------------------------------------
   -- Adjust
   --
   -- Implementation Notes:
   --    This is an override for Ada.Finalization.
   --    Adjust makes a copy of the heap-stored data.
   ---------------------------------------------------------------------
   procedure Adjust
     (Object            : in out Dynamic_Array) is
      
      New_Data          : Fixed_Array_Access;
      
   begin
      New_Data := new Fixed_Array(Object.Data'Range);
      if not Object.Is_Empty then
         New_Data.all := Object.Data.all;
      end if;
      Object.Data := New_Data;
   end Adjust;


   ---------------------------------------------------------------------
   -- Finalize
   --
   -- Implementation Notes:
   --    This is an override for Ada.Finalization.
   --    Finalize deallocates the data from the heap.
   ---------------------------------------------------------------------
   procedure Finalize
     (Object            : in out Dynamic_Array) is
      
   begin
      Free(Object.Data);
   end Finalize;


   function "="
     (Left              : in     Dynamic_Array;
      Right             : in     Dynamic_Array)
                          return Boolean is

   begin
      if Left.Length = Right.Length then
         if Left.Length = 0 then
            return TRUE;
         elsif Left.First = Right.First then
            return Left.Data.all = Right.Data.all;
         else
            return FALSE;
         end if;
      else
         return FALSE;
      end if;
   end "=";


   function Get
     (This              : in     Dynamic_Array)
                          return Fixed_Array is
      
   begin
      if This.Is_Empty then
         return Empty_Fixed_Array;
      else
         return This.Data (This.First .. This.Last);
      end if;
   end Get;


   ---------------------------------------------------------------------
   -- Set
   --
   -- Implementation Notes:
   --    This procedure destroys the old data and allocates new storage
   --    for the new data.
   ---------------------------------------------------------------------
   procedure Set
     (This              : in out Dynamic_Array;
      From              : in     Fixed_Array) is
      
   begin
      Free(This.Data);
      This.Data := new Fixed_Array(From'Range);
      This.Data.all := From;
      This.Length := From'Length;
   end Set;

   
   function Length
     (This              : in     Dynamic_Array)
                          return Natural_64 is
      
   begin
      return This.Length;
   end Length;

   
   function Is_Empty
     (This              : in     Dynamic_Array)
                          return Boolean is
      
   begin
      return This.Length = 0;
   end Is_Empty;
   
   
   function First
     (This              : in     Dynamic_Array)
                          return Index_Type is
      
   begin
      return This.Data'First;
   end First;
   
   
   function Last
     (This              : in     Dynamic_Array)
                          return Index_Type is
      
   begin
      return Index_Type'Val
        (Index_Type'Pos(This.First) + This.Length - 1);
   end Last;
   
   
   function Get
     (This              : in     Dynamic_Array;
      Index             : in     Index_Type)
                          return Component_Type is
      
   begin
      return This.Data (Index);
   end Get;

   
   procedure Set
     (This              : in out Dynamic_Array;
      Index             : in	Index_Type;
      Value             : in	Component_Type) is
      
   begin
      This.Data (Index) := Value;
   end Set;
   
   
   ---------------------------------------------------------------------
   -- Enlarge
   --
   -- Implementation Notes:
   --    This procedure will not change the dynamic array from the
   --    user's point of view. It just increases the storage space.
   --    If the old size was 0, the new size will be 1.
   --    Otherwise the new size is twice the old size.
   ---------------------------------------------------------------------
   procedure Enlarge
     (This              : in out Dynamic_Array) is
      
      Old_Size          : constant Natural_64 := This.Data'Length;
      New_Size          : Natural_64;
      New_Max_Index     : Index_Type;
      New_Data          : Fixed_Array_Access;
      
   begin
      if Old_Size = 0 then
         New_Data := new Fixed_Array (Index_Type'First .. Index_Type'First);
      else
         New_Size := 2 * Old_Size;
         New_Max_Index := Index_Type'Val
           (Index_Type'Pos(This.First) + New_Size - 1);
         New_Data := new Fixed_Array(This.First .. New_Max_Index);
         New_Data (This.First .. This.Last) := 
            This.Data (This.First .. This.Last);
      end if;
      Free(This.Data);
      This.Data := New_Data;
   end Enlarge;


   ---------------------------------------------------------------------
   -- No_Free_Space
   --
   -- Implementation Notes:
   --    This function returns TRUE if the storage space is entirely
   --    used up.
   ---------------------------------------------------------------------
   function No_Free_Space
     (This              : in     Dynamic_Array)
                          return Boolean is

   begin
      return This.Length = This.Data'Length;
   end No_Free_Space;


   ---------------------------------------------------------------------
   -- Add
   --
   -- Implementation Notes:
   --    This procedure allocates more space when necessary.
   ---------------------------------------------------------------------
   procedure Add
     (This              : in out Dynamic_Array;
      Value             : in     Component_Type) is
      
   begin
      if No_Free_Space(This) then
         Enlarge(This);
      end if;
      This.Length := This.Length + 1;
      This.Data (This.Last) := Value;
   end Add;


   procedure Add
     (This              : in out Dynamic_Array;
      Values            : in     Fixed_Array) is
      
   begin
      for I in Values'Range loop
         Add(This, Values(I));
      end loop;
   end Add;
      

   procedure Add
     (This              : in out Dynamic_Array;
      Values            : in     Dynamic_Array) is
      
   begin
      Add(This, Get(Values));
   end Add;

end Utility.Dynamic_Arrays;
