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
-- package Utility.Bits_and_Bytes
--
-- Purpose:
--    Tools for handling bits, bytes and arrays of bits and bytes.
--
------------------------------------------------------------------------

with Utility.Dynamic_Arrays;


package Utility.Bits_and_Bytes is

   type Bit is mod 2 with Size => 1;
   type Byte is mod 2**8 with Size => 8;
   
   type Bit_Array is array (Natural_64 range <>) of Bit
      with Component_Size => 1, Default_Component_Value => 0;
   
   type Byte_Array is array (Natural_64 range <>) of Byte
      with Component_Size => 8, Default_Component_Value => 0;
   
   subtype Byte_Bits is Bit_Array (0 .. 7);

   Empty_Bit_Array      : constant Bit_Array (1 .. 0) := (others => 0);
   Empty_Byte_Array     : constant Byte_Array (1 .. 0) := (others => 0);

   package Dynamic_Bit_Arrays is new Utility.Dynamic_Arrays
     (Component_Type    => Bit,
      Index_Type        => Natural_64,
      Fixed_Array       => Bit_Array,
      Empty_Fixed_Array => Empty_Bit_Array,
      Initial_Size      => 16);
      
   package Dynamic_Byte_Arrays is new Utility.Dynamic_Arrays
     (Component_Type    => Byte,
      Index_Type        => Natural_64,
      Fixed_Array       => Byte_Array,
      Empty_Fixed_Array => Empty_Byte_Array,
      Initial_Size      => 16);
      
   subtype Dynamic_Bit_Array  is Dynamic_Bit_Arrays.Dynamic_Array;
   subtype Dynamic_Byte_Array is Dynamic_Byte_Arrays.Dynamic_Array;
   
   Empty_Dynamic_Bit_Array    : constant Dynamic_Bit_Array := 
         Dynamic_Bit_Arrays.Empty_Dynamic_Array;
   Empty_Dynamic_Byte_Array    : constant Dynamic_Byte_Array := 
         Dynamic_Byte_Arrays.Empty_Dynamic_Array;


   function To_Bits
     (N                 : in     Natural_64;
      Length            : in     Natural_64)
                          return Dynamic_Bit_Array;

   function To_Number
     (Bits              : in     Bit_Array)
                          return Natural_64;
   
   procedure Add
     (Stream            : in out Dynamic_Bit_Array;
      B                 : in     Byte);

   procedure Read_Byte
     (Stream            : in     Dynamic_Bit_Array;
      Counter           : in out Natural_64;
      Result            : out    Byte);

end Utility.Bits_and_Bytes;
