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
------------------------------------------------------------------------

with Utility.Binary_Search_Trees.Red_Black_Trees;
with Utility.Test; use Utility.Test;


package body Utility.Binary_Search_Trees.Test is

   package RB_Trees is new Utility.Binary_Search_Trees.Red_Black_Trees;
   use RB_Trees;
   

   procedure Verify_Counters
     (X                 : in     RB_Node_Access) is

      Left_Count        : Natural_64 := 0;
      Right_Count       : Natural_64 := 0;

   begin
      if X /= null then
         if X.Left /= null then
            Left_Count := X.Left.Count;
         end if;
         if X.Right /= null then
            Right_Count := X.Right.Count;
         end if;
         Assert_Equals(X.Count, 1 + Left_Count + Right_Count, "X.Count");
         Verify_Counters(X.Left);
         Verify_Counters(X.Right);
      end if;
   end Verify_Counters;


   ---------------------------------------------------------------------
   -- Verify_RB_Properties
   --
   -- Implementation Notes:
   --    Introduction to Algorithms
   --       13.1 Properties of red-black trees
   --
   --    This procedure verifies red-black properties 4 and 5.
   --    Properties 1 and 3 are covered by definition of the
   --    data structure. Property 2 is verified by another
   --    procedure below.
   --
   --    To verify that all paths from a node to its descendants
   --    contain the same number of black nodes, a black counter 
   --    is carried in the parameter. Once the first descendant
   --    is reached, Final_Black_Count will be initialized to
   --    a non-zero value. For subsequent descendants, the number
   --    of black nodes along the path are compared to
   --    Final_Black_Count.
   ---------------------------------------------------------------------
   procedure Verify_RB_Properties
     (Node              : in     RB_Node_Access;
      Black_Count       : in     Natural;
      Final_Black_Count : in out Natural) is
      
      B_Count           : Natural;
      
   begin
      if Node /= null then
      
         -- Property 4. If a node is red, then both its children are black.
         -- Keep in mind that a null node is considered black.
         
         if Node.Color = Red then
            Assert_Equals
               ((Node.Left  = null or else Node.Left.Color  = Black) and
                (Node.Right = null or else Node.Right.Color = Black),
                TRUE, "Children of a red node are both black");
         end if;
         B_Count := Black_Count;
         if Node.Color = Black then
            B_Count := B_Count + 1;
         end if;
         if Node.Left = null and Node.Right = null then
         
            -- Property 5. All paths contain the same number of black nodes.
            -- End of the branch has now been reached. Check the number of
            -- blacks along the branch, or initialize the Final_Black_Count
            -- if this was the first descendant reached.
            
            if Final_Black_Count = 0 then
               Final_Black_Count := B_Count;
            else
               Assert_Equals(B_Count, Final_Black_Count, "Black node count");
            end if;
         else
            Verify_RB_Properties(Node.Left,  B_Count, Final_Black_Count);
            Verify_RB_Properties(Node.Right, B_Count, Final_Black_Count);
         end if;
      end if;
   end Verify_RB_Properties;
   
   
   procedure Verify_Red_Black_Properties
     (Root              : in     RB_Node_Access) is
      
      FBC               : Natural := 0;
      
   begin
      if Root /= null then
      
         -- Property 2. The root is black.
         
         Assert_Equals(Root.Color = Black, TRUE, "Root is black");
         Verify_RB_Properties
           (Node => Root, Black_Count => 0, Final_Black_Count => FBC);
      end if;
   end Verify_Red_Black_Properties;


end Utility.Binary_Search_Trees.Test;
