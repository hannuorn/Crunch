------------------------------------------------------------------------
--
--       Copyright (c) 2019, Hannu Örn
--       All rights reserved.
--
-- Author: Hannu Örn
--
------------------------------------------------------------------------

with Ada.Assertions;
with Utility.Test;      use Utility.Test;


package body Utility.Test.Discrete_Types is

   procedure Assert_Equals
     (Actual            : in     Discrete_Type;
      Expected          : in     Discrete_Type;
      Message           : in     String) is
      
   begin
      if not (Actual = Expected) then
         Utility.Test.Put_Line(
            Message & 
            ", expected = " & Discrete_Type'Image(Expected) & 
            ", actual = "   & Discrete_Type'Image(Actual));
      end if;
      Ada.Assertions.Assert(Actual = Expected);
   end Assert_Equals;
   

end Utility.Test.Discrete_Types;
