pragma Assertion_Policy(Check);

with Utility.Dynamic_Arrays;


package body Test_Utility.Test_Dynamic_Arrays is


   procedure Test is
      
      use type Natural_Dynamic_Array;
      
      FA_Length         : constant Natural := 100;
      FA                : Natural_Array (1 .. FA_Length);
      A                 : Natural_Dynamic_Array;
      B                 : Natural_Dynamic_Array;

   begin
      pragma Assert(A.Is_Empty);
      
      for I in FA'Range loop
         FA(I) := I;
      end loop;
      A.Set(FA);
      pragma Assert(not A.Is_Empty);
      pragma Assert(A.Length = FA'Length);
      pragma Assert(A.Get = FA);
      pragma Assert(A.First = FA'First);
      pragma Assert(A.Last = FA'Last);
      
      B := A;
      pragma Assert(B.Length = FA'Length);
      
      for I in FA'Range loop
         pragma Assert(A.Get(Index => I) = FA(I));
         pragma Assert(B.Get(Index => I) = FA(I));
      end loop;
      
      for I in FA'Range loop
         A.Set(Index => I, Value => 2 * I);
      end loop;
      for I in FA'Range loop
         pragma Assert(A.Get(Index => I) = 2* I);
      end loop;
      
      A.Set(Empty_Natural_Array);
      pragma Assert(A.Is_Empty);
      pragma Assert(not (A = B));
      B := A;
      pragma Assert(A = B);
      pragma Assert(B.Is_Empty);
      A.Add(1);
      A.Add(2);
      pragma Assert(A.Length = 2);
      pragma Assert(A.First = 1); -- Index_Type in this case is Positive
      B := A;
      pragma Assert(B.Length = 2);
      pragma Assert(B.First = 1); -- Index_Type in this case is Positive
      
      A.Set(Empty_Natural_Array);
      for I in 1 .. 1000 loop
         A.Add(2 * I + 1);
      end loop;
      for I in 1 .. 1000 loop
         pragma Assert(A.Get(Index => I) = 2 * I + 1);
      end loop;
   end Test;
   

end Test_Utility.Test_Dynamic_Arrays;
