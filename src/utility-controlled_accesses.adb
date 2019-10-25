------------------------------------------------------------------------
--
--       Copyright (c) 2019, Hannu Örn
--       All rights reserved.
--
-- Author: Hannu Örn
--
------------------------------------------------------------------------

with Ada.Unchecked_Deallocation;


package body Utility.Controlled_Accesses is


   function Access_to
     (This                 : in     Controlled_Access)
                             return Object_Access is
                             
   begin
      return This.Counter.Data;
   end Access_to;


   function Create           return Controlled_Access is

      X                    : Object_Access;
      CA                   : Controlled_Access;

   begin
      X := new Object;
      CA.Counter := new Counter;
      CA.Counter.Count := 1;
      CA.Counter.Data := X;
      return CA;
   end Create;


   procedure Initialize
     (This                 : in out Controlled_Access) is
     
   begin
      null;
   end Initialize;
   

   procedure Adjust
     (This                 : in out Controlled_Access) is
     
   begin
      if This.Counter /= null then
         This.Counter.Count := This.Counter.Count + 1;
      end if;
   end Adjust;
   

   procedure Finalize
     (This                 : in out Controlled_Access) is
     
      procedure Free is new Ada.Unchecked_Deallocation
            (Counter, Counter_Access);
      procedure Free is new Ada.Unchecked_Deallocation
            (Object, Object_Access);

   begin
      if This.Counter /= null then
         if This.Counter.Count = 1 then
            Free(This.Counter.Data);
            Free(This.Counter);
         else
            This.Counter.Count := This.Counter.Count - 1;
         end if;
      end if;
   end Finalize;

   
end Utility.Controlled_Accesses;
