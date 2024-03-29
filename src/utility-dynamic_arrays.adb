------------------------------------------------------------------------
--
--       Copyright (c) 2019, Hannu �rn
--       All rights reserved.
--
-- Author: Hannu �rn
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
      Object.Length := 0;
   end Finalize;


   function Empty_Dynamic_Array return Dynamic_Array is
   
      DA                : Dynamic_Array;
      
   begin
      return DA;
   end Empty_Dynamic_Array;


   ---------------------------------------------------------------------
   -- Enlarge
   --
   -- Implementation Notes:
   --    This procedure will not change the dynamic array from the
   --    user's point of view. It just increases the storage space.
   --    New size will be at least the equal to the argument Size.
   --    If no Size argument is given, the following applies:
   --    If the old size was 0, the new size will be 1.
   --    Otherwise the new size is twice the old size.
   ---------------------------------------------------------------------
   procedure Enlarge
     (This              : in out Dynamic_Array;
      Size              : in     Natural_64 := 0) is
      
      Old_Size          : constant Natural_64 := This.Data'Length;
      New_Size          : Natural_64;
      New_Max_Index     : Index_Type;
      New_Data          : Fixed_Array_Access;
      
   begin
      if Size = 0 then
         if Old_Size = 0 then
            New_Size := 1;
         else
            New_Size := 2 * Old_Size;
         end if;
      else
         New_Size := Natural_64'Max (2 * Old_Size, Size);
      end if;
      New_Max_Index := Index_Type'Val
        (Index_Type'Pos(This.Data'First) + New_Size - 1);
      New_Data := new Fixed_Array(This.Data'First .. New_Max_Index);
      if not This.Is_Empty then
         New_Data (This.First .. This.Last) := 
            This.Data (This.First .. This.Last);
      end if;
      Free(This.Data);
      This.Data := New_Data;
   end Enlarge;


   procedure Expect_Size
     (This              : in out Dynamic_Array;
      Size              : in     Natural_64) is
      
   begin
      Enlarge(This, Size);
   end Expect_Size;
   

   function "="
     (Left              : in     Dynamic_Array;
      Right             : in     Dynamic_Array)
                          return Boolean is

   begin
      if Left.Length = Right.Length then
         if Left.Length = 0 then
            return TRUE;
         elsif Left.First = Right.First then
            return 
                  Left.Data(Left.First .. Left.Last) = 
                  Right.Data(Right.First .. Right.Last);
         else
            return FALSE;
         end if;
      else
         return FALSE;
      end if;
   end "=";


   function Get_Array
     (This              : in     Dynamic_Array)
                          return Fixed_Array is
      
   begin
      if This.Is_Empty then
         return Empty_Fixed_Array;
      else
         return This.Data (This.First .. This.Last);
      end if;
   end Get_Array;


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
      if This.Data'Length = 0 then
         Enlarge(This, Values'Length);
      end if;
      loop
         exit when Index_Type'Pos(This.Data'First) + This.Length + 
           Values'Length - 1 <= Index_Type'Pos(This.Data'Last);
         Enlarge(This);
      end loop;
      This.Data
        (Index_Type'Val(Index_Type'Pos(This.Data'First) + This.Length) ..
         Index_Type'Val(Index_Type'Pos(This.Data'First) + This.Length + 
               Values'Length - 1)) := Values;
      This.Length := This.Length + Values'Length;
   end Add;
      

   procedure Add
     (This              : in out Dynamic_Array;
      Values            : in     Dynamic_Array) is
      
   begin
      if not Values.Is_Empty then
         Add(This, Values.Data (Values.First .. Values.Last));
      end if;
   end Add;


   
   procedure Read
     (This              : in     Dynamic_Array;
      Counter           : in out Index_Type;
      Value             : out    Component_Type) is
      
   begin
      Value := This.Data (Counter);
      Counter := Index_Type'Succ(Counter);
   end Read;
   
   
   procedure Read
     (This              : in     Dynamic_Array;
      Counter           : in out Index_Type;
      Values            : out    Fixed_Array) is
      
   begin
      Values := This.Data (Counter .. Counter + Values'Length - 1);
      Counter := Counter + Values'Length;
   end Read;


   procedure Read
     (This              : in     Dynamic_Array;
      Counter           : in out Index_Type;
      Length            : in     Natural_64;
      Values            : out    Dynamic_Array) is
      
      Result            : Fixed_Array 
        (Counter .. Index_Type'Val(Index_Type'Pos(Counter) + Length - 1));
      
   begin
      Read(This, Counter, Result);
      Set(Values, Result);
   end Read;

   
   procedure Get
     (This              : in     Dynamic_Array;
      Counter           : in     Index_Type;
      Length            : in     Natural_64;
      Values            : out    Dynamic_Array) is
      
      C                 : Index_Type;
      
   begin
      C := Counter;
      Read(This, C, Length, Values);
   end Get;

   
   procedure Get
     (This              : in     Dynamic_Array;
      Counter           : in     Index_Type;
      Values            : out    Fixed_Array) is
      
      C                 : Index_Type;
      
   begin
      C := Counter;
      Read(This, C, Values);
   end Get;
   
end Utility.Dynamic_Arrays;
