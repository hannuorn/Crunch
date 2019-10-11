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
     (Title             : in     String);
  
   procedure End_Test;

   procedure Print
     (S                 : in     String);
     
end Utility.Test;
