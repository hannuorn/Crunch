------------------------------------------------------------------------
--
--       Copyright (c) 2019, Hannu Örn
--       All rights reserved.
--
-- Author: Hannu Örn
--
------------------------------------------------------------------------

with Ada.Text_IO;       use Ada.Text_IO;


package body Deflate.LZ77 is

   
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
      X                 : Integer_64;
      Matches_Found     : Boolean;
      
   begin
      C := Input.First;
      loop
         exit when Input.Last - C < 2;
         
         -- Find matches
         Matches_Found := FALSE;
         Input.Get(C, Tri);
         if Tritree.Contains(Tri) then
            Loc := Access_to(Tritree.Get(Tri));
            
            -- Clean up the location tree, remove locations that are too far
            X := C - Natural_64(Deflate_Distance'Last) - 1;
            if X >= Input.First then
               Loc.Find_First(L, Found);
               while Found and then L <= X loop
                  Loc.Remove(L);
                  Loc.Find_First(L, Found);
               end loop;
            end if;
            if not Loc.Is_Empty then
               -- Matches found. Find the longest one and output length/distance.
               Matches_Found := TRUE;
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
                  Length      => Longest_Len,
                  Distance    => Deflate_Distance(C - Longest_Loc));
--                 Put_Line("Location: " & Natural_64'Image(C));
--                 Put_Line("Len-Dist: " & Deflate_Length'Image(Longest_Len) & " - " &
--                            Deflate_Distance'Image(Deflate_Distance(C - Longest_Loc)));
               
               -- Add all tribytes within the skipped distance to the tree
               -- Remove stuff that the skipped distance renders obsolete
               
               for I in C + 1 .. C + Natural_64(Longest_Len) - 1 loop
                  exit when Input.Last - I < 2;
                  
                  -- Add tribyte to tree
                  
                  Input.Get(I, Tri);
                  if Tritree.Contains(Tri) then
                     Loc := Access_to(Tritree.Get(Tri));
                     Loc.Put(I, I);
                  else
                     Loc_Tree := Create;
                     Loc := Access_to(Loc_Tree);
                     Loc.Put(I, I);
                  end if;
                  
                  -- Remove obsoletes
                  
                  X := I - Natural_64(Deflate_Distance'Last) - 1;
                  if X >= Input.First then
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
                  
               end loop;
               C := C + Natural_64(Longest_Len);
            end if;
         else -- if Tritree.Contains(Tri)
            Loc_Tree := Create;
            Loc := Access_to(Loc_Tree);
            Loc.Put(C, C);
            Tritree.Put(Tri, Loc_Tree);
         end if;
         if not Matches_Found then
            -- No matches found. Output literal.
            -- Remove the location that becomes obsolete.
            Input.Read(C, B);
            LLD := 
              (Is_Literal  => TRUE,
               Literal     => B);
            
            X := C - Natural_64(Deflate_Distance'Last) - 1;
            if X >= Input.First then
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
      
      -- All literals need to be in the alphabet
      for L in Literal_Length_Letter range 0 .. 255 loop
         if LL_Weights(L) = 0 then
            LL_Weights(L) := 1;
         end if;
      end loop;
      
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
--        N                 : Natural := 0;
      
   begin
      for I in LLDs.First .. LLDs.Last loop
         LLD := LLDs.Get(I);
         if LLD.Is_Literal then
            Output.Add(LL_CWs(Literal_Length_Letter(LLD.Literal)));
--              if N < 50 then
--                 Put_Line(Literal_Length_Huffman.To_String(LL_CWs(Literal_Length_Letter(LLD.Literal))));
--                 N := N + 1;
--              end if;
--              Put_Line("Literal: " & Byte'Image(LLD.Literal) & " = " & Character'Image(Character'Val(LLD.Literal)));
         else
            Length_Value_to_Code(LLD.Length, Length_L, Extra_Bits);
            Output.Add(LL_CWs(Length_L));
            Output.Add(Extra_Bits);
--              if N < 50 then
--                 Put_Line("Len code: " & Literal_Length_Huffman.To_String(LL_CWs(Length_L)));
--                 Put_Line("Len extra bits: " & Literal_Length_Huffman.To_String(Extra_Bits));
--              end if;
            Distance_Value_to_Code(LLD.Distance, Distance_L, Extra_Bits);
            Output.Add(Distance_CWs(Distance_L));
            Output.Add(Extra_Bits);
--              if N < 50 then
--                 Put_Line("Dist code: " & Distance_Huffman.To_String(Distance_CWs(Distance_L)));
--                 Put_Line("Dist extra bits: " & Distance_Huffman.To_String(Extra_Bits));
--                 N := N + 1;
--              end if;
            
--              Put_Line("Length-Distance: " & Deflate_Length'Image(LLD.Length) &
--                         " - " & Deflate_Distance'Image(LLD.Distance));
         end if;
      end loop;
   end LLD_Array_to_Bit_Array;

   
end Deflate.LZ77;
