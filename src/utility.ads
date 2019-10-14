------------------------------------------------------------------------
--
--       Copyright (c) 2019, Hannu �rn
--       All rights reserved.
--
-- Author: Hannu �rn
--
------------------------------------------------------------------------

package Utility is

   type Natural_64 is range 0 .. 2**63 - 1;
   subtype Positive_64 is Natural_64 range 1 .. Natural_64'Last;

end Utility;
