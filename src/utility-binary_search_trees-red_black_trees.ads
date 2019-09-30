private package Utility.Binary_Search_Trees.Red_Black_Trees is

   function Copy_of_Subtree
     (From              : in     RB_Node_Access;
      Parent            : in     RB_Node_Access := null)
                          return RB_Node_Access;

   procedure Free_Subtree
     (Node              : in out RB_Node_Access);
   

end Utility.Binary_Search_Trees.Red_Black_Trees;
