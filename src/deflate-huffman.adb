------------------------------------------------------------------------
--
--       Copyright (c) 2019, Hannu Örn
--       All rights reserved.
--
-- Author: Hannu Örn
--
------------------------------------------------------------------------

 
------------------------------------------------------------------------
--
-- package Deflate.Huffman
-- 
-- Implementation Notes:
--    This generic package implements Huffman codes for 
--    a given alphabet.
--
-- References:
--    * RFC 1951, 
--      DEFLATE Compressed Data Format Specification version 1.3
--    * Wikipedia: Huffman coding
--    * Sayood, Khalid (2012), Introduction to data compression,
--      Morgan Kaufmann, 4th ed.
--
------------------------------------------------------------------------

with Ada.Unchecked_Deallocation;
with Ada.Text_IO; use Ada.Text_IO;
with Utility.Binary_Search_Trees;


package body Deflate.Huffman is

   procedure Free is new Ada.Unchecked_Deallocation
        (Huffman_Tree_Node, Huffman_Tree_Node_Access);
     

   procedure Initialize
     (Object            : in out Huffman_Code) is
     
   begin
      null;
   end Initialize;
   
   
   procedure Adjust_Subtree
     (Node              : in out Huffman_Tree_Node_Access) is
   
      N                 : Huffman_Tree_Node_Access;

   begin
      if Node /= null then
         N := new Huffman_Tree_Node;
         N.all := Node.all;
         Adjust_Subtree(N.Edge_0);
         Adjust_Subtree(N.Edge_1);
         Node := N;
      end if;
   end Adjust_Subtree;
   
      
   procedure Adjust
     (Object            : in out Huffman_Code) is
     
   begin
      Adjust_Subtree(Object.Tree);
   end Adjust;
   
   
   procedure Free_Subtree
     (Node              : in out Huffman_Tree_Node_Access) is
     
   begin
      if Node /= null then
         Free_Subtree(Node.Edge_0);
         Free_Subtree(Node.Edge_1);
         Free(Node);
      end if;
   end Free_Subtree;
   
   
   procedure Finalize
     (Object            : in out Huffman_Code) is
     
   begin
      Object.Has_Weights := FALSE;
      Object.Weights := (others => 0);
      Object.Lengths := (others => 0);
      Object.Codewords := (others => Dynamic_Bit_Arrays.Empty_Dynamic_Array);
      Free_Subtree(Object.Tree);
   end Finalize;


   function To_String
     (Codeword          : in     Huffman_Codeword)
                          return String is
                          
      S                 : String(1 .. Integer(Codeword.Length));
      C                 : Bit_Array := Codeword.Get_Array;
      I                 : Natural;
      
   begin
      I := 1;
      for J in C'Range loop
         case C(J) is
            when 0 =>   S(I) := '0';
            when 1 =>   S(I) := '1';
         end case;
         I := I + 1;
      end loop;
      return S;
   end To_String;
   
                          
   procedure Find
     (Code              : in     Huffman_Code;
      Stream            : in     Dynamic_Bit_Array;
      Counter           : in out Natural_64;
      Found             : out    Boolean;
      L                 : out    Letter) is
      
      
      Node              : Huffman_Tree_Node_Access;
      I                 : Natural_64;
      
   begin
      Found := FALSE;
      L := Letter'First;
      Node := Code.Tree;
      I := Counter;
      loop
         exit when Node = null or else Node.Is_Leaf;
         case Stream.Get(Index => I) is
            when 0 => Node := Node.Edge_0;
            when 1 => Node := Node.Edge_1;
         end case;
         I := I + 1;
      end loop;
      if Node /= null and then Node.Is_Leaf then
         Found := TRUE;
         L := Node.L;
         Counter := I;
      end if;
   end Find;


   function To_Huffman_Codeword
     (N                 : in     Natural_64;
      Length            : in     Bit_Length)
                          return Huffman_Codeword is

      X                 : Natural_64;
      Bits              : Bit_Array(0 .. Natural_64(Limited_Bit_Length'Last));
      I                 : Bit_Length;
      C                 : Huffman_Codeword;
      B                 : Bit;
      
   begin
      X := N;
      I := 0;
      while X > 0 and I < Limited_Bit_Length'Last loop
         B := Bit(X mod 2);
         Bits(Natural_64(I)) := B;
         X := X / 2;
         I := I + 1;
      end loop;
      -- I is now number of bits written to Bits
      -- First add leading zeros: (Length - I) zeros
      -- Then add the bits in reverse order
      for J in 1 .. Length - I loop
         C.Add(0);
      end loop;
      for K in 1 .. I loop
         C.Add(Bits(Natural_64(I) - Natural_64(K)));
      end loop;
      return C;
   end To_Huffman_Codeword;
   
   
   procedure Add_to_Tree
     (Tree              : in out Huffman_Tree_Node_Access;
      L                 : in     Letter;
      Codeword          : in     Huffman_Codeword) is
      
      C                 : Bit_Array := Codeword.Get_Array;
      Node              : Huffman_Tree_Node_Access;
      
   begin
      if Codeword.Length > 0 then
         Node := Tree;
         for B in C'Range loop
            if C(B) = 0 then
               if Node.Edge_0 = null then
                  Node.Edge_0 := new Huffman_Tree_Node;
               end if;
               Node := Node.Edge_0;
            else
               if Node.Edge_1 = null then
                  Node.Edge_1 := new Huffman_Tree_Node;
               end if;
               Node := Node.Edge_1;
            end if;
            Node.Is_Leaf := FALSE;
         end loop;
         Node.Is_Leaf := TRUE;
         Node.L := L;
      end if;
   end Add_to_Tree;
   
   
   procedure Build_Tree
     (Tree              : in out Huffman_Tree_Node_Access;
      Codewords         : in     Huffman_Codewords) is
      
   begin
      Free_Subtree(Tree);
      Tree := new Huffman_Tree_Node;
      Tree.Is_Leaf := FALSE;
      for L in Codewords'Range loop
         Add_to_Tree(Tree, L, Codewords(L));
      end loop;
   end Build_Tree;
   

   ---------------------------------------------------------------------
   -- Build
   --
   -- Implementation Notes:
   --    This procedure builds the Huffman tree using a sequence 
   --    of bit lenghts as described in RFC 1951 3.2.2.
   ---------------------------------------------------------------------
   procedure Build
     (Code              : out    Huffman_Code;
      Lengths           : in     Huffman_Lengths) is
      
      type Bit_Length_Array is array (Limited_Bit_Length) of Natural_64;
      
      BL_Count          : Bit_Length_Array := (others => 0);
      Next_Code         : Bit_Length_Array := (others => 0);
      Number_Code       : Natural_64;
      Previous_Count    : Natural_64;
      Codewords         : Huffman_Codewords;
      Len               : Bit_Length;
      Max_Len           : Bit_Length := 0;
      
   begin
      -- 1) Count the number of codes for each code length.
      
      for I in Lengths'Range loop
         BL_Count(Lengths(I)) := BL_Count(Lengths(I)) + 1;
         if Lengths(I) > Max_Len then
            Max_Len := Lengths(I);
         end if;
      end loop;
      
      -- 2) Find the numerical value of the smallest code for each code length
      
      Previous_Count := 0;
      Number_Code := 0;
      for Bits in 1 .. Max_Len loop
         Number_Code := 2*(Number_Code + Previous_Count);

         -- Debugging
         -- Put_Line("BL" & Bit_Length'Image(Bits) & ", first code = " &
               -- Natural_64'Image(Number_Code) & ", codes available " & 
               -- Natural_64'Image(Natural_64(2**Natural(Bits)) - Number_Code) &
               -- ", codes used = " & Natural_64'Image(BL_Count(Bits)));
               
         Next_Code(Bits) := Number_Code;
         
         if Next_Code(Bits) > 2**Natural(Bits) then
            Put_Line("WARNING");
            Put_Line("for BL" & Bit_Length'Image(Bits) & ", Next_Code = " &
                  Natural_64'Image(Next_Code(Bits)) & " which is too long!");
         end if;
         Previous_Count := BL_Count(Bits);
      end loop;
      
      -- Debugging
      -- Put_Line("Bit length : MAX number of codes");
      -- for Bits in 1 .. Max_Len loop
         -- Put_Line(Bit_Length'Image(Bits) & " :" & 
               -- Natural_64'Image(Natural_64(2**Natural(Bits)) - Next_Code(Bits)));
      -- end loop;
      
      -- 3) Assign numerical values to all codes
      for L in Codewords'Range loop
         Len := Lengths(L);
         if Len /= 0 then
            Codewords(L) := To_Huffman_Codeword(Next_Code(Len), Len);
            Next_Code(Len) := Next_Code(Len) + 1;
         end if;
      end loop;

      Code.Has_Weights := FALSE;
      Code.Lengths := Lengths;
      Code.Codewords := Codewords;
      Build_Tree(Code.Tree, Codewords);
   end Build;


   function Build
     (Lengths           : in     Huffman_Lengths)
                          return Huffman_Code is
   
      Code              : Huffman_Code;
      
   begin
      Build(Code, Lengths);
      return Code;
   end Build;


   procedure Fill_in_Bit_Lengths
     (Lengths           : in out Huffman_Lengths;
      Depth             : in     Bit_Length;
      Node              : in     Huffman_Tree_Node_Access) is
      
   begin
      if Node /= null then
         if Node.Is_Leaf then
            Lengths(Node.L) := Depth;
         else
            Fill_in_Bit_Lengths(Lengths, Depth + 1, Node.Edge_0);
            Fill_in_Bit_Lengths(Lengths, Depth + 1, Node.Edge_1);
         end if;
      end if;
   end Fill_in_Bit_Lengths;
   

   function Calculate_Lengths
     (Tree              : in     Huffman_Tree_Node_Access)
                          return Huffman_Lengths is

      Lengths           : Huffman_Lengths(Letter);
      
   begin
      Fill_in_Bit_Lengths(Lengths, 0, Tree);
      return Lengths;
   end Calculate_Lengths;


   function Get_Lengths
     (Code              : in     Huffman_Code)
                          return Huffman_Lengths is

   begin
      return Code.Lengths;
   end Get_Lengths;


   function Get_Codewords
     (Code              : in     Huffman_Code)
                          return Huffman_Codewords is
      
   begin
      return Code.Codewords;
   end Get_Codewords;

   
   ---------------------------------------------------------------------
   -- Build
   --
   -- Implementation Notes:
   --    This procedure builds an optimal Huffman code
   --    given the weight of each letter.
   --
   --    Refer to Wikipedia: Huffman coding, chapter 'Basic technique'.
   ---------------------------------------------------------------------
   procedure Build
     (Code              : out    Huffman_Code;
      Weights           : in     Letter_Weights) is

      -- Binary tree is used to maintain the sorted list
      -- required in the algorithm.
      
      type Huffman_Build_Key is
         record
            Weight         : Natural_64;
            First_L        : Letter;
         end record;
      
      -- The list is sorted by weight.
      function "<"
        (Left, Right       : in     Huffman_Build_Key)
                             return Boolean is

      begin
         if Left.Weight = Right.Weight then
            return Left.First_L < Right.First_L;
         else
            return Left.Weight < Right.Weight;
         end if;
      end "<";
      
      package Sorted_Lists is new Binary_Search_Trees
        (Huffman_Build_Key, Huffman_Tree_Node_Access, "<", "=");
      
      List              : Sorted_Lists.Binary_Search_Tree;
      Key_0             : Huffman_Build_Key;
      Key_1             : Huffman_Build_Key;
      Node_0            : Huffman_Tree_Node_Access;
      Node_1            : Huffman_Tree_Node_Access;
      N                 : Huffman_Tree_Node_Access;
      Lengths           : Huffman_Lengths(Letter);
      
   begin
      for L in Weights'Range loop
         if Weights(L) > 0 then
            N := new Huffman_Tree_Node;
            N.all :=
                 (Is_Leaf  => TRUE,
                  L        => L,
                  Edge_0   => null,
                  Edge_1   => null);
            List.Put
                 (Key   => (Weight => Weights(L), First_L => L),
                  Value => N);
         end if;
      end loop;
      while List.Size >= 2 loop
         Key_0 := List.First;
         Node_0 := List.Get(Key_0);
         List.Remove(Key_0);
         Key_1 := List.First;
         Node_1 := List.Get(Key_1);
         List.Remove(Key_1);
         N := new Huffman_Tree_Node;
         N.all :=
              (Is_Leaf  => FALSE,
               L        => Letter'First,
               Edge_0   => Node_0,
               Edge_1   => Node_1);
         List.Put
              (Key   => (Weight  => Key_0.Weight + Key_1.Weight,
                         First_L => Key_0.First_L),
               Value => N);
      end loop;
      -- Code is now a non-canonical Huffman code.
      -- We use it only for bit lengths of the codes
      -- and build a canonical code from those lengths.
      Lengths := Calculate_Lengths(N);
      Free_Subtree(N);
      Code.Build(Lengths);
      Code.Has_Weights := TRUE;
      Code.Weights := Weights;
   end Build;


   ---------------------------------------------------------------------
   -- Build_Length_Limited
   --
   -- Implementation Notes:
   --    This procedure builds a length-limited Huffman code
   --    using the package-merge algorithm. Refer to
   --    
   --       Sayood, Khalid (2012), Introduction to data compression,
   --       Morgan Kaufmann, 4th ed.
   --
   --          3.2.3 Length-Limited Huffman Codes
   ---------------------------------------------------------------------
   procedure Build_Length_Limited
     (Code              : out    Huffman_Code;
      Length_Max        : in     Positive;
      Weights           : in     Letter_Weights) is
      
      package Letter_Trees is new Utility.Binary_Search_Trees
            (Letter, Letter, "<", "="); use Letter_Trees;
      subtype Letter_Tree is Letter_Trees.Binary_Search_Tree;
      
      type Package_Merge_Item is
         record
            Weight            : Natural_64;
            Letters           : Letter_Tree;
         end record;
         
      function "<"
        (Left, Right          : in     Package_Merge_Item)
                                return Boolean is

      begin
         if Left.Weight = Right.Weight then
            if Left.Letters.Size = Right.Letters.Size then
               return Left.Letters < Right.Letters;
            else
               return Left.Letters.Size < Right.Letters.Size;
            end if;
         else
            return Left.Weight < Right.Weight;
         end if;
      end "<";

      function Letters_Equal
        (Left, Right          : in     Package_Merge_Item)
                                return Boolean is

      begin
         return Left.Letters = Right.Letters;
      end Letters_Equal;

      package Package_Merge_Trees is new Utility.Binary_Search_Trees
            (Package_Merge_Item, Natural, "<", Letters_Equal);
      subtype Package_Merge_Tree is Package_Merge_Trees.Binary_Search_Tree;
      
      
      -- Print procedures for debugging purposes
      
      procedure Print
        (Item              : in     Package_Merge_Item) is
      
         L                 : Letter;
         OK                : Boolean;
         
      begin
         Put_Line("   Weight =" & Natural_64'Image(Item.Weight));
         Put("   Letters: ");
         Item.Letters.Find_First(L, OK);
         while OK loop
            Put(Letter'Image(L));
            Item.Letters.Find_Next(L, OK);
            if OK then
               Put(",");
            end if;
         end loop;
         Put_Line("");
         Put_Line("");
      end Print;
      
      procedure Print
        (PMT               : in     Package_Merge_Tree) is

         I                 : Package_Merge_Item;
         N                 : Natural := 0;
         OK                : Boolean;
        
      begin
         Put_Line("Package-Merge items:");
         PMT.Find_First(I, OK);
         while OK loop
            N := N + 1;
            Put_Line("Item #" & Natural'Image(N));
            Print(I);
            PMT.Find_Next(I, OK);
         end loop;
      end Print;
      

      PM_Letters           : Package_Merge_Tree;
      PM_Package           : Package_Merge_Tree;
      PM_Merge             : Package_Merge_Tree;
      I1, I2               : Package_Merge_Item;
      OK, L_OK             : Boolean;
      L                    : Letter;
      I                    : Natural_64;
      Packages             : Natural_64;
      Alphabet_Size        : Natural_64 := 0;
      Lengths              : Huffman_Lengths(Letter);

   begin
      -- Initialize the list of letters.
      for S in Weights'Range loop
         if Weights(S) > 0 then
            Alphabet_Size := Alphabet_Size + 1;
            declare
               Letters        : Letter_Tree;
            begin
               Letters.Put(S, S);
               I1 := (Weights(S), Letters);
               PM_Letters.Put(I1, 0);
            end;
         end if;
      end loop;
      
      PM_Merge := PM_Letters;
      for Iterations in 1 .. Length_Max - 1 loop
      
         -- Take items from merged list and group them two-by-two
         I1 := PM_Merge.First;
         I2 := PM_Merge.Next(I1);
         PM_Package.Clear;
         Packages := PM_Merge.Size/2;
         for Package_Steps in 1 .. Packages loop
            declare
               Letters           : Letter_Tree;
               Sum_Weight        : Natural_64 := 0;
               Add_OK            : Boolean;
            begin
               I1.Letters.Find_First(L, OK);
               while OK loop
                  Letters.Put(L, L);
                  Sum_Weight := Sum_Weight + Weights(L);
                  I1.Letters.Find_Next(L, OK);
               end loop;
               I2.Letters.Find_First(L, OK);
               while OK loop
                  Letters.Add(L, L, Add_OK);
                  if Add_OK then
                     Sum_Weight := Sum_Weight + Weights(L);
                  end if;
                  I2.Letters.Find_Next(L, OK);
               end loop;
               
               PM_Package.Put(
                    (Weight => Sum_Weight,
                     Letters => Letters), 0);
               if Package_Steps < Packages then
                  I1 := PM_Merge.Next(I2);
                  I2 := PM_Merge.Next(I1);
               end if;
            end;
         end loop;
         
         -- Merge the packages and original list of letters
         PM_Merge.Clear;
         PM_Package.Find_First(I1, OK);
         while OK loop
            PM_Merge.Put(I1, 0);
            PM_Package.Find_Next(I1, OK);
         end loop;
         PM_Letters.Find_First(I1, OK);
         while OK loop
            PM_Merge.Put(I1, 0);
            PM_Letters.Find_Next(I1, OK);
         end loop;
      end loop;

      -- Debugging
      -- Put_Line("Symbols in use: " & Natural_64'Image(Alphabet_Size));
      -- Put_Line("Using " & Natural_64'Image(2*Alphabet_Size - 2) & " PM items");
      --
      
      -- Count number of items containing each letter
      I := 0;
      PM_Merge.Find_First(I1, OK);
      for I in 1 .. 2*Alphabet_Size - 2 loop
         I1.Letters.Find_First(L, L_OK);
         while L_OK loop
            Lengths(L) := Lengths(L) + 1;
            I1.Letters.Find_Next(L, L_OK);
         end loop;
         PM_Merge.Find_Next(I1, OK);
      end loop;
      Build(Code, Lengths);
   end Build_Length_Limited;


   procedure Print
     (Lengths           : in     Huffman_Lengths) is

   begin
      Put_Line("Letter : code length");
      for I in Lengths'Range loop
         if Lengths(I) > 0 then
            Put_Line(Letter'Image(I) & " : " & Bit_Length'Image(Lengths(I)));
         end if;
      end loop;
      Put_Line("");
   end Print;


   procedure Print
     (Codewords         : in     Huffman_Codewords) is

   begin
      Put_Line("");
      Put_Line("Huffman_Codewords. Size is" & Integer'Image(Codewords'Length));
      for L in Codewords'Range loop
         Put_Line("      " & Letter'Image(L) & " = " & To_String(Codewords(L)));
      end loop;
      Put_Line("End of Huffman_Codewords.");
      Put_Line("");
   end Print;
   

   procedure Print
     (Code              : in     Huffman_Code) is

      type Symbol_Info is 
         record
            L                 : Letter;
            Weight            : Natural_64;
            Code              : Huffman_Codeword;
         end record;
         
      function "<"
        (Left                 : in     Symbol_Info;
         Right                : in     Symbol_Info)
                                return Boolean is

      begin
         if Left.L = Right.L then
            return FALSE;
         elsif Left.Weight = Right.Weight then
            if Left.Code.Length = Right.Code.Length then
               return Left.L < Right.L;
            else
               return Left.Code.Length > Right.Code.Length;
            end if;
         else
            return Left.Weight < Right.Weight;
         end if;
      end "<";
      
      function Symbol_Equals
        (Left, Right          : in     Symbol_Info)
                                return Boolean is
                                
      begin
         return Left.L = Right.L;
      end Symbol_Equals;
      
      
      package Symbol_Info_Trees is new Utility.Binary_Search_Trees
            (Symbol_Info, Symbol_Info, "<", Symbol_Equals);
      type Bit_Length_Array is array (Limited_Bit_Length) of Natural;
      
      BL_Count          : Bit_Length_Array := (others => 0);
     
      CW                : Huffman_Codewords;
      SI                : Symbol_Info_Trees.Binary_Search_Tree;
      Freq              : Natural_64;
      Info              : Symbol_Info;
      OK                : Boolean;
   
   begin
      Put_Line("Huffman printout");
      Put_Line("");
      Put_Line("Alphabet size:" & Natural'Image(
            Letter'Pos(Letter'Last) - Letter'Pos(Letter'First) + 1));
            
      if Code.Has_Weights then
         Put_Line("This tree was built from Weights.");
      else
         Put_Line("This tree was built from code lengths.");
      end if;
      Put_Line("");

      -- Build sorted statistics
      CW := Code.Get_Codewords;
      for I in CW'Range loop
         Freq := 0;
         if Code.Has_Weights then
            Freq := Code.Weights(I);
         end if;
         Info := 
              (L => I,
               Weight => Freq,
               Code => CW(I));
         if Info.Code.Length > 0 then
            SI.Put(Info, Info);
         end if;
      end loop;
      
      -- 10 most/least common symbols, weight, code length, code

      Put_Line("10 most common symbols:");
      SI.Find_Last(Info, OK);
      for N in 1 .. 10 loop
         exit when not OK;
         if Code.Has_Weights then
            Put_Line("Letter " & Letter'Image(Info.L) & 
                  ": Weight" & Natural_64'Image(Info.Weight) &
                  ", code length =" & Natural_64'Image(Info.Code.Length) & 
                  ", code = " & To_String(Info.Code));
         else
            Put_Line("Letter '" & Letter'Image(Info.L) &
                  "', code length =" & Natural_64'Image(Info.Code.Length) &
                  ", code = " & To_String(Info.Code));
         end if;
         SI.Find_Previous(Info, OK);
      end loop;
      Put_Line("");

      Put_Line("10 least common symbols:");
      SI.Find_First(Info, OK);
      for N in 1 .. 10 loop
         exit when not OK;
         if Code.Has_Weights then
            Put_Line("Letter " & Letter'Image(Info.L) & 
                  ": Weight" & Natural_64'Image(Info.Weight) &
                  ", code length =" & Natural_64'Image(Info.Code.Length) & 
                  ", code = " & To_String(Info.Code));
         else
            Put_Line("Letter " & Letter'Image(Info.L) &
                  ", code length =" & Natural_64'Image(Info.Code.Length) &
                  ", code = " & To_String(Info.Code));
         end if;
         SI.Find_Next(Info, OK);
      end loop;
      Put_Line("");
      
      -- summary by code length, how many codes for each length
      for I in CW'Range loop
         BL_Count(Bit_Length(CW(I).Length)) := 
               BL_Count(Bit_Length(CW(I).Length)) + 1;
      end loop;
      Put_Line("Bit length : Number of codes");
      for I in 1 .. Max_Bit_Length loop
         if BL_Count(Bit_Length(I)) > 0 then
            Put_Line("   " & Bit_Length'Image(Bit_Length(I)) & " :" & 
                  Natural'Image(BL_Count(Bit_Length(I))));
         end if;
      end loop;
   end Print;

   
end Deflate.Huffman;
