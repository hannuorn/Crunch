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
-- package Utility.Test
--
-- Purpose:
--    Tools for unit testing.
--
------------------------------------------------------------------------

package Utility.Test is

   procedure Assert
     (Condition         : in     Boolean);
     
   procedure Assert
     (Condition         : in     Boolean;
      Message           : in     String);

   procedure Assert_Equals
     (Actual            : in     Natural;
      Expected          : in     Natural;
      Message           : in     String);

   procedure Assert_Equals
     (Actual            : in     Natural_64;
      Expected          : in     Natural_64;
      Message           : in     String);

   procedure Assert_Equals
     (Actual            : in     Boolean;
      Expected          : in     Boolean;
      Message           : in     String);
   
   procedure Begin_Test
     (Title             : in     String;
      Is_Leaf           : in     Boolean);
      
   procedure End_Test
     (Is_Leaf           : in     Boolean);

   procedure Put_Line
     (S                 : in     String);
     
end Utility.Test;
