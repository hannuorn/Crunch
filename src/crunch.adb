with Deflate;
with Utility.Dynamic_Arrays;
with Ada.Text_IO; use Ada.Text_IO;

   
   procedure Crunch is
   
      type Natural_Array is array (Natural range <>) of Natural;
      Empty_Natural_Array : constant Natural_Array (1 .. 0) := (others => 0);
      
      package Dynamic_Natural_Arrays is new Utility.Dynamic_Arrays(
        Natural, Natural, Natural_Array, Empty_Natural_Array);
      
      DA	: Dynamic_Natural_Arrays.Dynamic_Array;
      
   begin
      Put_Line("Crunch");
      Put_Line("");
      Put_Line("Some dumb testing...");
      for I in 1 .. 1000 loop
         DA.Add(I);
      end loop;
      Put_Line("Length of dynamic array: " & Natural'Image(DA.Length));
      Put_Line("Goodbye.");
   end Crunch;

