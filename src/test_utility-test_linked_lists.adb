------------------------------------------------------------------------
--
--       Copyright (c) 2019, Hannu Örn
--       All rights reserved.
--
-- Author: Hannu Örn
--
------------------------------------------------------------------------

with Utility.Linked_Lists;
with Utility.Test;            use Utility.Test;
                              use Utility;


package body Test_Utility.Test_Linked_Lists is

   package Natural_64_Lists is new Utility.Linked_Lists (Natural_64);
   use Natural_64_Lists;
   
   
   procedure Basic_Test is
   
      L                 : Natural_64_Lists.Linked_List;
      N                 : Natural_64_Lists.Linked_List_Node;
      Found             : Boolean;
      X                 : Natural_64;
      
   begin
      Begin_Test("Basic_Test", Is_Leaf => True);
      
      Assert(L.Is_Empty);
      Assert(L.Size = 0);
      
      L.Add_Last(1);
      Assert(not L.Is_Empty);
      Assert(L.Size = 1);
      Assert(Value(L.First) = 1);
      Assert(Value(L.Last) = 1);
      
      Assert(Is_Null(N));
      N := L.First;
      Assert(not Is_Null(N));
      Assert(Value(N) = 1);
      Assert(Value(L.First) = 1);
      Assert(Value(L.Last) = 1);
      
      N := Next(N);
      Assert(Is_Null(N));
      
      Assert(Is_Null(Previous(L.First)));
      
      L.Add_Last(2);
      Assert(Value(Next(L.First)) = 2);
      Assert(Value(Previous(L.Last)) = 1);
      Assert(Is_Null(Next(L.Last)));
      Assert(Is_Null(Previous(L.First)));
      
      L.Get_and_Remove_First(Found, X);
      Assert(Found);
      Assert(X = 1);
      Assert(L.Size = 1);
      Assert(L.First = L.Last);

      End_Test(Is_Leaf => True);
   end Basic_Test;
   
   
   procedure Test_Size_N
     (N                 : in     Natural_64) is
   
      L                 : Natural_64_Lists.Linked_List;
      Node              : Natural_64_Lists.Linked_List_Node;
      
   begin
      Begin_Test("Test_Size_N, N = " & Natural_64'Image(N), Is_Leaf => True);
      
      for I in 1 .. N loop
         L.Add_Last(I);
         Assert(Value(L.Last) = I);
         Assert(Value(L.First) = 1);
         if I > 1 then
            Assert(Value(Previous(L.Last)) = I - 1);
         end if;
      end loop;
      
      Assert(Value(L.First) = 1);
      Assert(Value(L.Last) = N);

      Node := L.First;
      for I in 1 .. N loop
      
         Assert(Value(Node) = I);
         
         if I = 1 then
            Assert(Value(Node) = Value(L.First));
            Assert(Is_Null(Previous(Node)));
         else
            Assert(Value(Previous(Node)) = I - 1);
         end if;
         
         if I = N then
            Assert(Value(Node) = Value(L.Last));
            Assert(Is_Null(Next(Node)));
         else
            Assert(Value(Next(Node)) = I + 1);
         end if;
         
         Node := Next(Node);
      end loop;
      Assert(Is_Null(Node));
      
      Node := L.Last;
      for I in reverse 1 .. N loop
      
         Assert(Value(Node) = I);
         
         if I = 1 then
            Assert(Value(Node) = Value(L.First));
            Assert(Is_Null(Previous(Node)));
         else
            Assert(Value(Previous(Node)) = I - 1);
         end if;
         
         if I = N then
            Assert(Value(Node) = Value(L.Last));
            Assert(Is_Null(Next(Node)));
         else
            Assert(Value(Next(Node)) = I + 1);
         end if;

         Node := Previous(Node);
      end loop;
      Assert(Is_Null(Node));
      
      End_Test(Is_Leaf => True);
   end Test_Size_N;
   
                                                         
   procedure Test is
      
   begin
      Begin_Test("Linked_Lists", Is_Leaf => False);
      
      Basic_Test;
      Test_Size_N(100);
      Test_Size_N(10_000);
      Test_Size_N(1_000_000);
      Test_Size_N(10_000_000);
      
      End_Test(Is_Leaf => False);
   end Test;
   

end Test_Utility.Test_Linked_Lists;
