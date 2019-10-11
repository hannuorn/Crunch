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
--       DEFLATE Compressed Data Format Specification version 1.3
--    * Wikipedia: Huffman coding
--
------------------------------------------------------------------------

with Ada.Unchecked_Deallocation;
with Ada.Text_IO; use Ada.Text_IO;
with Utility.Binary_Search_Trees;


package body Deflate.Huffman is

   procedure Free is new Ada.Unchecked_Deallocation
     (Huffman_Tree_Node, Huffman_Tree_Node_Access);
     

   procedure Initialize
     (Object            : in out Huffman_Tree) is
     
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
     (Object            : in out Huffman_Tree) is
     
   begin
      Adjust_Subtree(Object.Root);
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
     (Object            : in out Huffman_Tree) is
     
   begin
      Free_Subtree(Object.Root);
   end Finalize;


   function To_String
     (Code              : in     Huffman_Code)
                          return String is
                          
      S                 : String(1 .. Integer(Code.Length));
      C                 : Bit_Array := Code.Get;
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
     (HT                : in     Huffman_Tree;
      Code              : in     Huffman_Code;
      Found             : out    Boolean;
      S                 : out    Symbol) is
      
      C                 : Bit_Array := Code.Get;
      Node              : Huffman_Tree_Node_Access;
      
   begin
      Found := FALSE;
      S := Symbol'First;
      Node := HT.Root;
      for I in C'Range loop
         exit when Node = null or else Node.Is_Leaf;
         case C(I) is
            when 0 => Node := Node.Edge_0;
            when 1 => Node := Node.Edge_1;
         end case;
      end loop;
      if Node /= null and then Node.Is_Leaf then
         Found := TRUE;
         S := Node.S;
      end if;
   end Find;


   procedure Find
     (Tree              : in     Huffman_Tree;
      Stream            : in     Huffman_Code;
      Counter           : in out Natural_64;
      Found             : out    Boolean;
      S                 : out    Symbol) is
      
      Node              : Huffman_Tree_Node_Access;
      I                 : Natural_64;
      
   begin
      Found := FALSE;
      S := Symbol'First;
      Node := Tree.Root;
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
         S := Node.S;
         Counter := I;
      end if;
   end Find;


   -- Trivial conversion from Natural to an array of bits.
   function To_Huffman_Code
     (N                 : in     Natural_64;
      Length            : in     Bit_Length)
                          return Huffman_Code is

      X                 : Natural_64;
      Bits              : Bit_Array(0 .. Natural_64(Limited_Bit_Length'Last));
      I                 : Bit_Length;
      C                 : Huffman_Code;
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
   end To_Huffman_Code;
   
   
   procedure Add_to_Tree
     (Tree              : in out Huffman_Tree;
      S                 : in     Symbol;
      HC                : in     Huffman_Code) is
      
      C                 : Bit_Array := HC.Get;
      Node              : Huffman_Tree_Node_Access;
      
   begin
      if HC.Length > 0 then
         Node := Tree.Root;
         for B in C'Range loop
            pragma Assert(not Node.Is_Leaf);
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
         Node.S := S;
      end if;
   end Add_to_Tree;
   
   
   procedure Build_Tree_From_Dictionary
     (Tree              : out    Huffman_Tree;
      D                 : in     Dictionary) is
      
   begin
      Tree.Root := new Huffman_Tree_Node;
      Tree.Root.Is_Leaf := FALSE;
      for S in D'Range loop
         Add_to_Tree(Tree, S, D(S));
      end loop;
      Tree.Has_Frequencies := FALSE;
      Tree.Codes := D;
   end Build_Tree_From_Dictionary;
   

------------------------------------------------------------------------
-- Build
--
-- Implementation Notes:
--    This procedure builds the Huffman tree using a sequence 
--    of bit lenghts as described in RFC 1951 3.2.2.
------------------------------------------------------------------------

   procedure Build
     (Tree              : out    Huffman_Tree;
      Lengths           : in     Bit_Lengths) is
      
      type Bit_Length_Array is array (Limited_Bit_Length) of Natural_64;
      
      BL_Count          : Bit_Length_Array := (others => 0);
      Next_Code         : Bit_Length_Array := (others => 0);
      Code              : Natural_64;
      Previous_Count    : Natural_64;
      D                 : Dictionary;
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
      Code := 0;
      for Bits in 1 .. Max_Len loop
         Code := 2*(Code + Previous_Count);
         Next_Code(Bits) := Code;
         Previous_Count := BL_Count(Bits);
      end loop;
      
      -- 3) Assign numerical values to all codes
      for S in D'Range loop
         Len := Lengths(S);
         if Len /= 0 then
            D(S) := To_Huffman_Code(Next_Code(Len), Len);
            Next_Code(Len) := Next_Code(Len) + 1;
         end if;
      end loop;

      -- Convert the dictionary to a tree
      Build_Tree_From_Dictionary(Tree, D);
   end Build;


   function Build
     (Lengths           : in     Bit_Lengths)
                          return Huffman_Tree is
   
      HT                : Huffman_Tree;
      
   begin
      Build(HT, Lengths);
      return HT;
   end Build;


   procedure Fill_in_Bit_Lengths
     (Lengths           : in out Bit_Lengths;
      Depth             : in     Bit_Length;
      Node              : in     Huffman_Tree_Node_Access) is
      
   begin
      if Node /= null then
         if Node.Is_Leaf then
            Lengths(Node.S) := Depth;
         else
            Fill_in_Bit_Lengths(Lengths, Depth + 1, Node.Edge_0);
            Fill_in_Bit_Lengths(Lengths, Depth + 1, Node.Edge_1);
         end if;
      end if;
   end Fill_in_Bit_Lengths;
   

   function Get_Bit_Lengths
     (Tree              : in     Huffman_Tree)
                          return Bit_Lengths is

      BL                : Bit_Lengths(Symbol'Range) := (others => 0);
      
   begin
      Fill_in_Bit_Lengths(BL, 0, Tree.Root);
      return BL;
   end Get_Bit_Lengths;


   procedure Fill_in_Dictionary
     (D                 : in out Dictionary;
      Node              : in     Huffman_Tree_Node_Access;
      Root_C            : in     Huffman_Code) is
      
      C0                : Huffman_Code;
      C1                : Huffman_Code;
      
   begin
      if Node /= null then
         if Node.Is_Leaf then
            D(Node.S) := Root_C;
         else
            C0 := Root_C;
            C0.Add(0);
            C1 := Root_C;
            C1.Add(1);
            Fill_in_Dictionary(D, Node.Edge_0, C0);
            Fill_in_Dictionary(D, Node.Edge_1, C1);
         end if;
      end if;
   end Fill_in_Dictionary;


   function Get_Code_Values
     (Tree              : in     Huffman_Tree)
                          return Dictionary is
      
      C                 : Huffman_Code;
      D                 : Dictionary;
      
   begin
      return Tree.Codes;
   end Get_Code_Values;


   type Huffman_Build_Key is
      record
         Frequency      : Natural_64;
         First_S        : Symbol;
      end record;
   
   
   function "<"
     (Left, Right       : in     Huffman_Build_Key)
                          return Boolean is

   begin
      if Left.Frequency = Right.Frequency then
         return Left.First_S < Right.First_S;
      else
         return Left.Frequency < Right.Frequency;
      end if;
   end "<";
   
   
   ---------------------------------------------------------------------
   -- Build
   --
   -- Implementation Notes:
   --    This procedure builds an optimal Huffman code
   --    given the frequency of each symbol.
   --
   --    Refer to Wikipedia: Huffman coding, chapter 'Basic technique'.
   ---------------------------------------------------------------------

   procedure Build
     (Tree              : out    Huffman_Tree;
      Frequencies       : in     Symbol_Frequencies) is

      package Sorted_Lists is new Binary_Search_Trees
        (Huffman_Build_Key, Huffman_Tree_Node_Access, "<", "=");
      
      HT                : Huffman_Tree;
      List              : Sorted_Lists.Binary_Search_Tree;
      Key_0             : Huffman_Build_Key;
      Key_1             : Huffman_Build_Key;
      Node_0            : Huffman_Tree_Node_Access;
      Node_1            : Huffman_Tree_Node_Access;
      N                 : Huffman_Tree_Node_Access;
      
   begin
      for S in Frequencies'Range loop
         if Frequencies(S) > 0 then
            N := new Huffman_Tree_Node;
            N.all :=
                 (Is_Leaf  => TRUE,
                  S        => S,
                  Edge_0   => null,
                  Edge_1   => null);
            List.Put
                 (Key   => (Frequency => Frequencies(S), First_S => S),
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
               S        => Symbol'First,
               Edge_0   => Node_0,
               Edge_1   => Node_1);
         List.Put
              (Key   => (Frequency => Key_0.Frequency + Key_1.Frequency,
                         First_S => Key_0.First_S),
               Value => N);
      end loop;
      HT.Root := N;
      -- HT is now a non-canonical Huffman code.
      -- We use it only for bit lengths of the codes
      -- and build a canonical code from those lengths.
      Tree.Build(Get_Bit_Lengths(HT));
      Tree.Has_Frequencies := TRUE;
      Tree.Frequencies := Frequencies;
   end Build;


   ---------------------------------------------------------------------
   -- Build
   --
   -- Implementation Notes:
   --    This procedure builds a length-limited Huffman code
   --    using the package-merge algorithm. Refer to
   --    
   --       Sayodd, Khalid (2012), Introduction to data compression,
   --       Morgan Kaufmann, 4th ed.
   --
   --          3.2.3 Length-Limited Huffman Codes
   ---------------------------------------------------------------------
   procedure Build_Length_Limited
     (Lengths           : out    Bit_Lengths;
      Length_Max        : in     Positive;
      Frequencies       : in     Symbol_Frequencies) is
      
      package Letter_Trees is new Utility.Binary_Search_Trees
            (Symbol, Symbol, "<", "="); use Letter_Trees;
      subtype Letter_Tree is Letter_Trees.Binary_Search_Tree;
      
      type Package_Merge_Item is
         record
            Frequency         : Natural_64;
            Letters           : Letter_Tree;
         end record;
         
      function "<"
        (Left, Right          : in     Package_Merge_Item)
                                return Boolean is

      begin
         if Left.Frequency = Right.Frequency then
            if Left.Letters.Size = Right.Letters.Size then
               return Left.Letters < Right.Letters;
            else
               return Left.Letters.Size < Right.Letters.Size;
            end if;
         else
            return Left.Frequency < Right.Frequency;
         end if;
      end "<";
      
      package Package_Merge_Trees is new Utility.Binary_Search_Trees
            (Package_Merge_Item, Natural, "<", "=");
      subtype Package_Merge_Tree is Package_Merge_Trees.Binary_Search_Tree;
      
      procedure Print
        (Item              : in     Package_Merge_Item) is
      
         L                 : Symbol;
         OK                : Boolean;
         
      begin
         Put_Line("   Frequency =" & Natural_64'Image(Item.Frequency));
         Put("   Letters: ");
         Item.Letters.Find_First(L, OK);
         while OK loop
            Put(Symbol'Image(L));
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
         OK                : Boolean;
        
      begin
         Put_Line("Package-Merge items:");
         PMT.Find_First(I, OK);
         while OK loop
            Print(I);
            PMT.Find_Next(I, OK);
         end loop;
      end Print;
      

      PM_Letters           : Package_Merge_Tree;
      PM_Package           : Package_Merge_Tree;
      PM_Merge             : Package_Merge_Tree;
      I1, I2               : Package_Merge_Item;
      OK, L_OK             : Boolean;
      L                    : Symbol;
      I                    : Natural_64;
      Packages             : Natural_64;
      Alphabet_Size        : Natural_64 := 0;

   begin
      -- Initialize the list of letters.
      for S in Frequencies'Range loop
         if Frequencies(S) > 0 then
            Alphabet_Size := Alphabet_Size + 1;
            declare
               Letters        : Letter_Tree;
            begin
               Letters.Put(S, S);
               I1 := (Frequencies(S), Letters);
               PM_Letters.Put(I1, 0);
            end;
         end if;
      end loop;
      PM_Merge := PM_Letters;
      for Iterations in 1 .. Length_Max - 1 loop
         I1 := PM_Merge.First;
         I2 := PM_Merge.Next(I1);
         -- take items from merged list and group them two-by-two
         PM_Package.Clear;
         Packages := PM_Merge.Size/2;
         for Package_Steps in 1 .. Packages loop
            declare
               Letters        : Letter_Tree;
            begin
               I1.Letters.Find_First(L, OK);
               while OK loop
                  Letters.Put(L, L);
                  I1.Letters.Find_Next(L, OK);
               end loop;
               I2.Letters.Find_First(L, OK);
               while OK loop
                  Letters.Put(L, L);
                  I2.Letters.Find_Next(L, OK);
               end loop;
               PM_Package.Put(
                    (Frequency => I1.Frequency + I2.Frequency,
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
      -- Count number of items containing each letter
      Print(PM_Merge);
      Put_Line("Symbols in use: " & Natural_64'Image(Alphabet_Size));
      I := 0;
      PM_Merge.Find_First(I1, OK);
      while OK loop
         exit when I = 2*Alphabet_Size - 2;
         I := I + 1;
         I1.Letters.Find_First(L, L_OK);
         while L_OK loop
            Lengths(L) := Lengths(L) + 1;
            if Lengths(L) > Bit_Length(Length_Max) then
               Put_Line("Warning. Symbol " & Symbol'Image(L) & " now has " &
                     "bit length of " & Bit_Length'Image(Lengths(L)));
            end if;
            I1.Letters.Find_Next(L, L_OK);
         end loop;
         PM_Merge.Find_Next(I1, OK);
      end loop;
   end Build_Length_Limited;


   procedure Print
     (Lengths           : in     Bit_Lengths) is
     
   begin
      Put_Line("Symbol : code length");
      for I in Lengths'Range loop
         if Lengths(I) > 0 then
            Put_Line(Symbol'Image(I) & " : " & Bit_Length'Image(Lengths(I)));
         end if;
      end loop;
      Put_Line("");
   end Print;
   

   procedure Print
     (Tree              : in     Huffman_Tree) is

      type Symbol_Info is 
         record
            S                 : Symbol;
            Frequency         : Natural_64;
            Code              : Huffman_Code;
         end record;
         
      function "<"
        (Left                 : in     Symbol_Info;
         Right                : in     Symbol_Info)
                                return Boolean is

      begin
         if Left.S = Right.S then
            return FALSE;
         elsif Left.Frequency = Right.Frequency then
            if Left.Code.Length = Right.Code.Length then
               return Left.S < Right.S;
            else
               return Left.Code.Length > Right.Code.Length;
            end if;
         else
            return Left.Frequency < Right.Frequency;
         end if;
      end "<";
      
      function Symbol_Equals
        (Left, Right          : in     Symbol_Info)
                                return Boolean is
                                
      begin
         return Left.S = Right.S;
      end Symbol_Equals;
      
      
      package Symbol_Info_Trees is new Utility.Binary_Search_Trees
            (Symbol_Info, Symbol_Info, "<", Symbol_Equals);
      type Bit_Length_Array is array (Limited_Bit_Length) of Natural;
      
      BL_Count          : Bit_Length_Array := (others => 0);
     
      D                 : Dictionary;
      SI                : Symbol_Info_Trees.Binary_Search_Tree;
      Freq              : Natural_64;
      Info              : Symbol_Info;
      OK                : Boolean;
   
   begin
      Put_Line("Huffman printout");
      Put_Line("");
      Put_Line("Alphabet size:" & Natural'Image(
            Symbol'Pos(Symbol'Last) - Symbol'Pos(Symbol'First) + 1));
            
      if Tree.Has_Frequencies then
         Put_Line("This tree was built from frequencies.");
      else
         Put_Line("This tree was built from code lengths.");
      end if;
      Put_Line("");

      -- Build sorted statistics
      D := Tree.Get_Code_Values;
      for I in D'Range loop
         Freq := 0;
         if Tree.Has_Frequencies then
            Freq := Tree.Frequencies(I);
         end if;
         Info := 
              (S => I,
               Frequency => Freq,
               Code => D(I));
         if Info.Code.Length > 0 then
            SI.Put(Info, Info);
         end if;
      end loop;
      
      -- 10 most/least common symbols, frequency, code length, code

      Put_Line("10 most common symbols:");
      SI.Find_Last(Info, OK);
      for N in 1 .. 10 loop
         exit when not OK;
         if Tree.Has_Frequencies then
            Put_Line("Symbol " & Symbol'Image(Info.S) & 
                  ": frequency" & Natural_64'Image(Info.Frequency) &
                  ", code length =" & Natural_64'Image(Info.Code.Length) & 
                  ", code = " & To_String(Info.Code));
         else
            Put_Line("Symbol '" & Symbol'Image(Info.S) &
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
         if Tree.Has_Frequencies then
            Put_Line("Symbol " & Symbol'Image(Info.S) & 
                  ": frequency" & Natural_64'Image(Info.Frequency) &
                  ", code length =" & Natural_64'Image(Info.Code.Length) & 
                  ", code = " & To_String(Info.Code));
         else
            Put_Line("Symbol " & Symbol'Image(Info.S) &
                  ", code length =" & Natural_64'Image(Info.Code.Length) &
                  ", code = " & To_String(Info.Code));
         end if;
         SI.Find_Next(Info, OK);
      end loop;
      Put_Line("");
      
      -- summary by code length, how many codes for each length
      for I in D'Range loop
         BL_Count(Bit_Length(D(I).Length)) := 
               BL_Count(Bit_Length(D(I).Length)) + 1;
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
