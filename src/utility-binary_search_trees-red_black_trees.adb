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
-- package Utility.Binary_Search_Trees.Red_Black_Trees
-- 
-- Implementation Notes:
--    This package is an implementation of Red-Black Trees.
--    For details, refer to chapters 12 and 13 in
--    
--       Cormen, Thomas H., et al. (2009), Introduction to Algorithms,
--       Third Edition. MIT Press.
--
--    The procedures in this package have been written to
--    closely match the routines in the book.
--
------------------------------------------------------------------------

with Ada.Unchecked_Deallocation;
with Utility.Test; use Utility.Test;


package body Utility.Binary_Search_Trees.Red_Black_Trees is

      
   function Subtree_Size
     (X                 : in     RB_Node_Access)
                          return Natural_64 is

   begin
      if X = null then
         return 0;
      else
         return X.Count;
      end if;
   end Subtree_Size;
   

   procedure Update_Count
     (X                 : in     RB_Node_Access) is
     
   begin
      X.Count := Subtree_Size(X.Left) + Subtree_Size(X.Right) + 1;
   end Update_Count;


   ---------------------------------------------------------------------
   -- Left_Rotate
   --
   -- Implementation Notes:
   --    Introduction to Algorithms
   --       13.2 Rotations
   ---------------------------------------------------------------------
   
   procedure Left_Rotate
     (Root              : in out RB_Node_Access;
      X                 : in     RB_Node_Access) is
      
      Y                 : constant RB_Node_Access := X.Right;
      P                 : constant RB_Node_Access := X.P;
      Beta              : constant RB_Node_Access := Y.Left;
      
   begin
      -- X adopts Beta as right child
      X.Right := Beta;
      if Beta /= null then
         Beta.P := X;
      end if;
      
      -- Y replaces X as root of the subtree
      Y.P := P;
      if P = null then
         Root := Y;
      elsif X = P.Left then
         P.Left := Y;
      else
         P.Right := Y;
      end if;
      
      -- Y adopts X as left child
      Y.Left := X;
      X.P := Y;
      
      -- Order matters when updating the counts;
      -- lower node, X, comes first.
      Update_Count(X);
      Update_Count(Y);
   end Left_Rotate;


   procedure Right_Rotate
     (Root              : in out RB_Node_Access;
      Y                 : in     RB_Node_Access) is
      
      X                 : constant RB_Node_Access := Y.Left;
      P                 : constant RB_Node_Access := Y.P;
      Beta              : constant RB_Node_Access := X.Right;
      
   begin
      -- Y adopts Beta as left child
      Y.Left := Beta;
      if Beta /= null then
         Beta.P := Y;
      end if;
      
      -- X replaces Y as root of the subtree
      X.P := P;
      if P = null then
         Root := X;
      elsif Y = P.Left then
         P.Left := X;
      else
         P.Right := X;
      end if;
      
      -- X adopts Y as right child
      X.Right := Y;
      Y.P := X;

      -- Order matters when updating the counts;
      -- lower node, Y, comes first.
      Update_Count(Y);
      Update_Count(X);
   end Right_Rotate;


   ---------------------------------------------------------------------
   -- Is_Black
   -- Is_Red
   --
   -- Implementation Notes:
   --    Introduction to Algorithms
   --       13.1 Properties of red-black trees
   --
   --    The book uses a single 'sentinel node' to represent NIL.
   --    Its color attribute is Black and its other attributes
   --    can take on arbitrary values.
   --
   --    This implementation does not refer to a 'sentinel'.
   --    Instead, simple null is used, and a null node is considered
   --    to be black. This way the the routines that depend on the
   --    concept of a black NIL node can be implemented easily.
   ---------------------------------------------------------------------
  
   function Is_Black
     (X                 : in     RB_Node_Access)
                          return Boolean is

   begin
      return X = null or else X.Color = Black;
   end Is_Black;
   
   
   function Is_Red
     (X                 : in     RB_Node_Access)
                          return Boolean is

   begin
      return not Is_Black(X);
   end Is_Red;
   
   
   ---------------------------------------------------------------------
   -- Iterative_Tree_Search
   -- Tree_Minimum
   -- Tree_Maximum
   -- Tree_Successor
   -- Tree_Predecessor
   --
   -- Implementation Notes:
   --    Introduction to Algorithms
   --       12.2 Querying a binary search tree
   ---------------------------------------------------------------------
   
   function Iterative_Tree_Search
     (Z                 : in     RB_Node_Access;
      K                 : in     Key_Type)
                          return RB_Node_Access is
      
      X                 : RB_Node_Access := Z;
      
   begin
      while X /= null and then K /= X.Key loop
         if K < X.Key then
            X := X.Left;
         else
            X := X.Right;
         end if;
      end loop;
      return X;
   end Iterative_Tree_Search;
   
   
   function Tree_Minimum
     (Z                 : in     RB_Node_Access)
                          return RB_Node_Access is
                          
      X                 : RB_Node_Access := Z;
                          
   begin
      if X /= null then
         while X.Left /= null loop
            X := X.Left;
         end loop;
      end if;
      return X;
   end Tree_Minimum;
   
   
   function Tree_Maximum
     (Z                 : in     RB_Node_Access)
                          return RB_Node_Access is
                          
      X                 : RB_Node_Access := Z;
                          
   begin
      if X /= null then
         while X.Right /= null loop
            X := X.Right;
         end loop;
      end if;
      return X;
   end Tree_Maximum;
   
   
   function Tree_Successor
     (Z                 : in     RB_Node_Access)
                          return RB_Node_Access is
                          
      X                 : RB_Node_Access := Z;
      Y                 : RB_Node_Access;
                          
   begin
      if X /= null then
         if X.Right /= null then
            return Tree_Minimum(X.Right);
         else
            Y := X.P;
            while Y /= null and then X = Y.Right loop
               X := Y;
               Y := Y.P;
            end loop;
            return Y;
         end if;
      else
         return null;
      end if;
   end Tree_Successor;
   
   
   function Tree_Predecessor
     (Z                 : in     RB_Node_Access)
                          return RB_Node_Access is
                          
      X                 : RB_Node_Access := Z;
      Y                 : RB_Node_Access;
                          
   begin
      if X /= null then
         if X.Left /= null then
            return Tree_Maximum(X.Left);
         else
            Y := X.P;
            while Y /= null and then X = Y.Left loop
               X := Y;
               Y := Y.P;
            end loop;
            return Y;
         end if;
      else
         return null;
      end if;
   end Tree_Predecessor;
   
   
   ---------------------------------------------------------------------
   -- RB_Insert_Fixup
   -- RB_Insert
   --
   -- Implementation Notes:
   --    Introduction to Algorithms
   --       13.3 Insertion
   ---------------------------------------------------------------------

   procedure Insert_Fixup_Left_Branch
     (Root              : in out RB_Node_Access;
      Z                 : in out RB_Node_Access) is
     
      Y                 : RB_Node_Access;

   begin
      Y := Z.P.P.Right;
      if Is_Red(Y) then
         Z.P.Color := Black;
         Y.Color := Black;
         Z.P.P.Color := Red;
         Z := Z.P.P;
      else
         if Z = Z.P.Right then
            Z := Z.P;
            Left_Rotate(Root, Z);
         end if;
         Z.P.Color := Black;
         Z.P.P.Color := Red;
         Right_Rotate(Root, Z.P.P);
      end if;
   end Insert_Fixup_Left_Branch;

   
   procedure Insert_Fixup_Right_Branch
     (Root              : in out RB_Node_Access;
      Z                 : in out RB_Node_Access) is

      Y                 : RB_Node_Access;

   begin
      Y := Z.P.P.Left;
      if Is_Red(Y) then
         Z.P.Color := Black;
         Y.Color := Black;
         Z.P.P.Color := Red;
         Z := Z.P.P;
      else
         if Z = Z.P.Left then
            Z := Z.P;
            Right_Rotate(Root, Z);
         end if;
         Z.P.Color := Black;
         Z.P.P.Color := Red;
         Left_Rotate(Root, Z.P.P);
      end if;
   end Insert_Fixup_Right_Branch;
   
   
   procedure RB_Insert_Fixup
     (Root              : in out RB_Node_Access;
      Z                 : in out RB_Node_Access) is

   begin
      while Is_Red(Z.P) loop
         if Z.P = Z.P.P.Left then
            Insert_Fixup_Left_Branch(Root, Z);
         else
            Insert_Fixup_Right_Branch(Root, Z);
         end if;
      end loop;
      Root.Color := Black;
   end RB_Insert_Fixup;
   

   procedure RB_Insert
     (Root              : in out RB_Node_Access;
      Z                 : in out RB_Node_Access) is
      
      X                 : RB_Node_Access;
      Y                 : RB_Node_Access;
      
   begin
      Y := null;
      X := Root;
      while X /= null loop
         Y := X;
         Y.Count := Y.Count + 1;
         if Z.Key < X.Key then
            X := X.Left;
         else
            X := X.Right;
         end if;
      end loop;
      Z.P := Y;
      Z.Count := 1;
      if Y = null then
         Root := Z;
      elsif Z.Key < Y.Key then
         Y.Left := Z;
      else
         Y.Right := Z;
      end if;
      Z.Left := null;
      Z.Right := null;
      Z.Color := Red;
      RB_Insert_Fixup(Root, Z);
   end RB_Insert;


   ---------------------------------------------------------------------
   -- Iterative_Update_Count
   --
   -- Purpose:
   --    Update the node counter of a node and all of its ancestors.
   ---------------------------------------------------------------------
   
   procedure Iterative_Update_Count
     (Z                 : in     RB_Node_Access) is
     
      X                 : RB_Node_Access := Z;
      
   begin
      while X /= null loop
         X.Count := 1 + Subtree_Size(X.Left) + Subtree_Size(X.Right);
         X := X.P;
      end loop;
   end Iterative_Update_Count;
   
   
   ---------------------------------------------------------------------
   -- RB_Transplant
   -- RB_Delete_Fixup
   -- RB_Delete
   --
   -- Implementation Notes:
   --    Introduction to Algorithms
   --       13.4 Deletion
   ---------------------------------------------------------------------
   
   procedure RB_Transplant
     (Root              : in out RB_Node_Access;
      U                 : in     RB_Node_Access;
      V                 : in     RB_Node_Access) is
      
   begin
      if U.P = null then
         Root := V;
      elsif U = U.P.Left then
         U.P.Left := V;
      else
         U.P.Right := V;
      end if;
      if V /= null then
         V.P := U.P;
      end if;
   end RB_Transplant;
   

   procedure Delete_Fixup_Left_Branch
     (Root              : in out RB_Node_Access;
      X                 : in out RB_Node_Access;
      P                 : in out RB_Node_Access) is

      W                 : RB_Node_Access;
      
   begin
      W := P.Right;
      Assert(W /= null);
      if Is_Red(W) then
         W.Color := Black;
         P.Color := Red;
         Left_Rotate(Root, P);
         W := P.Right;
         Assert(W /= null);
      end if;
      if Is_Black(W.Left) and Is_Black(W.Right) then
         W.Color := Red;
         X := P;
         P := X.P;
      else
         if Is_Black(W.Right) then
            W.Left.Color := Black;
            W.Color := Red;
            Right_Rotate(Root, W);
            W := P.Right;
         end if;
         W.Color := P.Color;
         P.Color := Black;
         W.Right.Color := Black;
         Left_Rotate(Root, P);
         X := Root;
      end if;
   end Delete_Fixup_Left_Branch;


   procedure Delete_Fixup_Right_Branch
     (Root              : in out RB_Node_Access;
      X                 : in out RB_Node_Access;
      P                 : in out RB_Node_Access) is

      W                 : RB_Node_Access;
      
   begin
      W := P.Left;
      Assert(W /= null);
      if Is_Red(W) then
         W.Color := Black;
         P.Color := Red;
         Right_Rotate(Root, P);
         W := P.Left;
         Assert(W /= null);
      end if;
      if Is_Black(W.Left) and Is_Black(W.Right) then
         W.Color := Red;
         X := P;
         P := X.P;
      else
         if Is_Black(W.Left) then
            W.Right.Color := Black;
            W.Color := Red;
            Left_Rotate(Root, W);
            W := P.Left;
         end if;
         W.Color := P.Color;
         P.Color := Black;
         W.Left.Color := Black;
         Right_Rotate(Root, P);
         X := Root;
      end if;
   end Delete_Fixup_Right_Branch;


   procedure RB_Delete_Fixup
     (Root              : in out RB_Node_Access;
      X_Init            : in     RB_Node_Access;
      P_Init            : in     RB_Node_Access) is
      
      X                 : RB_Node_Access := X_Init;
      P                 : RB_Node_Access := P_Init;
      
   begin
      while X /= Root and Is_Black(X) loop
         if X = P.Left then
            Delete_Fixup_Left_Branch(Root, X, P);
         else
            Delete_Fixup_Right_Branch(Root, X, P);
         end if;
      end loop;
      if X /= null then
         X.Color := Black;
      end if;
   end RB_Delete_Fixup;


   procedure RB_Delete
     (Root              : in out RB_Node_Access;
      Z                 : in out RB_Node_Access) is
      
      P                 : constant RB_Node_Access := Z.P;
      X, Y              : RB_Node_Access;
      
   begin
      if Z.Left = null or Z.Right = null then
         if Z.Left = null then
            X := Z.Right;
         else
            X := Z.Left;
         end if;
         RB_Transplant(Root, Z, X);
         Iterative_Update_Count(P);
         if Z.Color = Black then
            RB_Delete_Fixup(Root, X, P);
         end if;
      else
         Y := Tree_Minimum(Z.Right);
         RB_Delete(Root, Y);
         Y.Count := Z.Count;
         Y.Color := Z.Color;
         RB_Transplant(Root, Z, Y);
         Y.Left := Z.Left;
         if Y.Left /= null then
            Y.Left.P := Y;
         end if;
         Y.Right := Z.Right;
         if Y.Right /= null then
            Y.Right.P := Y;
         end if;
      end if;
   end RB_Delete;


   function RB_Find
     (Root              : in     RB_Node_Access;
      Key               : in     Key_Type)
                          return RB_Node_Access is
                          
   begin
      return Iterative_Tree_Search(Root, Key);
   end RB_Find;


   function RB_First
     (Z                 : in     RB_Node_Access)
                          return RB_Node_Access is

   begin
      return Tree_Minimum(Z);
   end RB_First;

   
   function RB_Last
     (Z                 : in     RB_Node_Access)
                          return RB_Node_Access is

   begin
      return Tree_Maximum(Z);
   end RB_Last;


   function RB_Next
     (Z                 : in     RB_Node_Access)
                          return RB_Node_Access is

   begin
      return Tree_Successor(Z);
   end RB_Next;
   
   
   function RB_Next
     (Root              : in     RB_Node_Access;
      Key               : in     Key_Type)
                          return RB_Node_Access is

      X                 : RB_Node_Access := Root;
      Lowest            : RB_Node_Access;
      
   begin
      while X /= null loop
         if Key < X.Key then
            Lowest := X;
            X := X.Left;
         else
            X := X.Right;
         end if;
      end loop;
      return Lowest;
   end RB_Next;


   function RB_Previous
     (Root              : in     RB_Node_Access;
      Key               : in     Key_Type)
                          return RB_Node_Access is

      X                 : RB_Node_Access := Root;
      Highest           : RB_Node_Access;
      
   begin
      while X /= null loop
         if Key < X.Key or Key = X.Key then
            X := X.Left;
         else
            Highest := X;
            X := X.Right;
         end if;
      end loop;
      return Highest;
   end RB_Previous;


end Utility.Binary_Search_Trees.Red_Black_Trees;
