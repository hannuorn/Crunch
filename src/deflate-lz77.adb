------------------------------------------------------------------------
--
--       Copyright (c) 2019, Hannu Örn
--       All rights reserved.
--
-- Author: Hannu Örn
--
------------------------------------------------------------------------

package body Deflate.LZ77 is

   --type Dynamic_Byte_Array

   procedure Not_Implemented is
   
--      Tri               : Tribyte;
      
   begin
      -- loop
      --    tri = tribyte starting from current location
      --    add (tri, counter) to tree
      --    go back counter - window_size, read tribyte, remove from tree
      --    find tri from tree, if found
      --       enumerate results from newest to oldest
      --       find match length for each
      --       select longest (L) match at location M
      --       output (L, C - M) as length-distance
      --    if not found
      --       output literal
      -- end loop;
      null;
      -- Data = Byte_Array
      -- C := Data.First;
      
      -- constant Window_Width
      -- loop
         -- make sure at least 3 bytes left
         -- exit when Data.Last - C < 2;

         -- Tri := Data(C, C .. C + 2);
         -- if Tritree.Contains(Tri) then
            -- Loc := Access_to(Tritree.Get(Tri));
            -- Longest_Match := 0;
            -- Longest_Loc := 0;
            -- Loc.Find_Last(L, Found);
            -- while Found loop
               -- Len := Match_Length(Data, C, L);
               -- if Len > Longest_Len then
                  -- Longest_Len := Len;
                  -- Longest_Loc := L;
               -- end if;
            -- end loop;
            -- dist = C - longest_loc
            -- output longest_len, dist
            -- Loc.Put(C);
         -- else
            -- Locations := Create;
            -- Access_to(Locations).Put(C);
            -- Tritree.Put(Tri, Locations);
            -- output literal
         -- end if;
         -- find first
         -- while found and then result + win_wid < c
           -- remove
           -- find_first again
         -- end loop
         
   end Not_Implemented;
   
   
   function Match_Length
     (Input             : in     Dynamic_Byte_Array;
      C                 : in     Natural_64;
      L                 : in     Natural_64) 
                          return Natural_64 is
      
      N                 : Natural_64;
      
   begin
      N := 0;
      while C + N <= Input.Last and then Input.Get(C + N) = Input.Get(L + N) loop
         N := N + 1;
      end loop;
      return N;
   end Match_Length;
      
   
   procedure Compress
     (Input             : in     Dynamic_Byte_Array;
      Output            : out    Dynamic_LLD_Array) is
      
      use Tribyte_Location_Tree_Controlled_Accesses;
      
      C                 : Natural_64;
      Tri               : Tribyte;
      Tritree           : Tribyte_Tree;
      Loc               : Tribyte_Location_Tree_Access;
      Loc_Tree          : Tribyte_Location_Tree_Controlled_Access;
      Longest_Len       : Deflate_Length;
      Longest_Loc       : Natural_64;
      L                 : Natural_64;
      Found             : Boolean;
      Len               : Natural_64;
      LLD               : Literal_Length_Distance;
      B                 : Byte;
      X                 : Natural_64;
      
   begin
      C := Input.First;
      loop
         exit when Input.Last - C < 2;
         
         -- Remove references to stuff that is too far 
         
         if Input.First + Natural_64(Deflate_Distance'Last) < C then
            X := C - Natural_64(Deflate_Distance'Last) - 1;
            -- Anything at location X or before is useless.
            Input.Get(X, Tri);
            if Tritree.Contains(Tri) then
               Loc := Access_to(Tritree.Get(Tri));
               Loc.Find_First(L, Found);
               while Found and then L <= X loop
                  Loc.Remove(L);
                  Loc.Find_First(L, Found);
               end loop;
            end if;
         end if;
         
         -- Find matches 
         Input.Get(C, Tri);
         if Tritree.Contains(Tri) then
            -- Matches found. Find the longest one and output length/distance.
            Loc := Access_to(Tritree.Get(Tri));
            Longest_Len := Deflate_Length'First;
            Longest_Loc := C;
            Loc.Find_Last(L, Found);
            while Found loop
               Len := Match_Length(Input, C, L);
               if Longest_Loc = C or Len > Natural_64(Longest_Len) then
                  Longest_Loc := L;
                  if Len >= Natural_64(Deflate_Length'Last) then
                     Longest_Len := Deflate_Length'Last;
                     exit;
                  else
                     Longest_Len := Deflate_Length(Len);
                  end if;
               end if;
               Loc.Find_Previous(L, Found);
            end loop;
            Loc.Put(C, C);
            LLD := 
              (Is_Literal  => FALSE,
               Length      => Deflate_Length(Longest_Len),
               Distance    => Deflate_Distance(C - Longest_Loc));
            C := C + Natural_64(Longest_Len);
         else
            -- No matches found. Output literal.
            Loc_Tree := Create;
            Loc := Access_to(Loc_Tree);
            Loc.Put(C, C);
            Tritree.Put(Tri, Loc_Tree);
            Input.Read(C, B);
            LLD := 
              (Is_Literal  => TRUE,
               Literal     => B);
         end if;
         Output.Add(LLD);
      end loop;
      
      -- Output remaining bytes (if any) as literals.
      while C <= Input.Last loop
         Input.Read(C, B);
         LLD :=
           (Is_Literal  => TRUE,
            Literal     => B);
         Output.Add(LLD);
      end loop;
      
   end Compress;

   
   function Find_Length_Letter
     (Length            : in     Deflate_Length) 
                          return Length_Letter is
      
   begin
      for L in reverse First_Length'Range loop
         if First_Length(L) <= Length then
            return L;
         end if;
      end loop;
      return Length_Letter'First;
   end Find_Length_Letter;
   
   
   function Find_Distance_Letter
     (Distance          : in     Deflate_Distance)
                          return Distance_Letter is
      
   begin
      for L in reverse First_Distance'Range loop
         if First_Distance(L) <= Distance then
            return L;
         end if;
      end loop;
      return Distance_Letter'First;
   end Find_Distance_Letter;
   
   
   procedure Count_Weights
     (LLDs              : in     Dynamic_LLD_Array;
      LL_Weights        : out    Literal_Length_Huffman.Letter_Weights;
      Distance_Weights  : out    Distance_Huffman.Letter_Weights) is
      
      LLD               : Literal_Length_Distance;
      LL_Letter         : Literal_Length_Letter;
      Dist_Letter       : Distance_Letter;
      
   begin
      for I in LLDs.First .. LLDs.Last loop
         LLD := LLDs.Get(I);
         if LLD.Is_Literal then
            LL_Letter := Literal_Length_Letter(LLD.Literal);
            LL_Weights(LL_Letter) := LL_Weights(LL_Letter) + 1;
         else
            LL_Letter := Find_Length_Letter(LLD.Length);
            LL_Weights(LL_Letter) := LL_Weights(LL_Letter) + 1;
            Dist_Letter := Find_Distance_Letter(LLD.Distance);
            Distance_Weights(Dist_Letter) := Distance_Weights(Dist_Letter) + 1;
         end if;
      end loop;
   end Count_Weights;

end Deflate.LZ77;
