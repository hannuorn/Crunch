------------------------------------------------------------------------
--
--       Copyright (c) 2019, Hannu Örn
--       All rights reserved.
--
-- Author: Hannu Örn
--
------------------------------------------------------------------------

package Utility is

   type Integer_64 is range -2**63 .. 2**63 - 1;
   subtype Natural_64 is Integer_64 range 0 .. Integer_64'Last;
   subtype Positive_64 is Natural_64 range 1 .. Natural_64'Last;

end Utility;
