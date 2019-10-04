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
     (N                 : in     Natural;
      Length            : in     Bit_Length)
                          return Huffman_Code is

      X                 : Natural;
      Bits              : Bit_Array(0 .. Natural_64(Bit_Length'Last));
      I                 : Bit_Length;
      C                 : Huffman_Code;
      B                 : Bit;
      
   begin
      X := N;
      I := 0;
      while X > 0 and I < Bit_Length'Last loop
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
   end Build_Tree_From_Dictionary;
   
   
------------------------------------------------------------------------
--    Build the Huffman tree from a sequence of bit lenghts
--    as described in RFC 3.2.2
------------------------------------------------------------------------

   procedure Build
     (Tree              : out    Huffman_Tree;
      Lengths           : in     Bit_Lengths) is
      
      type Bit_Length_Array is array (Bit_Length) of Natural;
      
      BL_Count          : Bit_Length_Array := (others => 0);
      Next_Code         : Bit_Length_Array;
      Code              : Natural;
      Previous_Count    : Natural;
      D                 : Dictionary;
      Len               : Bit_Length;
      
   begin
      -- 1) Count the number of codes for each code length.
      
      for I in Lengths'Range loop
         BL_Count(Lengths(I)) := BL_Count(Lengths(I)) + 1;
      end loop;
      
      -- 2) Find the numerical value of the smallest code for each code length
      
      Previous_Count := 0;
      Code := 0;
      for Bits in BL_Count'Range loop
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


   procedure Fill_in_Bit_Lengths
     (BL                : in out Bit_Lengths;
      Depth             : in     Bit_Length;
      Node              : in     Huffman_Tree_Node_Access) is
      
   begin
      if Node /= null then
         if Node.Is_Leaf then
            BL(Node.S) := Depth;
         else
            Fill_in_Bit_Lengths(BL, Depth + 1, Node.Edge_0);
            Fill_in_Bit_Lengths(BL, Depth + 1, Node.Edge_1);
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


   function Build
     (Lengths           : in     Bit_Lengths)
                          return Huffman_Tree is
   
      HT                : Huffman_Tree;
      
   begin
      Build(HT, Lengths);
      return HT;
   end Build;
   
   
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
      Fill_in_Dictionary(D, Tree.Root, C);
      return D;
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
   
   
   procedure Build
     (Tree              : out    Huffman_Tree;
      Frequencies       : in     Symbol_Frequencies) is

      package Sorted_Lists is new Binary_Search_Trees
        (Huffman_Build_Key, Huffman_Tree_Node_Access, "<", "=");

      
      List              : Sorted_Lists.Binary_Search_Tree;
      Key_0             : Huffman_Build_Key;
      Key_1             : Huffman_Build_Key;
      Node_0            : Huffman_Tree_Node_Access;
      Node_1            : Huffman_Tree_Node_Access;
      N                 : Huffman_Tree_Node_Access;
      
   begin
      Put_Line("Counting symbol frequencies");
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
      Put_Line("Found " & Natural_64'Image(List.Size) & " symbols.");
      Put_Line("Creating Huffman tree...");
      while List.Size >= 2 loop
         List.Get_First(Key_0, Node_0);
         List.Remove(Key_0);
         List.Get_First(Key_1, Node_1);
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
      Tree.Root := N;
   end Build;


end Deflate.Huffman;
