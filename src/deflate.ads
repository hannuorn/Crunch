with Utility.Dynamic_Arrays;


package Deflate is

   type Bit is range 0 .. 1;
   type Bit_Array is array (Natural range <>) of Bit
      with Default_Component_Value => 0;
   for Bit_Array'Component_Size use 1;

   Empty_Bit_Array      : constant Bit_Array (1 .. 0) := (others => 0);

   package Dynamic_Bit_Arrays is new Utility.Dynamic_Arrays
     (Component         => Bit, 
      Index             => Natural, 
      Fixed_Array       => Bit_Array,
      Empty_Fixed_Array => Empty_Bit_Array,
      Initial_Size      => 16);

end Deflate;
