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
      Begin_Test("Basic_Test");
      
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

      End_Test;
   end Basic_Test;
   
                                                         
   procedure Test is
      
   begin
      Begin_Test("Linked_Lists");
      
      Basic_Test;
      
      End_Test;
   end Test;
   

end Test_Utility.Test_Linked_Lists;
