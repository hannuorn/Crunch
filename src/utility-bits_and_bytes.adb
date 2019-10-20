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
-- package Utility.Bits_and_Bytes
--
-- Implementation Notes:
--    This package uses Ada.Unchecked_Conversion.
--
------------------------------------------------------------------------

with Ada.Unchecked_Conversion;


package body Utility.Bits_and_Bytes is

   
   function To_Bits
     (N                 : in     Natural_64;
      Length            : in     Natural_64)
                          return Dynamic_Bit_Array is
      
      X                 : Natural_64 := N;
      Bits              : Bit_Array (1 .. Length);
      Result            : Dynamic_Bit_Array;
      
   begin
      for I in reverse 1 .. Length loop
         Bits(I) := Bit(X mod 2);
         X := X / 2;
      end loop;
      Result.Set(Bits);
      return Result;
   end To_Bits;

   
   function To_Number
     (Bits              : in     Bit_Array)
                          return Natural_64 is
   
      N                 : Natural_64;
      B                 : Natural_64;
      
   begin
      N := 0;
      B := 1;
      for I in reverse Bits'Range loop
         N := N + Natural_64(Bits(I)) * B;
         B := 2 * B;
      end loop;
      return N;
   end To_Number;
    

   function To_Bits
     (B                 : in     Byte)
                          return Byte_Bits is
                          
      function Byte_To_Bits is new Ada.Unchecked_Conversion(Byte, Byte_Bits);
      
      -- X                 : Byte := B;
      -- Bits              : Byte_Bits;
      
   begin
      -- for I in Byte_Bits'Range loop
         -- Bits(I) := Bit(X mod 2);
         -- X := X/2;
      -- end loop;
      -- pragma Assert(Bits = Byte_To_Bits(B));
      -- return Bits;
      return Byte_to_Bits(B);
   end To_Bits;
   
   
   function To_Byte
     (Bits              : in     Byte_Bits)
                          return Byte is
                          
      function Bits_to_Byte is new Ada.Unchecked_Conversion(Byte_Bits, Byte);
                          
      --B                 : Byte := 0;

   begin
      -- for I in Bits'Range loop
         -- if Bits(I) = 1 then
            -- B := B + 2**Natural(I);
         -- end if;
      -- end loop;
      -- pragma Assert(B = Bits_to_Byte(Bits));
      -- return B;
      return Bits_to_Byte(Bits);
   end To_Byte;


   procedure Add
     (Stream            : in out Dynamic_Bit_Array;
      B                 : in     Byte) is
      
      Bits              : constant Byte_Bits := To_Bits(B);
      
   begin
      for I in reverse Bits'Range loop
         Stream.Add(Bits(I));
      end loop;
   end Add;


   procedure Skip_to_Next_Whole_Byte
     (Counter           : in out Natural_64) is
     
   begin
      if Counter mod 8 /= 0 then
         Counter := 8*(1 + Counter/8);
      end if;
   end Skip_to_Next_Whole_Byte;
   

   procedure Read_Bit
     (Stream            : in     Dynamic_Bit_Array;
      Counter           : in out Natural_64;
      Result            : out    Bit) is
      
   begin
      Result := Stream.Get(Index => Counter);
      Counter := Counter + 1;
   end Read_Bit;


   -- if less than 8 bits remaining, fill in with 0s at the end
   
   procedure Read_Byte
     (Stream            : in     Dynamic_Bit_Array;
      Counter           : in out Natural_64;
      Result            : out    Byte) is
      
      Last              : constant Natural_64 := Natural_64'Min
                           (Counter + 8 - 1, Stream.Last);
      BB                : Byte_Bits := (others => 0);
      C                 : Natural_64;
      
   begin
      C := Counter;
      for I in Counter .. Last loop
         BB(Counter + 7 - I) := Stream.Get(Index => C);
         C := C + 1;
      end loop;
      Counter := C;
      Result := To_Byte(BB);
   end Read_Byte;
   
   
end Utility.Bits_and_Bytes;
