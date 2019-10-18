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
   

end Deflate.LZ77;
