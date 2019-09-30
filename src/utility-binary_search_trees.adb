with Utility.Binary_Search_Trees.Red_Black_Trees;


package body Utility.Binary_Search_Trees is

   procedure Initialize
     (Object            : in out Binary_Search_Tree) is
     
   begin
      null;
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

end Utility.Binary_Search_Trees;
