------------------------------------------------------------------------
--
--       Copyright (c) 2019, Hannu Örn
--       All rights reserved.
--
-- Author: Hannu Örn
--
------------------------------------------------------------------------

with Ada.Unchecked_Deallocation;


package body Deflate.LZ77 is

   subtype Tribyte is Byte_Array (1 .. 3);
   
   subtype Bytes_X is Byte_Array (1 .. 6);
   
   -- List of locations where a tribyte can be found
   
   package Location_Trees is new Utility.Binary_Search_Trees
      (Natural_64, Natural_64, "<", "=");
      
   subtype Location_Tree is Location_Trees.Binary_Search_Tree;
   type Location_Tree_Access is access Location_Tree;
      
   -- Tree of tribytes, given a tribyte, gives list of locations for it

   package Location_Tree_Controlled_Accesses is
     new Controlled_Accesses (Location_Tree, Location_Tree_Access);
   use Location_Tree_Controlled_Accesses;
   
   subtype Location_Tree_Controlled_Access is
         Location_Tree_Controlled_Accesses.Controlled_Access;
               
   package Tribyte_Trees is new Utility.Binary_Search_Trees
     (Tribyte, Location_Tree_Controlled_Access, "<", "=");
   subtype Tribyte_Tree is Tribyte_Trees.Binary_Search_Tree;
   
   package Bytes_X_Trees is new Utility.Binary_Search_Trees
     (Bytes_X, Location_Tree_Controlled_Access, "<", "=");
   subtype Bytes_X_Tree is Bytes_X_Trees.Binary_Search_Tree;
   
   
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
      
   
   procedure Remove_Obsolete_Locations
     (Locations         : in out Location_Tree;
      Input             : in     Dynamic_Byte_Array;
      Counter           : in     Natural_64) is
      
      X                 : Integer_64;
      L                 : Natural_64;
      Found             : Boolean;
      
   begin
      X := Counter - Natural_64(Deflate_Distance'Last) - 1;
      if X >= Input.First then
         Locations.Find_First(L, Found);
         while Found and then L <= X loop
            Locations.Remove(L);
            Locations.Find_First(L, Found);
         end loop;
      end if;
   end Remove_Obsolete_Locations;
   
   
   procedure Find_Longest_Match
     (Input             : in     Dynamic_Byte_Array;
      C                 : in     Natural_64;
      Locations         : in out Location_Tree;
      Found             : out    Boolean;
      Length            : out    Deflate_Length;
      Distance          : out    Deflate_Distance) is
      
      Tri               : Tribyte;
      Longest_Len       : Deflate_Length;
      Longest_Loc       : Natural_64;
      L                 : Natural_64;
      Len               : Natural_64;
      L_Found           : Boolean;
      
   begin
      Found := FALSE;
      Length := Deflate_Length'First;
      Distance := Deflate_Distance'First;
      if not Locations.Is_Empty then
         Longest_Len := Deflate_Length'First;
         Longest_Loc := C;
         Locations.Find_Last(L, L_Found);
         while L_Found loop
            Len := Match_Length(Input, C, L);
            if C - L <= Natural_64(Deflate_Distance'Last) then
               Found := TRUE;
               if Longest_Loc = C or Len > Natural_64(Longest_Len) then
                  Longest_Loc := L;
                  if Len >= Natural_64(Deflate_Length'Last) then
                     Longest_Len := Deflate_Length'Last;
                     exit;
                  else
                     Longest_Len := Deflate_Length(Len);
                  end if;
               end if;
            else
               exit;
            end if;
            Locations.Find_Previous(L, L_Found);
         end loop;
         if Found then
            Length := Longest_Len;
            Distance := Deflate_Distance(C - Longest_Loc);
         end if;
      end if;
   end Find_Longest_Match;
   
   
   procedure Compress
     (Input             : in     Dynamic_Byte_Array;
      Output            : out    Dynamic_LLD_Array) is
      
      procedure Free is new Ada.Unchecked_Deallocation (Location_Tree, Location_Tree_Access);
      
      use Location_Tree_Controlled_Accesses;
      
      C                 : Natural_64;
      Tri               : Tribyte;
      Tri_Next          : Tribyte;
      Tritree           : Tribyte_Tree;
      Length            : Deflate_Length;
      Distance          : Deflate_Distance;
      Length_2          : Deflate_Length;
      Distance_2        : Deflate_Distance;
      Found             : Boolean;
      LLD               : Literal_Length_Distance;
      B                 : Byte;
      X                 : Integer_64;
      Matches_Found     : Boolean;
      BX                : Bytes_X;
      BX_Next           : Bytes_X;
      BX_Tree           : Bytes_X_Tree;
      
   begin
      C := Input.First;
      loop
         exit when Input.Last - C < 3;
         
         -- Find matches
         Matches_Found := FALSE;
         Input.Get(C, Tri);
         if Tritree.Contains(Tri) then
            declare
               Locations      : Location_Tree_Access := Access_to(Tritree.Get(Tri));
            begin
               if not Locations.Is_Empty then
               -- Matches found. Find the longest one and output length/distance.
                  Matches_Found := TRUE;
               
                  Find_Longest_Match(Input, C, Locations.all, Found, Length, Distance);
                  if Found then
                     Input.Get(C + 1, Tri_Next);
                     if Tritree.Contains(Tri_Next) then
                        Find_Longest_Match(Input, C + 1, Access_to(Tritree.Get(Tri_Next)).all, Found, Length_2, Distance_2);
                        if Found and then (Length_2 - Length >= 2) then
                           Matches_Found := FALSE;
                        end if;
                     end if;
                  end if;
               end if;

               Locations.Put(C, C);
               
               if Matches_Found then
                 LLD := 
                    (Is_Literal  => FALSE,
                     Length      => Length,
                     Distance    => Distance);
               
                  -- Add all tribytes within the skipped distance to the tree
                  -- Remove stuff that the skipped distance renders obsolete
                  
                  for I in C + 1 .. C + Natural_64(Length) loop
                     exit when Input.Last - I < 2;
                     X := I - Natural_64(Deflate_Distance'Last) - 1;
                     if X >= Input.First then
                        Input.Get(X, Tri);
                        if Tritree.Contains(Tri) then
                           Remove_Obsolete_Locations(Access_to(Tritree.Get(Tri)).all, Input, I);
                        end if;
                     end if;
                  end loop;
                  
                  for I in C + 1 .. C + Natural_64(Length) - 1 loop
                     exit when Input.Last - I < 2;
                     
                     Input.Get(I, Tri);
                     if not Tritree.Contains(Tri) then
                        Tritree.Put(Tri, Create);
                     end if;
                     Access_to(Tritree.Get(Tri)).Put(I, I);
                  end loop;
               end if;
            end;
         else -- if Tritree.Contains(Tri)
            Tritree.Put(Tri, Create);
            Access_to(Tritree.Get(Tri)).Put(C, C);
         end if;
         
         if Matches_Found then
            C := C + Natural_64(Length);
         else
            -- Output literal.
            -- Remove the location that becomes obsolete.
            Input.Read(C, B);
            LLD := 
              (Is_Literal  => TRUE,
               Literal     => B);
            
            X := C - Natural_64(Deflate_Distance'Last) - 1;
            if X >= Input.First then
               Input.Get(X, Tri);
               if Tritree.Contains(Tri) then
                  Remove_Obsolete_Locations(Access_to(Tritree.Get(Tri)).all, Input, C);
               end if;
            end if;
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
--      Min_Len_Weight    : Natural_64;
      
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
      
--        -- All literals need to be in the alphabet
--        for L in Literal_Length_Letter range 0 .. 255 loop
--           if LL_Weights(L) = 0 then
--              LL_Weights(L) := 1;
--           end if;
--        end loop;
      
      -- EOB must be in the alphabet
      LL_Weights (End_of_Block) := 1;
      
   end Count_Weights;
   
   
   procedure LLD_Array_to_Bit_Array
     (LLDs              : in     Dynamic_LLD_Array;
      LL_Code           : in     Literal_Length_Huffman.Huffman_Code;
      Distance_Code     : in     Distance_Huffman.Huffman_Code;
      Output            : in out Dynamic_Bit_Array) is
      
      LL_CWs            : Literal_Length_Huffman.Huffman_Codewords := LL_Code.Get_Codewords;
      Distance_CWs      : Distance_Huffman.Huffman_Codewords := Distance_Code.Get_Codewords;
      LLD               : Literal_Length_Distance;
      Length_L          : Length_Letter;
      Distance_L        : Distance_Letter;
      Extra_Bits        : Dynamic_Bit_Array;
      
   begin
      for I in LLDs.First .. LLDs.Last loop
         LLD := LLDs.Get(I);
         if LLD.Is_Literal then
            Output.Add(LL_CWs(Literal_Length_Letter(LLD.Literal)));
         else
            Length_Value_to_Code(LLD.Length, Length_L, Extra_Bits);
            Output.Add(LL_CWs(Length_L));
            Output.Add(Extra_Bits);
            Distance_Value_to_Code(LLD.Distance, Distance_L, Extra_Bits);
            Output.Add(Distance_CWs(Distance_L));
            Output.Add(Extra_Bits);
         end if;
      end loop;
   end LLD_Array_to_Bit_Array;
   
   
   procedure LLD_Array_to_ASCII
     (LLDs              : in     Dynamic_LLD_Array;
      Input             : in     Dynamic_Byte_Array;
      Output            : out    Dynamic_Byte_Array) is

      LLD               : Literal_Length_Distance;
      C                 : Natural_64 := Input.First;
      
   begin
      for I in LLDs.First .. LLDs.Last loop
         LLD := LLDs.Get(I);
         if LLD.Is_Literal then
            Output.Add(LLD.Literal);
            C := C + 1;
         else
            declare
               S_Len    : String := Deflate_Length'Image(LLD.Length);
               S_Dist   : String := Deflate_Distance'Image(LLD.Distance);
               
            begin
               Output.Add(Character'Pos('['));
               for I in S_Len'Range loop
                  Output.Add(Byte(Character'Pos(S_Len(I))));
               end loop;
               Output.Add(Character'Pos(','));
               for I in S_Dist'Range loop
                  Output.Add(Byte(Character'Pos(S_Dist(I))));
               end loop;
               Output.Add(Character'Pos(']'));
               Output.Add(Character'Pos('='));
               Output.Add(Character'Pos('"'));
               for X in 0 .. LLD.Length - 1 loop
                  Output.Add
                    (Input.Get
                       (C + Natural_64(X) - Natural_64(LLD.Distance)));
               end loop;
               Output.Add(Character'Pos('"'));
               C := C + Natural_64(LLD.Length);
            end;
         end if;
      end loop;
   end LLD_Array_to_ASCII;
   
   
end Deflate.LZ77;
