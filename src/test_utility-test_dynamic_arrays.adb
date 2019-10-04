with Utility;                 use Utility;
with Utility.Test;            use Utility.Test;
with Utility.Dynamic_Arrays;


package body Test_Utility.Test_Dynamic_Arrays is

   procedure Simple_Test is
   
      use type Natural_Dynamic_Array;
      
      FA_Length         : constant Natural := 100;
      FA                : Natural_Array (1 .. FA_Length);
      A                 : Natural_Dynamic_Array;
      B                 : Natural_Dynamic_Array;

   begin
      Begin_Test("Simple_Test");
      Assert(A.Is_Empty);
      
      for I in FA'Range loop
         FA(I) := I;
      end loop;
      A.Set(FA);
      Assert(not A.Is_Empty);
      Assert(A.Length = FA'Length);
      Assert(A.Get = FA);
      Assert(A.First = FA'First);
      Assert(A.Last = FA'Last);
      
      B := A;
      Assert(B.Length = FA'Length);
      
      for I in FA'Range loop
         Assert(A.Get(Index => I) = FA(I));
         Assert(B.Get(Index => I) = FA(I));
      end loop;
      
      for I in FA'Range loop
         A.Set(Index => I, Value => 2 * I);
      end loop;
      for I in FA'Range loop
         Assert(A.Get(Index => I) = 2* I);
      end loop;
      
      A.Set(Empty_Natural_Array);
      Assert(A.Is_Empty);
      Assert(not (A = B));
      B := A;
      Assert(A = B);
      Assert(B.Is_Empty);
      A.Add(1);
      A.Add(2);
      Assert(A.Length = 2);
      Assert(A.First = 1); -- Index_Type in this case is Positive
      B := A;
      Assert(B.Length = 2);
      Assert(B.First = 1); -- Index_Type in this case is Positive
      
      A.Set(Empty_Natural_Array);
      for I in 1 .. 1000 loop
         A.Add(2 * I + 1);
      end loop;
      for I in 1 .. 1000 loop
         Assert(A.Get(Index => I) = 2 * I + 1);
      end loop;
      End_Test;
   end Simple_Test;


   procedure Test is
      
   begin
      Begin_Test("Dynamic_Arrays");
      Simple_Test;
      End_Test;
   end Test;
   
end Test_Utility.Test_Dynamic_Arrays;
