------------------------------------------------------------------------
--
--       Copyright (c) 2019, Hannu Örn
--       All rights reserved.
--
-- Author: Hannu Örn
--
------------------------------------------------------------------------

with Utility.Dynamic_Arrays;


package Test_Utility.Test_Dynamic_Arrays is

   type Natural_Array is array (Positive range <>) of Natural;
   Empty_Natural_Array  : Natural_Array (1 .. 0) := (others => 0);
   
   package Natural_Dynamic_Arrays is new Utility.Dynamic_Arrays
     (Component_Type    => Natural,
      Index_Type        => Positive,
      Fixed_Array       => Natural_Array,
      Empty_Fixed_Array => Empty_Natural_Array,
      Initial_Size      => 0);
      
   subtype Natural_Dynamic_Array is Natural_Dynamic_Arrays.Dynamic_Array;
      

   procedure Test;

end Test_Utility.Test_Dynamic_Arrays;
