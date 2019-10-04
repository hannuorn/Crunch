with Utility.Binary_Search_Trees;
with Utility.Test; use Utility.Test;


package body Test_Utility.Test_Binary_Search_Trees is

   package Natural_Trees is new Utility.Binary_Search_Trees
     (Key_Type       => Natural, 
      Element_Type   => Natural,
      "<" => "<", 
      "=" => "=");
   use Natural_Trees;
   subtype Natural_Tree is Natural_Trees.Binary_Search_Tree;
   
      
   procedure Simple_Test is
   
      T1                : Natural_Tree;
      T2                : Natural_Tree;
      OK                : Boolean;
      X                 : Natural;
      
   begin
      Begin_Test("Simple_Test");
      Assert(T1 = T2);
      T2 := T1;
      Assert(T1 = T2);
      
      Assert(Natural(T1.Size) = 0);
      Assert(T1.Is_Empty);
      Assert(not T1.Contains(1));

      for I in 1 .. 1000 loop
         T1.Add(I, I, OK);
         Assert(OK);
         T1.Put(I, I + 1);
         Assert(T1.Next(I - 1) = I);
      end loop;
      T1.Find_First(X, OK);
      Assert(OK);
      Assert(X = 1);

      Assert(T1.First = 1);
      Assert(T1.Last = 1000);
      Assert(T1.Is_Last(1000));

      for I in 1 .. 1000 loop
         Assert(T1.Contains(I));
         Assert(T1.Get(I) = I + 1);
         T1.Remove(I);
         Assert(not T1.Contains(I));
         if I < 1000 then
            Assert(T1.Next(I) = I + 1);
         end if;
      end loop;
      Assert(T1.Is_Empty);
      End_Test;
   end Simple_Test;


   procedure Large_Test_1 is
   
      N                 : constant Natural := 1_000_000;
      T1                : Natural_Tree;
      T2                : Natural_Tree;
      S                 : Natural;
      
   begin
      Begin_Test("Large_Test_1");
      Assert(T1.Is_Empty);
      for I in 1 .. N loop
         T1.Put(I, I);
      end loop;
      T2 := T1;
      Assert(T1.First = 1);
      Assert(T1.Last = N);
      S := Natural(T1.Size);
      Assert(S = N);
      for I in 1 .. N loop
         T1.Remove(I);
      end loop;
      Assert(T1.Is_Empty);
      
      for I in 1 .. N loop
         T1.Put(I, I);
      end loop;
      Assert(T1.First = 1);
      Assert(T1.Last = N);
      S := Natural(T1.Size);
      Assert(S = N);
      for I in reverse 1 .. N loop
         T1.Remove(I);
      end loop;
      Assert(T1.Is_Empty);
      
      for I in reverse 1 .. N loop
         T1.Put(I, I);
      end loop;
      Assert(T1.First = 1);
      Assert(T1.Last = N);
      S := Natural(T1.Size);
      Assert(S = N);
      for I in 1 .. N loop
         T1.Remove(I);
      end loop;
      Assert(T1.Is_Empty);
      
      for I in reverse 1 .. N loop
         T1.Put(I, I);
      end loop;
      Assert(T1.First = 1);
      Assert(T1.Last = N);
      S := Natural(T1.Size);
      Assert(S = N);
      for I in 1 .. N loop
         Assert(T1.Contains(I));
      end loop;
      for I in reverse 1 .. N loop
         T1.Remove(I);
      end loop;
      Assert(T1.Is_Empty);

      End_Test;
   end Large_Test_1;
   
   
   procedure Large_Test_2 is
   
      N                 : constant Natural := 1_000_000;
      T1                : Natural_Tree;
      K                 : Natural;
      Found             : Boolean;
      
   begin
      Begin_Test("Large_Test_2");
      for I in 1 .. N loop
         T1.Put(I, I);
      end loop;
      
      K := N - 1;
      T1.Find_Next(K, Found);
      Assert(Found and K = N);

      K := N;
      T1.Find_Next(K, Found);
      Assert(not Found);
      
      T1.Find_First(K, Found);
      Assert(Found and K = 1);
      while Found loop
         T1.Remove(K);
         T1.Find_Next(K, Found);
      end loop;
      Assert(T1.Is_Empty);
      End_Test;
   end Large_Test_2;
   
      
   procedure Test is
      
   begin
      Begin_Test("Binary_Search_Trees");
      Simple_Test;
      Large_Test_1;
      Large_Test_2;
      End_Test;
   end Test;
   

end Test_Utility.Test_Binary_Search_Trees;
