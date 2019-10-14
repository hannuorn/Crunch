------------------------------------------------------------------------
--
--       Copyright (c) 2019, Hannu �rn
--       All rights reserved.
--
-- Author: Hannu �rn
--
------------------------------------------------------------------------

generic

   type Discrete_Type is (<>);
   
package Utility.Test.Discrete_Types is

   procedure Assert_Equals
     (Actual            : in     Discrete_Type;
      Expected          : in     Discrete_Type;
      Message           : in     String);

end Utility.Test.Discrete_Types;
