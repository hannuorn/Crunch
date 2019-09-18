-- Dynamic_Array is a class similar to ArrayList in Java.


with Ada.Finalization;


generic
   
   type Component is private;
   type Index is range <>;
   type Fixed_Array is array (Index range <>) of Component;
   Empty_Fixed_Array	: Fixed_Array;
   Initial_Size      : Natural := 1;

   
package Utility.Dynamic_Arrays is

   type Dynamic_Array is tagged private;
   
   
   function Get
     (DA                : in     Dynamic_Array) 
                          return Fixed_Array;
   
   procedure Set
     (DA                : in out Dynamic_Array;
      FA                : in     Fixed_Array);
   
   function Length
     (DA                : in	 Dynamic_Array) 
                          return Natural;
   
   function Is_Empty
     (DA                : in	 Dynamic_Array) 
                          return Boolean
      with
         Post => Is_Empty'Result = (DA.Length = 0);
   
   function First
     (DA                : in	 Dynamic_Array) 
                          return Index
      with
         Pre => not DA.Is_Empty;
   
   function Last
     (DA                : in	 Dynamic_Array) 
                          return Index
      with
         Pre => not DA.Is_Empty;

   procedure Add
     (DA                : in out Dynamic_Array;
      C                 : in     Component);
   
   function Get
     (DA                : in out Dynamic_Array;
      I                 : in     Index) 
                          return Component
      with 
         Pre => I in First(DA) .. Last(DA);
   
   procedure Set
     (DA                : in out Dynamic_Array;
      I                 : in	 Index;
      C                 : in	 Component)

      with
         Pre => I >= First(DA) and I <= Last(DA);

   
private
   
   type Fixed_Array_Access is access Fixed_Array;
   
   type Dynamic_Array is new Ada.Finalization.Controlled with
   -- Data'First and Data'Length indicate the current capacity.
   -- First and Length determine the indices actually in use.
      record
         Data        : Fixed_Array_Access;
         First       : Index;
         Length      : Natural;
      end record;
   
   procedure Initialize
     (Object         : in out Dynamic_Array);
   
   procedure Adjust
     (Object         : in out Dynamic_Array);
   
   procedure Finalize
     (Object         : in out Dynamic_Array);

end Utility.Dynamic_Arrays;
