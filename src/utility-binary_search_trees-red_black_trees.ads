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
-- Purpose:
--    This private child package implements the Red-Black Tree.
--
------------------------------------------------------------------------

private generic package Utility.Binary_Search_Trees.Red_Black_Trees is

   function RB_Find
     (Root              : in     RB_Node_Access;
      Key               : in     Key_Type)
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

   function RB_Previous
     (Root              : in     RB_Node_Access;
      Key               : in     Key_Type)
                          return RB_Node_Access;

end Utility.Binary_Search_Trees.Red_Black_Trees;
