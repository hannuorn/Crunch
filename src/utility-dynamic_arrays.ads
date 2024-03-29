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
   Initial_Size         : Natural_64 := 0;

   
package Utility.Dynamic_Arrays is

   type Dynamic_Array is tagged private;
   
   
   procedure Expect_Size
     (This              : in out Dynamic_Array;
      Size              : in     Natural_64);
      
   
   function "="
     (Left              : in     Dynamic_Array;
      Right             : in     Dynamic_Array)
                          return Boolean;
   
   ---------------------------------------------------------------------
   -- Get_Array
   --
   -- Purpose:
   --    This function returns the contents of the dynamic array
   --    as a regular array.
   ---------------------------------------------------------------------
   function Get_Array
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
                          return Natural_64
      with
         Post => Length'Result = This.Get_Array'Length;
   
   
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

   function Empty_Dynamic_Array return Dynamic_Array;
 
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
      Value             : in     Component_Type)
      
      with
         Post => This.Get(Index => This.Last) = Value;


   ---------------------------------------------------------------------
   -- Add
   --
   -- Purpose:
   --    This procedure adds all of the values in Values to the
   --    dynamic array.
   --    
   ---------------------------------------------------------------------
   procedure Add
     (This              : in out Dynamic_Array;
      Values            : in     Fixed_Array)
      
      with
         Post => This.Get(Index => This.Last) = Values(Values'Last);


   procedure Add
     (This              : in out Dynamic_Array;
      Values            : in     Dynamic_Array)
      
      with
         Post =>   This.Get(Index => This.Last) = 
                 Values.Get(Index => Values.Last);

      
   ---------------------------------------------------------------------
   -- Get
   --
   -- Purpose:
   --    This function returns a given element of the array
   --    The result is equal to Get(This)(Index).
   ---------------------------------------------------------------------
   function Get
     (This              : in     Dynamic_Array;
      Index             : in     Index_Type) 
                          return Component_Type
      with 
         Pre => Index in First(This) .. Last(This),
         Post => Get'Result = This.Get_Array (Index);


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
         Pre => Index in First(This) .. Last(This),
         Post => This.Get(Index => Index) = Value;

   
   procedure Read
     (This              : in     Dynamic_Array;
      Counter           : in out Index_Type;
      Value             : out    Component_Type);
   
   procedure Read
     (This              : in     Dynamic_Array;
      Counter           : in out Index_Type;
      Values            : out    Fixed_Array)
     
     with
        Pre => Index_Type'Pos(Counter) + Values'Length - 1 <= Index_Type'Pos(This.Last);
   
   procedure Read
     (This              : in     Dynamic_Array;
      Counter           : in out Index_Type;
      Length            : in     Natural_64;
      Values            : out    Dynamic_Array);

   procedure Get
     (This              : in     Dynamic_Array;
      Counter           : in     Index_Type;
      Length            : in     Natural_64;
      Values            : out    Dynamic_Array);

   procedure Get
     (This              : in     Dynamic_Array;
      Counter           : in     Index_Type;
      Values            : out    Fixed_Array);

   
private
   
   type Fixed_Array_Access is access Fixed_Array;
   
   type Dynamic_Array is new Ada.Finalization.Controlled with
      record
         Data           : Fixed_Array_Access;
         Length         : Natural_64;
      end record;
   
   procedure Initialize
     (Object            : in out Dynamic_Array);
   
   procedure Adjust
     (Object            : in out Dynamic_Array);
   
   procedure Finalize
     (Object            : in out Dynamic_Array);

end Utility.Dynamic_Arrays;
