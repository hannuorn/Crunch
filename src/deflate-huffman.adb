with Ada.Unchecked_Deallocation;


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
     (HT                : in     Huffman_Tree;
      Stream            : in     Huffman_Code;
      Counter           : in out Natural_64;
      Found             : out    Boolean;
      S                 : out    Symbol) is
      
      Node              : Huffman_Tree_Node_Access;
      I                 : Natural_64;
      
   begin
      Found := FALSE;
      S := Symbol'First;
      Node := HT.Root;
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
     (HT                : in out Huffman_Tree;
      S                 : in     Symbol;
      HC                : in     Huffman_Code) is
      
      C                 : Bit_Array := HC.Get;
      Node              : Huffman_Tree_Node_Access;
      
   begin
      Node := HT.Root;
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
     (HT                : out    Huffman_Tree;
      D                 : in     Dictionary) is
      
   begin
      Free_Subtree(HT.Root);
      HT.Root := new Huffman_Tree_Node;
      HT.Root.Is_Leaf := FALSE;
      for S in D'Range loop
         Add_to_Tree(HT, S, D(S));
      end loop;
   end Build_Tree_From_Dictionary;
   
   
------------------------------------------------------------------------
--    Build the Huffman tree from a sequence of bit lenghts
--    as described in RFC 3.2.2
------------------------------------------------------------------------

   procedure Build
     (HT                : out    Huffman_Tree;
      BL                : in     Bit_Lengths) is
      
      type Bit_Length_Array is array (Bit_Length) of Natural;
      
      BL_Count          : Bit_Length_Array := (others => 0);
      Next_Code         : Bit_Length_Array;
      Code              : Natural;
      Previous_Count    : Natural;
      D                 : Dictionary;
      Len               : Bit_Length;
      
   begin
      -- 1) Count the number of codes for each code length.
      
      for I in BL'Range loop
         BL_Count(BL(I)) := BL_Count(BL(I)) + 1;
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
         Len := BL(S);
         if Len /= 0 then
            D(S) := To_Huffman_Code(Next_Code(Len), Len);
            Next_Code(Len) := Next_Code(Len) + 1;
         end if;
      end loop;

      -- Convert the dictionary to a tree
      Build_Tree_From_Dictionary(HT, D);
   end Build;


   function Build
     (BL                : in     Bit_Lengths)
                          return Huffman_Tree is
   
      HT                : Huffman_Tree;
      
   begin
      Build(HT, BL);
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


   function Code_Values
     (HT                : in     Huffman_Tree)
                          return Dictionary is
      
      C                 : Huffman_Code;
      D                 : Dictionary;
      
   begin
      Fill_in_Dictionary(D, HT.Root, C);
      return D;
   end Code_Values;


end Deflate.Huffman;
