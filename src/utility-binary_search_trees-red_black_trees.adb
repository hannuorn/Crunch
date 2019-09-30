package body Utility.Binary_Search_Trees.Red_Black_Trees is

   procedure Free is new Ada.Unchecked_Deallocation
      (RB_Node, RB_Node_Access);
      
      
   function Copy_of_Subtree
     (From              : in     RB_Node_Access;
      Parent            : in     RB_Node_Access := null)
                          return RB_Node_Access is
                          
   begin
      N := new RB_Node;
      N.all :=
        (P        => Parent,
         Left     => Copy_of_Subtree(From => Root.Left, Parent => N),
         Right    => Copy_of_Subtree(From => Root.Right, Parent => N),
         Key      => From.Key,
         Color    => From.Color,
         Count    => From.Count);
      return N;
   end Copy_of_Subtree;


   procedure Free_Subtree
     (Node              : in out RB_Node_Access) is
     
   begin
      if Node /= null then
         Free_Subtree(Node.Left);
         Free_Subtree(Node.Right);
         Free(Node);
      end if;
   end Free_Subtree);


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
      if Beta /= null
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
   end Right_Rotate;


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
   
   
   function Tree_Minimum
     (X                 : in     RB_Node_Access)
                          return RB_Node_Access is
                          
      Y                 : RB_Node_Access;
                          
   begin
      Y := X;
      while Y.Left /= null then
         Y := Y.Left;
      end loop;
      return Y;
   end Tree_Minimum;
   
   
   function Tree_Maximum
     (X                 : in     RB_Node_Access)
                          return RB_Node_Access is
                          
      Y                 : RB_Node_Access;
                          
   begin
      Y := X;
      while Y.Right /= null then
         Y := Y.Right;
      end loop;
      return Y;
   end Tree_Maximum;
   
   
   function Tree_Successor
     (X                 : in     RB_Node_Access)
                          return RB_Node_Access is
                          
      Y                 : RB_Node_Access;
                          
   begin
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
   end Tree_Successor;
   
   
   function Tree_Predecessor
     (X                 : in     RB_Node_Access)
                          return RB_Node_Access is
                          
      Y                 : RB_Node_Access;
                          
   begin
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
   end Tree_Predecessor;
   
   
   procedure RB_Insert_Fixup
     (Root              : in out RB_Node_Access;
      Z                 : in out RB_Node_Access) is

   begin
      while Is_Red(Z.P) loop
         if Z.P = Z.P.P.Left then
            Y := Z.P.P.Right;
            if Is_Red(Y) then
               Z.P.Color := Black;
               Y.Color := Black;
               Z.P.P.Color := Red;
               Z := Z.P.P;
            elsif Z = Z.P.Right then
               Z := Z.P;
               Left_Rotate(Root, Z);
            end if;
            Z.P.Color := Black;
            Z.P.P.Color := Red;
            Right_Rotate(Root, Z.P.P);
         else -- same as then clause with "right" and "left" exchanged
            Y := Z.P.P.Left;
            if Is_Red(Y) then
               Z.P.Color := Black;
               Y.Color := Black;
               Z.P.P.Color := Red;
               Z := Z.P.P;
            elsif Z = Z.P.Left then
               Z := Z.P;
               Right_Rotate(Root, Z);
            end if;
            Z.P.Color := Black;
            Z.P.P.Color := Red;
            Left_Rotate(Root, Z.P.P);
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
         if Z.Key < X.Key then
            X := X.Left;
         else
            X := X.Right;
         end if;
      end loop;
      Z.P := Y;
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
      V.P := U.P;
   end RB_Transplant;
   
   
   procedure RB_Delete_Fixup
     (Root              : in out RB_Node_Access;
      X                 : in out RB_Node_Access) is
      
      W                 : RB_Node_Access;
      
   begin
      while X /= Root and Is_Black(X) loop
         if X = X.P.Left then
            W := X.P.Right;
            if Is_Red(W) then
               W.Color := Black;
               X.P.Color := Red;
               Left_Rotate(Root, X.P);
               W := X.P.Right;
            end if;
            if Is_Black(W.Left) and Is_Black(W.Right) then
               W.Color := Red;
               X := X.P;
            elsif Is_Black(W.Right) then
               W.Left.Color := Black;
               W.Color := Red;
               Right_Rotate(Root, W);
               W := X.P.Right;
            end if;
            W.Color := X.P.Color;
            X.P.Color := Black;
            W.Right.Color := Black;
            Left_Rotate(Root, X.P);
            X := Root;
         else -- same as then clause with "right" and "left" exchanged
            W := X.P.Left;
            if Is_Red(W) then
               W.Color := Black;
               X.P.Color := Red;
               Right_Rotate(Root, X.P);
               W := X.P.Left;
            end if;
            if Is_Black(W.Left) and Is_Black(W.Right) then
               W.Color := Red;
               X := X.P;
            elsif Is_Black(W.Left) then
               W.Right.Color := Black;
               W.Color := Red;
               Left_Rotate(Root, W);
               W := X.P.Left;
            end if;
            W.Color := X.P.Color;
            X.P.Color := Black;
            W.Left.Color := Black;
            Right_Rotate(Root, X.P);
            X := Root;
         end if;
      end loop;
      if X /= null then
         X.Color := Black;
      end if;
   end RB_Delete_Fixup;
   

   procedure RB_Delete
     (Root              : in out RB_Node_Access;
      Z                 : in out RB_Node_Access) is
      
      X                 : RB_Node_Access;
      Y                 : RB_Node_Access;
      Y_Original_Color  : RB_Color;
      
   begin
      Y := Z;
      Y_Original_Color := Y.Color;
      if Z.Left = null then
         X := Z.Right;
         RB_Transplant(Root, Z, Z.Right);
      elsif Z.Right = null then
         X := Z.Left;
         RB_Transplant(Root, Z, Z.Left);
      else
         Y := Tree_Minimum(Z.Right);
         Y_Original_Color := Y.Color;
         X := Y.Right;
         if Y.P = Z then
            X.P := Y;
         else
            RB_Transplant(Root, Y, Y.Right);
            Y.Right := Z.Right;
            Y.Right.P := Y;
         end if;
         RB_Transplant(Root, Z, Y);
         Y.Left := Z.Left;
         Y.Left.P := Y;
         Y.Color := Z.Color;
      end if;
      if Y_Original_Color = Black then
         RB_Delete_Fixup(Root, X);
      end if;
   end RB_Delete;
         
         
end Utility.Binary_Search_Trees.Red_Black_Trees;
