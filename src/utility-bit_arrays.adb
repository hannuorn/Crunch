package body Utility.Bit_Arrays is


   function To_Bits
     (B                 : in     Byte)
                          return Byte_Bits is
                          
      X                 : Byte := B;
      Bits              : Byte_Bits;
      
   begin
      for I in Byte_Bits'Range loop
         Bits(I) := Bit(X mod 2);
         X := X/2;
      end loop;
      return Bits;
   end To_Bits;
   
   
   function To_Byte
     (Bits              : in     Byte_Bits)
                          return Byte is
                          
      B                 : Byte := 0;

   begin
      for I in Bits'Range loop
         if Bits(I) = 1 then
            B := B + 2**Natural(I);
         end if;
      end loop;
      return B;
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
   

   procedure Read
     (Stream            : in     Dynamic_Bit_Array;
      Counter           : in out Natural_64;
      Length            : in     Natural_64;
      Result            : out    Dynamic_Bit_Array) is
      
      Last              : Natural_64 := Natural_64'Min
                           (Counter + Length - 1, Stream.Last);
   
   begin
      Result.Set(Stream.Get(Counter .. Last));
      Counter := Last + 1;
   end Read;


   procedure Read
     (Stream            : in     Dynamic_Bit_Array;
      Counter           : in out Natural_64;
      Result            : out    Bit_Array) is

   begin
      Result := Stream.Get(Counter .. Counter + Result'Length - 1);
      Counter := Counter + Result'Length;
   end Read;


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
      
   begin
      for I in Counter .. Last loop
         BB(Counter + 7 - I) := Stream.Get(Index => Counter);
      end loop;
      Counter := Last + 1;
      Result := To_Byte(BB);
   end Read_Byte;
   
   
end Utility.Bit_Arrays;
