private generic package Utility.Binary_Search_Trees.Red_Black_Trees is

   function Copy_of_Subtree
     (From              : in     RB_Node_Access;
      Parent            : in     RB_Node_Access := null)
                          return RB_Node_Access;

   procedure Free_Subtree
     (Node              : in out RB_Node_Access);
     
   function RB_Find
     (Root              : in     RB_Node_Access;
      Key               : in     Key_Type)
                          return RB_Node_Access;
     
   function RB_Node_Create
     (Key               : in     Key_Type;
      Value             : in     Element_Type)
                          return RB_Node_Access;


   function RB_First
     (Z                 : in     RB_Node_Access)
                          return RB_Node_Access;
   
   function RB_Last
     (Z                 : in     RB_Node_Access)
                          return RB_Node_Access;
   
   procedure RB_Insert
     (Root              : in out RB_Node_Access;
      Z                 : in out RB_Node_Access);

   procedure RB_Delete
     (Root              : in out RB_Node_Access;
      Z                 : in out RB_Node_Access);

   function RB_Next
     (Root              : in     RB_Node_Access;
      Key               : in     Key_Type)
                          return RB_Node_Access;

end Utility.Binary_Search_Trees.Red_Black_Trees;
