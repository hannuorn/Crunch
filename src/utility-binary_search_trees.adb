------------------------------------------------------------------------
--
--       Copyright (c) 2019, Hannu �rn
--       All rights reserved.
--
-- Author: Hannu �rn
--
------------------------------------------------------------------------


------------------------------------------------------------------------
--
-- package Utility.Binary_Search_Trees
-- 
-- Implementation Notes:
--    This package implements a simple binary tree interface.
--    The actual tree algorithms can be found in a child package.
--    
------------------------------------------------------------------------

with Ada.Unchecked_Deallocation;
with Utility.Binary_Search_Trees.Red_Black_Trees;
with Utility.Binary_Search_Trees.Test;


package body Utility.Binary_Search_Trees is

   package RB_Trees is new Utility.Binary_Search_Trees.Red_Black_Trees;
   use RB_Trees;
   
   package RB_Test is new Utility.Binary_Search_Trees.Test;
   use RB_Test;

   procedure Free is new Ada.Unchecked_Deallocation
      (RB_Node, RB_Node_Access);
      

   function Copy_of_Subtree
     (From              : in     RB_Node_Access;
      Parent            : in     RB_Node_Access := null)
                          return RB_Node_Access is
      
      N                 : RB_Node_Access;
      
   begin
      if From /= null then
         N := new RB_Node;
         N.all :=
           (P        => Parent,
            Left     => Copy_of_Subtree(From => From.Left, Parent => N),
            Right    => Copy_of_Subtree(From => From.Right, Parent => N),
            Color    => From.Color,
            Count    => From.Count,
            Key      => From.Key,
            Value    => From.Value);
      end if;
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
   end Free_Subtree;
   
   
   procedure Initialize
     (Object            : in out Binary_Search_Tree) is
     
   begin
      Object.Root := null;
      Object.Last_Find := null;
   end Initialize;
   
   
   procedure Adjust
     (Object            : in out Binary_Search_Tree) is
     
   begin
      Object.Root := Copy_of_Subtree(Object.Root);
      Object.Last_Find := null;
   end Adjust;


   procedure Finalize
     (Object            : in out Binary_Search_Tree) is
     
   begin
      Free_Subtree(Object.Root);
      Object.Last_Find := null;
   end Finalize;


   function "="
     (Left, Right       : in     Binary_Search_Tree)
                          return Boolean is

      L, R              : Key_Type;
      L_OK, R_OK        : Boolean;

   begin
      if Left.Size /= Right.Size then
         return False;
      elsif Left.Size = 0 then
         return True;
      else
         Left.Find_First(L, L_OK);
         Right.Find_First(R, R_OK);
         loop
            if L /= R then
               return False;
            elsif RB_Find(Left.Root, L).Value /= RB_Find(Right.Root, L).Value then
               return False;
            else
               Left.Find_Next(L, L_OK);
               Right.Find_Next(R, R_OK);
            end if;
            exit when not L_OK;
         end loop;
      end if;
      return True;
   end "=";


   function "<"
     (Left, Right       : in     Binary_Search_Tree)
                          return Boolean is

      L, R              : Key_Type;
      L_OK, R_OK        : Boolean;
      
   begin
      Left.Find_First(L, L_OK);
      Right.Find_First(R, R_OK);
      if not L_OK and not L_OK then
         return False;
      elsif L_OK /= R_OK then
         return Left.Size < Right.Size;
      else
         loop
            if L /= R then
               return L < R;
            else
               Left.Find_Next(L, L_OK);
               Right.Find_Next(R, R_OK);
               if not L_OK and not R_OK then
                  return False;
               elsif L_OK /= R_OK then
                  return Left.Size < Right.Size;
               end if;
            end if;
         end loop;
      end if;
   end "<";


   function Size
     (This              : in     Binary_Search_Tree)
                          return Natural_64 is

   begin
      if This.Root = null then
         return 0;
      else
         return This.Root.Count;
      end if;
   end Size;
   

   function Is_Empty
     (This              : in     Binary_Search_Tree)
                          return Boolean is

   begin
      return This.Size = 0;
   end Is_Empty;


   procedure Clear
     (This              : in out Binary_Search_Tree) is
     
   begin
      Finalize(This);
      Initialize(This);
   end Clear;


   function Contains
     (This              : in out Binary_Search_Tree;
      Key               : in     Key_Type)
                          return Boolean is

      X                 : RB_Node_Access;
      
   begin
      if This.Last_Find /= null and then This.Last_Find.Key = Key then
         return True;
      else
         X := RB_Find(This.Root, Key);
         if X /= null then
            This.Last_Find := X;
         end if;
         return X /= null;
      end if;
   end Contains;
   
                          
   function Get
     (This              : in out Binary_Search_Tree;
      Key               : in     Key_Type)
                          return Element_Type is
             
      X                 : RB_Node_Access;
      
   begin
      if This.Last_Find /= null and then This.Last_Find.Key = Key then
         X := This.Last_Find;
      else
         X := RB_Find(This.Root, Key);
         if X = null then
            raise Binary_Search_Tree_Key_Not_Found;
         else
            This.Last_Find := X;
         end if;
      end if;
      return X.Value;
   end Get;
   

   function Create_Node
     (Key               : in     Key_Type;
      Value             : in     Element_Type)
                          return RB_Node_Access is

      X                 : RB_Node_Access;
      
   begin
      X := new RB_Node;
      X.Count := 1;
      X.Key := Key;
      X.Value := Value;
      return X;
   end Create_Node;

   
   procedure Add_without_Checking
     (This              : in out Binary_Search_Tree;
      Key               : in     Key_Type;
      Value             : in     Element_Type) is
      
      X                 : RB_Node_Access;
      
   begin
      X := Create_Node(Key, Value);
      RB_Insert(This.Root, X);
      This.Last_Find := X;
   end Add_without_Checking;
   

   procedure Add
     (This              : in out Binary_Search_Tree;
      Key               : in     Key_Type;
      Value             : in     Element_Type;
      OK                : out    Boolean) is
      
   begin
      if This.Contains(Key) then
         OK := False;
      else
         OK := True;
         Add_without_Checking(This, Key, Value);
      end if;
   end Add;
      
      
   procedure Put
     (This              : in out Binary_Search_Tree;
      Key               : in     Key_Type;
      Value             : in     Element_Type) is
      
      X                 : RB_Node_Access;
      
   begin
      if This.Last_Find /= null and then This.Last_Find.Key = Key then
         X := This.Last_Find;
      else
         X := RB_Find(This.Root, Key);
      end if;
      if X = null then
         Add_without_Checking(This, Key, Value);
      else
         X.Value := Value;
         This.Last_Find := X;
      end if;
   end Put;

      
   procedure Remove
     (This              : in out Binary_Search_Tree;
      Key               : in     Key_Type) is
      
      X                 : RB_Node_Access;
      
   begin
      X := RB_Find(This.Root, Key);
      if X /= null then
         if This.Last_Find = X then
            This.Last_Find := null;
         end if;
         RB_Delete(This.Root, X);
         Free(X);
      end if;
   end Remove;
   
   
   function First
     (This              : in out Binary_Search_Tree)
                          return Key_Type is

      X                 : RB_Node_Access;
      
   begin
      X := RB_First(This.Root);
      This.Last_Find := X;
      return X.Key;
   end First;
   

   function Last
     (This              : in out Binary_Search_Tree)
                          return Key_Type is
                          
      X                 : RB_Node_Access;
      
   begin
      X := RB_Last(This.Root);
      This.Last_Find := X;
      return X.Key;
   end Last;
   
   
   function Is_Last
     (This              : in out Binary_Search_Tree;
      Key               : in     Key_Type)
                          return Boolean is

   begin
      return This.Last = Key;
   end Is_Last;
   
         
   function Next
     (This              : in     Binary_Search_Tree;
      Key               : in     Key_Type)
                          return Key_Type is

      X                 : RB_Node_Access;
      
   begin
      X := RB_Next(This.Root, Key);
      return X.Key;
   end Next;
   
   
   function Previous
     (This              : in     Binary_Search_Tree;
      Key               : in     Key_Type)
                          return Key_Type is

      X                 : RB_Node_Access;
      
   begin
      X := RB_Previous(This.Root, Key);
      return X.Key;
   end Previous;
   
   
   procedure Find_First
     (This              : in     Binary_Search_Tree;
      Key               : out    Key_Type;
      Found             : out    Boolean) is
      
      X                 : RB_Node_Access;
      
   begin
      X := RB_First(This.Root);
      if X = null then
         Found := False;
      else
         Key := X.Key;
         Found := True;
      end if;
   end Find_First;

   
   procedure Find_Last
     (This              : in     Binary_Search_Tree;
      Key               : out    Key_Type;
      Found             : out    Boolean) is
      
      X                 : RB_Node_Access;
      
   begin
      X := RB_Last(This.Root);
      if X = null then
         Found := False;
      else
         Key := X.Key;
         Found := True;
      end if;
   end Find_Last;

   
   procedure Find_Next
     (This              : in     Binary_Search_Tree;
      Key               : in out Key_Type;
      Found             : out    Boolean) is
      
      X                 : RB_Node_Access;
      
   begin
      X := RB_Next(This.Root, Key);
      if X = null then
         Found := False;
      else
         Key := X.Key;
         Found := True;
      end if;
   end Find_Next;


   procedure Find_Previous
     (This              : in     Binary_Search_Tree;
      Key               : in out Key_Type;
      Found             : out    Boolean) is
      
      X                 : RB_Node_Access;
      
   begin
      X := RB_Previous(This.Root, Key);
      if X = null then
         Found := False;
      else
         Key := X.Key;
         Found := True;
      end if;
   end Find_Previous;


   procedure Verify
     (This              : in     Binary_Search_Tree) is
      
   begin
      Verify_Counters(This.Root);
      Verify_Red_Black_Properties(This.Root);
   end Verify;

end Utility.Binary_Search_Trees;
