with Utility.Dynamic_Arrays;


package Utility.Bit_Arrays is

   type Bit is mod 2;
   for Bit'Size use 1;
   type Byte is mod 2**8;
   for Byte'Size use 8;
   
   type Bit_Array is array (Natural_64 range <>) of Bit
      with Default_Component_Value => 0;
   for Bit_Array'Component_Size use 1;
   
   subtype Byte_Bits is Bit_Array (0 .. 7);

   Empty_Bit_Array      : constant Bit_Array (1 .. 0) := (others => 0);

   package Dynamic_Bit_Arrays is new Utility.Dynamic_Arrays
     (Component_Type    => Bit,
      Index_Type        => Natural_64,
      Fixed_Array       => Bit_Array,
      Empty_Fixed_Array => Empty_Bit_Array,
      Initial_Size      => 16);
      
   subtype Dynamic_Bit_Array is Dynamic_Bit_Arrays.Dynamic_Array;


   function To_Bits
     (B                 : in     Byte)
                          return Byte_Bits;

   function To_Byte
     (Bits              : in     Byte_Bits)
                          return Byte;

   procedure Add
     (Stream            : in out Dynamic_Bit_Array;
      B                 : in     Byte);

   procedure Read
     (Stream            : in     Dynamic_Bit_Array;
      Counter           : in out Natural_64;
      Length            : in     Natural_64;
      Result            : out    Dynamic_Bit_Array);

   procedure Read
     (Stream            : in     Dynamic_Bit_Array;
      Counter           : in out Natural_64;
      Result            : out    Bit_Array);
   
   procedure Read_Bit
     (Stream            : in     Dynamic_Bit_Array;
      Counter           : in out Natural_64;
      Result            : out    Bit);

   procedure Read_Byte
     (Stream            : in     Dynamic_Bit_Array;
      Counter           : in out Natural_64;
      Result            : out    Byte);
   
   procedure Skip_to_Next_Whole_Byte
     (Counter           : in out Natural_64);


end Utility.Bit_Arrays;
