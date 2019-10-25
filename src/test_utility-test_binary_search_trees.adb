------------------------------------------------------------------------
--
--       Copyright (c) 2019, Hannu Örn
--       All rights reserved.
--
-- Author: Hannu Örn
--
------------------------------------------------------------------------

with Ada.Numerics.Discrete_Random;
with Utility.Binary_Search_Trees;
with Utility.Test;            use Utility.Test;
                              use Utility;


package body Test_Utility.Test_Binary_Search_Trees is

   package Natural_Trees is new Utility.Binary_Search_Trees
     (Key_Type       => Natural, 
      Element_Type   => Natural,
      "<"            => "<", 
      "="            => "=");
      
   use Natural_Trees;
   subtype Natural_Tree is Natural_Trees.Binary_Search_Tree;
   
      
   procedure Simple_Test is
   
      N                 : constant Natural := 1000;
      
      T1                : Natural_Tree;
      T2                : Natural_Tree;
      OK                : Boolean;
      X                 : Natural;
      
   begin
      Begin_Test("Simple_Test", Is_Leaf => True);
      
      -- Empty trees should be equal
      Assert(T1 = T2);
      T2 := T1;
      Assert(T1 = T2);
      
      -- Size of empty tree should be 0
      Assert_Equals(T1.Size, 0, "Size of an empty tree");
      Assert(T1.Is_Empty);
      Assert(not T1.Contains(1));

      -- Add 1000 nodes
      for I in 1 .. N loop
         T1.Add(I, I, OK);
         Assert(OK);
         T1.Put(I, I + 1);
         Assert_Equals(T1.Next(I - 1), I, "Next to " & Natural'Image(I - 1));
         T1.Verify;
         Assert(OK);
      end loop;
      
      -- Try enumeration with Find_First and Find_Next
      -- First should be 1
      T1.Find_First(X, OK);
      Assert(OK);
      Assert(X = 1);
      -- Next should be 2
      T1.Find_Next(X, OK);
      Assert(OK);
      Assert(X = 2);
      -- Jump to the end, so there should not be a next one
      X := N;
      T1.Find_Next(X, OK);
      Assert(not OK);

      -- Try reverse enumeration with Find_Last and Find_Previous
      -- First should be N
      T1.Find_Last(X, OK);
      Assert(OK, "Find_Last");
      Assert(X = N, "Find_Last, X = N");
      -- Previous should be N - 1
      T1.Find_Previous(X, OK);
      Assert(OK, "Find_Previous");
      Assert(X = N - 1, "Find_Previous, X = N - 1");
      -- Jump to the beginning, so there should not be a previous one
      X := 1;
      T1.Find_Previous(X, OK);
      Assert(not OK, "Find_Previous, X = 1");

      -- Check first and last node
      Assert(T1.First = 1);
      Assert(T1.Last = N);
      Assert(T1.Is_Last(N));

      -- Check the existence and values of the nodes
      -- Check next and previous node
      for I in 1 .. N loop
         Assert(T1.Contains(I));
         Assert(T1.Get(I) = I + 1);
         if I > 1 then
            Assert_Equals(T1.Previous(I), I - 1,
               "Previous to" & Natural'Image(I));
         end if;
         if I < N then
            Assert_Equals(T1.Next(I), I + 1, "Next to" & Natural'Image(I));
         end if;
      end loop;
      
      -- Remove a node and check it no longer exists
      for I in 1 .. N loop
         T1.Remove(I);
         Assert_Equals(T1.Contains(I), FALSE, "Contains" & Natural'Image(I));
      end loop;
      Assert_Equals(T1.Is_Empty, TRUE, "Is_Empty");
      
      End_Test(Is_Leaf => True);
   end Simple_Test;


   procedure Large_Test_1 is
   
      N                 : constant Natural := 100_000;
      Verify_Period     : constant Natural := 4247;
      T1                : Natural_Tree;
      T2                : Natural_Tree;
      S                 : Natural;
      
   begin
      Begin_Test("Large_Test_1", Is_Leaf => True);
      -- Large_Test_1: Add and remove a large amount of nodes
      -- in various patterns. Verify tree integrity occasionally.
      
      Assert_Equals(T1.Is_Empty, TRUE, "Is_Empty");
      for I in 1 .. N loop
         T1.Put(I, I);
         if I mod Verify_Period = 0 then
            T1.Verify;
         end if;
      end loop;
      T2 := T1;
      T1.Verify;
      T2.Verify;
      
      -- Check the size of the tree, check first and last node
      S := Natural(T1.Size);
      Assert_Equals(S, N, "Size");
      Assert_Equals(T1.First, 1, "First");
      Assert_Equals(T1.Last, N, "Last");
      
      -- Remove all nodes, check size decreasing
      for I in 1 .. N loop
         T1.Remove(I);
         Assert_Equals(Natural(T1.Size), N - I, "Size");
         if I mod Verify_Period = 0 then
            T1.Verify;
         end if;
      end loop;
      Assert_Equals(T1.Is_Empty, TRUE, "Is_Empty");
      T1.Verify;
      
      -- Add N nodes again, remove in reverse order
      for I in 1 .. N loop
         T1.Put(I, I);
      end loop;
      S := Natural(T1.Size);
      Assert_Equals(S, N, "Size");
      Assert_Equals(T1.First, 1, "First");
      Assert_Equals(T1.Last, N, "Last");
      for I in reverse 1 .. N loop
         T1.Remove(I);
         if I mod Verify_Period = 0 then
            T1.Verify;
         end if;
      end loop;
      Assert_Equals(T1.Is_Empty, TRUE, "Is_Empty");

      -- Add nodes in reverse order, remove in normal order
      for I in reverse 1 .. N loop
         T1.Put(I, I);
      end loop;
      T1.Verify;
      S := Natural(T1.Size);
      Assert_Equals(S, N, "Size");
      Assert_Equals(T1.First, 1, "First");
      Assert_Equals(T1.Last, N, "Last");
      for I in 1 .. N loop
         T1.Remove(I);
         if I mod Verify_Period = 0 then
            T1.Verify;
         end if;
      end loop;
      Assert_Equals(T1.Is_Empty, TRUE, "Is_Empty");
      
      -- Add and remove in reverse order
      for I in reverse 1 .. N loop
         T1.Put(I, I);
      end loop;
      T1.Verify;
      S := Natural(T1.Size);
      Assert_Equals(S, N, "Size");
      Assert_Equals(T1.First, 1, "First");
      Assert_Equals(T1.Last, N, "Last");
      for I in 1 .. N loop
         Assert_Equals(
            T1.Contains(I), TRUE, "Contains key" & Integer'Image(I));
      end loop;
      for I in reverse 1 .. N loop
         T1.Remove(I);
         if I mod Verify_Period = 0 then
            T1.Verify;
         end if;
      end loop;
      Assert_Equals(T1.Is_Empty, TRUE, "Is_Empty");

      End_Test(Is_Leaf => True);
   end Large_Test_1;
   
   
   procedure Large_Test_2 is
   
      N                 : constant Natural := 1_000_000;
      T1                : Natural_Tree;
      K                 : Natural;
      Found             : Boolean;
      
   begin
      Begin_Test("Large_Test_2", Is_Leaf => True);
      -- Test tree enumeration by Find_First/Find_Next
      
      for I in 1 .. N loop
         T1.Put(I, I);
      end loop;
      
      -- N should be next to N - 1
      K := N - 1;
      T1.Find_Next(K, Found);
      Assert(Found and K = N);

      -- there should not be a node next to N
      K := N;
      T1.Find_Next(K, Found);
      Assert(not Found);

      -- enumerate and remove the whole tree
      T1.Find_First(K, Found);
      Assert(Found and K = 1);
      while Found loop
         T1.Remove(K);
         Assert_Equals(
            T1.Contains(K), FALSE, "Contains key " & Natural'Image(K));
         T1.Find_Next(K, Found);
      end loop;
      Assert_Equals(T1.Is_Empty, TRUE, "Is_Empty");
      
      End_Test(Is_Leaf => True);
   end Large_Test_2;
   
   
   procedure Random_Test is
      
      subtype Key_Type is Natural range 1 .. 5_000_000;
      package Random is new Ada.Numerics.Discrete_Random (Key_Type);
      use Random;
      
      Verify_Period     : constant Natural := 4247;
        
      Gen         : Random.Generator;
      K           : Key_Type;
      T           : Natural_Tree;
      
   begin
      Begin_Test("Random_Test", Is_Leaf => True);
      
      Reset(Gen, 1);
      for I in 1 .. Key_Type'Last / 5 loop
         K := Random.Random(Gen);
         T.Put(K, K);
         if I mod Verify_Period = 0 then
            T.Verify;
         end if;
      end loop;
      T.Verify;
      
      for I in 1 .. Key_Type'Last / 2 loop
         K := Random.Random(Gen);
         if T.Contains(K) then
            T.Remove(K);
            if I mod Verify_Period = 0 then
               T.Verify;
            end if;
         end if;
      end loop;

      End_Test(Is_Leaf => True);
   end Random_Test;
   
      
   procedure Test is
      
   begin
      Begin_Test("Binary_Search_Trees", Is_Leaf => False);
      
      Simple_Test;
      Random_Test;
      Large_Test_1;
      Large_Test_2;
      
      End_Test(Is_Leaf => False);
   end Test;
   

end Test_Utility.Test_Binary_Search_Trees;
