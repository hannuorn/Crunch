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

   type Object is limited private;
   type Object_Access is access Object;
   
   
package Utility.Controlled_Accesses is

   type Controlled_Access is tagged private;


   function Access_to
     (This                 : in     Controlled_Access)
                             return Object_Access;

   function Create           return Controlled_Access;
   
         
private

   type Counter is
      record
         Count             : Positive_64;
         Data              : Object_Access;
      end record;
   type Counter_Access is access Counter;
   
   type Controlled_Access is new Ada.Finalization.Controlled with 
      record
         Counter           : Counter_Access;
      end record;

   procedure Initialize
     (This                 : in out Controlled_Access);

   procedure Adjust
     (This                 : in out Controlled_Access);

   procedure Finalize
     (This                 : in out Controlled_Access);

end Utility.Controlled_Accesses;
