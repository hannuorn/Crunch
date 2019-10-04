with Utility.Binary_Search_Trees.Red_Black_Trees;


package body Utility.Binary_Search_Trees is

   package RB_Trees is new Utility.Binary_Search_Trees.Red_Black_Trees;
   use RB_Trees;


   procedure Initialize
     (Object            : in out Binary_Search_Tree) is
     
   begin
      Object.Root := null;
   end Initialize;
   
   
   procedure Adjust
     (Object            : in out Binary_Search_Tree) is
     
   begin
      Object.Root := Copy_of_Subtree(Object.Root);
   end Adjust;


   procedure Finalize
     (Object            : in out Binary_Search_Tree) is
     
   begin
      Free_Subtree(Object.Root);
   end Finalize;


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

                        
   function Contains
     (This              : in     Binary_Search_Tree;
      Key               : in     Key_Type)
                          return Boolean is

   begin
      return RB_Find(This.Root, Key) /= null;
   end Contains;
   
                          
   function Get
     (This              : in     Binary_Search_Tree;
      Key               : in     Key_Type)
                          return Element_Type is
             
      X                 : RB_Node_Access;
      
   begin
      X := RB_Find(This.Root, Key);
      if X = null then
         raise Binary_Search_Tree_Key_Not_Found;
      else
         return X.Value;
      end if;
   end Get;
   

   procedure Add
     (This              : in out Binary_Search_Tree;
      Key               : in     Key_Type;
      Value             : in     Element_Type;
      OK                : out    Boolean) is
      
      X                 : RB_Node_Access;
      
   begin
      if This.Contains(Key) then
         OK := FALSE;
      else
         OK := TRUE;
         X := RB_Node_Create(Key, Value);
         RB_Insert(This.Root, X);
      end if;
   end Add;
      
      
   procedure Put
     (This              : in out Binary_Search_Tree;
      Key               : in     Key_Type;
      Value             : in     Element_Type) is
      
      X                 : RB_Node_Access;
      OK                : Boolean;
      
   begin
      X := RB_Find(This.Root, Key);
      if X = null then
         This.Add(Key, Value, OK);
      else
         X.Value := Value;
      end if;
   end Put;

      
   procedure Remove
     (This              : in out Binary_Search_Tree;
      Key               : in     Key_Type) is
      
      X                 : RB_Node_Access;
      
   begin
      X := RB_Find(This.Root, Key);
      if X /= null then
         RB_Delete(This.Root, X);
      end if;
   end Remove;
   
   
   function First
     (This              : in     Binary_Search_Tree)
                          return Key_Type is

   begin
      return RB_First(This.Root).Key;
   end First;
   
   
   procedure Get_First
     (This              : in     Binary_Search_Tree;
      Key               : out    Key_Type;
      Value             : out    Element_Type) is
      
      X                 : RB_Node_Access;
      
   begin
      X := RB_First(This.Root);
      Key := X.Key;
      Value := X.Value;
   end Get_First;


   function Last
     (This              : in     Binary_Search_Tree)
                          return Key_Type is
                          
   begin
      return RB_Last(This.Root).Key;
   end Last;
   
   
   function Is_Last
     (This              : in     Binary_Search_Tree;
      Key               : in     Key_Type)
                          return Boolean is

      X                 : RB_Node_Access;
      
   begin
      X := RB_Last(This.Root);
      return Key = X.Key;
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
   
   
   procedure Find_First
     (This              : in     Binary_Search_Tree;
      First             : out    Key_Type;
      Found             : out    Boolean) is
      
      X                 : RB_Node_Access;
      
   begin
      X := RB_First(This.Root);
      if X = null then
         Found := FALSE;
      else
         First := X.Key;
         Found := TRUE;
      end if;
   end Find_First;

   
   procedure Find_Next
     (This              : in     Binary_Search_Tree;
      Key               : in out Key_Type;
      Found             : out    Boolean) is
      
      X                 : RB_Node_Access;
      
   begin
      X := RB_Next(This.Root, Key);
      if X = null then
         Found := FALSE;
      else
         Key := X.Key;
         Found := TRUE;
      end if;
   end Find_Next;


end Utility.Binary_Search_Trees;
