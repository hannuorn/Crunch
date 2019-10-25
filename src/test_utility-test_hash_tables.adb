------------------------------------------------------------------------
--
--       Copyright (c) 2019, Hannu Örn
--       All rights reserved.
--
-- Author: Hannu Örn
--
------------------------------------------------------------------------

with Ada.Numerics.Discrete_Random;
with Utility.Hash_Tables; use Utility;
with Utility.Test; use Utility.Test;


package body Test_Utility.Test_Hash_Tables is

   type Hash_Key is mod 2**16;

   
   function Hash
     (Key               : in     Natural_64)
                          return Hash_Key is

   begin
      return Hash_Key (Key mod 2**16);
   end Hash;

                          
   package Natural_64_Hash_Tables is new Utility.Hash_Tables
     (Hash_Key, Natural_64, Boolean, "<", "=", Hash);


   procedure Basic_Test is
   
      H                 : Natural_64_Hash_Tables.Hash_Table;
      N                 : Natural_64 := 10_000_000;

   begin
      Begin_Test("Basic_Test", Is_Leaf => True);
      
      for I in 1 .. N loop
         H.Put(I, True);
      end loop;
      for I in 1 .. N loop
         Assert(H.Contains(I));
         H.Remove(I);
         Assert(not H.Contains(I));
      end loop;

      End_Test(Is_Leaf => True);
   end Basic_Test;


   procedure Random_Test is
      
      subtype Key_Type is Natural_64 range 1 .. 10_000_000;
      package Random is new Ada.Numerics.Discrete_Random (Key_Type);
      use Random;
      
      Gen         : Random.Generator;
      K           : Key_Type;
      T           : Natural_64_Hash_Tables.Hash_Table;
      
   begin
      Begin_Test("Random_Test", Is_Leaf => True);
      
      Reset(Gen, 1);
      for I in 1 .. Key_Type'Last / 2 loop
         K := Random.Random(Gen);
         T.Put(K, True);
      end loop;
      
      for I in 1 .. Key_Type'Last / 2 loop
         K := Random.Random(Gen);
         if T.Contains(K) then
            T.Remove(K);
         end if;
      end loop;

      End_Test(Is_Leaf => True);
   end Random_Test;
   
   
   procedure Test is
      
   begin
      Begin_Test("Hash_Tables", Is_Leaf => False);
      
      Basic_Test;
      Random_Test;
      
      End_Test(Is_Leaf => False);
   end Test;
   

end Test_Utility.Test_Hash_Tables;
