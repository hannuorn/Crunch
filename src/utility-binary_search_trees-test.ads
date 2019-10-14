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
-- package Utility.Binary_Search_Trees.Test
-- 
-- Purpose:
--    Implement procedures to check the integrity of the red-black tree.
--    This is for testing purposes only;
--    These tests should never fail unless there is a bug in the
--    red-black implementation (or the test itself).
--
------------------------------------------------------------------------

private generic package Utility.Binary_Search_Trees.Test is

   ---------------------------------------------------------------------
   -- Verify_Counters
   --
   -- Purpose:
   --    This procedure verifies that the node counter is correct for
   --    every node in the subtree.
   -- Exceptions:
   --    Assertion_Error
   ---------------------------------------------------------------------
   procedure Verify_Counters
     (X                 : in     RB_Node_Access);

   ---------------------------------------------------------------------
   -- Verify_Red_Black_Properties
   --
   -- Purpose:
   --    This procedure verifies that red-black properties
   --    are satisfied in the tree.
   -- Exceptions:
   --    Assertion_Error
   ---------------------------------------------------------------------
   procedure Verify_Red_Black_Properties
     (Root              : in     RB_Node_Access);

end Utility.Binary_Search_Trees.Test;
