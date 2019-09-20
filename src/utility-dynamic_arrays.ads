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
-- Purpose:
--    This generic package defines the class Dynamic_Array.
--    Dynamic array is a variable-length array.
--
-- Effects:
--    - The expected usage is:
--       1. Call Set to store an array
--       2. Call Add to add an element to the end of the array;
--          this can be repeated until no more indices are available
--          or the computer runs out of memory
--       3. Make a copy of a dynamic array by an assign statement
--       4. Call Get to read the contents as an array,
--          or to read a single element from the array
--
-- Performance:
--    The array is stored in the heap.
--    Heap allocation/deallocation and data copying can occur whenever
--    changes are made to the dynamic array.
--    
------------------------------------------------------------------------

with Ada.Finalization;


generic
   
   type Component_Type is private;
   type Index_Type is range <>;
   type Fixed_Array is array (Index_Type range <>) of Component_Type;
   Empty_Fixed_Array    : Fixed_Array;
   Initial_Size         : Natural := 0;

   
package Utility.Dynamic_Arrays is

   type Dynamic_Array is tagged private;
   
   
   function "="
     (Left              : in     Dynamic_Array;
      Right             : in     Dynamic_Array)
                          return Boolean;
   
   ---------------------------------------------------------------------
   -- Get
   --
   -- Purpose:
   --    This function returns the contents of the dynamic array
   --    as a regular array.
   ---------------------------------------------------------------------
   function Get
     (This              : in     Dynamic_Array) 
                          return Fixed_Array;

   
   ---------------------------------------------------------------------
   -- Set
   --
   -- Purpose:
   --    This procedures converts an array into a dynamic array.
   ---------------------------------------------------------------------
   procedure Set
     (This              : in out Dynamic_Array;
      From              : in     Fixed_Array);
   
   
   ---------------------------------------------------------------------
   -- Length
   --
   -- Purpose:
   --    This function returns the length of the array.
   --    The result is equal to Get'Length.
   ---------------------------------------------------------------------
   function Length
     (This              : in	 Dynamic_Array) 
                          return Natural;
   
   
   ---------------------------------------------------------------------
   -- Is_Empty
   --
   -- Purpose:
   --    This function returns TRUE if the length of the array is 0.
   ---------------------------------------------------------------------
   function Is_Empty
     (This              : in	 Dynamic_Array) 
                          return Boolean
      with
         Post => Is_Empty'Result = (This.Length = 0);

 
   ---------------------------------------------------------------------
   -- First
   --
   -- Purpose:
   --    This function returns the first index of the array.
   ---------------------------------------------------------------------
   function First
     (This              : in	 Dynamic_Array) 
                          return Index_Type
      with
         Pre => not This.Is_Empty;

   
   ---------------------------------------------------------------------
   -- First
   --
   -- Purpose:
   --    This function returns the last index of the array.
   ---------------------------------------------------------------------
   function Last
     (This              : in	 Dynamic_Array) 
                          return Index_Type
      with
         Pre => not This.Is_Empty;


   ---------------------------------------------------------------------
   -- Add
   --
   -- Purpose:
   --    This procedure increases the length of the array by 1
   --    and adds the given value as the last element.
   ---------------------------------------------------------------------
   procedure Add
     (This              : in out Dynamic_Array;
      Value             : in     Component_Type);

      
   ---------------------------------------------------------------------
   -- Get
   --
   -- Purpose:
   --    This function returns a given element of the array
   --    The result is equal to Get(This)(Index).
   ---------------------------------------------------------------------
   function Get
     (This              : in out Dynamic_Array;
      Index             : in     Index_Type) 
                          return Component_Type
      with 
         Pre => Index in First(This) .. Last(This);


   ---------------------------------------------------------------------   
   -- Set
   --
   -- Purpose:
   --    This procedure sets the value of a given element of the array.
   ---------------------------------------------------------------------
   procedure Set
     (This              : in out Dynamic_Array;
      Index             : in	 Index_Type;
      Value             : in	 Component_Type)

      with
         Pre => Index in First(This) .. Last(This);

   
private
   
   type Fixed_Array_Access is access Fixed_Array;
   
   type Dynamic_Array is new Ada.Finalization.Controlled with
      record
         Data           : Fixed_Array_Access;
         Length         : Natural;
      end record;
   
   procedure Initialize
     (Object            : in out Dynamic_Array);
   
   procedure Adjust
     (Object            : in out Dynamic_Array);
   
   procedure Finalize
     (Object            : in out Dynamic_Array);

end Utility.Dynamic_Arrays;
