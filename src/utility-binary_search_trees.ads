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
-- package Utility.Binary_Search_Trees
-- 
-- Purpose:
--    Generic binary tree algorithm.
--
-- Effects:
--    - The expected usage is:
--       1. Call Add or Put to add nodes
--       2. Call Remove to remove nodes
--       3. Call Contains, Get et al. to find data from the tree
--       4. Make a copy of a binary search tree by an assign statement
--       5. Binary tree can be used as a O(n * log n) sorting algorithm:
--          - add data to the tree
--          - enumerate using Find_First and Find_Next
--
-- Performance:
--    Adding, removing, or finding data from the tree: O(log n)
--    Size, Is_Empty: O(1)
--    Making a copy of the tree: O(n)
--    
------------------------------------------------------------------------

with Ada.Finalization;


generic

   type Key_Type is private;
   type Element_Type is private;
   
   with function "<"
     (Left, Right       : in     Key_Type)
                          return Boolean;
   
   with function "="
     (Left, Right       : in     Key_Type)
                          return Boolean;
   
   
package Utility.Binary_Search_Trees is

   type Binary_Search_Tree is tagged private;
   
   Binary_Search_Tree_Key_Not_Found : exception;
   

   ---------------------------------------------------------------------
   -- Size
   --
   -- Purpose:
   --    This function returns the number of nodes in the tree.
   -- Exceptions:
   --    None.
   ---------------------------------------------------------------------
   function Size
     (This              : in     Binary_Search_Tree)
                          return Natural_64;

   function Is_Empty
     (This              : in     Binary_Search_Tree)
                          return Boolean
      with
         Post => Is_Empty'Result = (This.Size = 0);
   
   
   ---------------------------------------------------------------------
   -- Contains
   --
   -- Purpose:
   --    This function checks whether the tree contains a key.
   -- Exceptions:
   --    None.
   ---------------------------------------------------------------------
   function Contains
     (This              : in     Binary_Search_Tree;
      Key               : in     Key_Type)
                          return Boolean;
                          
   ---------------------------------------------------------------------
   -- Get
   --
   -- Purpose:
   --    This function retrieves a value from the tree.
   -- Exceptions:
   --    Binary_Search_Tree_Key_Not_Found
   ---------------------------------------------------------------------
   function Get
     (This              : in     Binary_Search_Tree;
      Key               : in     Key_Type)
                          return Element_Type
      with
         Pre => This.Contains(Key);
         

   ---------------------------------------------------------------------
   -- Add
   --
   -- Purpose:
   --    This procedure adds a node to the tree.
   --    If a node with the given key already exists,
   --    OK will return FALSE and the tree will remain unchanged.
   -- Exceptions:
   --    None.
   ---------------------------------------------------------------------
   procedure Add
     (This              : in out Binary_Search_Tree;
      Key               : in     Key_Type;
      Value             : in     Element_Type;
      OK                : out    Boolean)
      
      with
         Post => This.Contains(Key);
      
      
   ---------------------------------------------------------------------
   -- Put
   --
   -- Purpose:
   --    This procedure adds or updates a node.
   --    If a node with the given key already exists,
   --    the value will be updated.
   -- Exceptions:
   --    None.
   ---------------------------------------------------------------------
   procedure Put
     (This              : in out Binary_Search_Tree;
      Key               : in     Key_Type;
      Value             : in     Element_Type)
      
      with
         Post => This.Contains(Key);

      
   ---------------------------------------------------------------------
   -- Remove
   --
   -- Purpose:
   --    This procedure removes a node from the tree.
   --    If a node with the given key does not exist,
   --    the tree remains unchanged.
   -- Exceptions:
   --    None.
   ---------------------------------------------------------------------
   procedure Remove
     (This              : in out Binary_Search_Tree;
      Key               : in     Key_Type)
      
      with
         Post => not This.Contains(Key);
   
   
   ---------------------------------------------------------------------
   -- First
   --
   -- Purpose:
   --    This function returns the smallest key in the tree.
   --    An exception is raised if the tree is empty.
   -- Exceptions:
   --    Binary_Search_Tree_Key_Not_Found
   ---------------------------------------------------------------------
   function First
     (This              : in     Binary_Search_Tree)
                          return Key_Type
      with
         Pre => not This.Is_Empty;
   
   -- procedure Get_First
     -- (This              : in     Binary_Search_Tree;
      -- Key               : out    Key_Type;
      -- Value             : out    Element_Type)
      
      -- with
         -- Pre => not This.Is_Empty;


   function Last
     (This              : in     Binary_Search_Tree)
                          return Key_Type
      with
         Pre => not This.Is_Empty;
   
   function Is_Last
     (This              : in     Binary_Search_Tree;
      Key               : in     Key_Type)
                          return Boolean
      with
         Post => Is_Last'Result = (Key = This.Last);
         
   function Next
     (This              : in     Binary_Search_Tree;
      Key               : in     Key_Type)
                          return Key_Type
      with
         Pre => not This.Is_Empty;
   
   function Previous
     (This              : in     Binary_Search_Tree;
      Key               : in     Key_Type)
                          return Key_Type
      with
         Pre => not This.Is_Empty;
   
   ---------------------------------------------------------------------
   -- Find_First
   -- Find_Next
   --
   -- Purpose:
   --    These procedures allow easy enumeration of the tree.
   --    Parameter Found returns FALSE when there are no more nodes.
   -- Exceptions:
   --    None.
   ---------------------------------------------------------------------
   procedure Find_First
     (This              : in     Binary_Search_Tree;
      First             : out    Key_Type;
      Found             : out    Boolean);
   
   procedure Find_Next
     (This              : in     Binary_Search_Tree;
      Key               : in out Key_Type;
      Found             : out    Boolean);  
   
   ---------------------------------------------------------------------
   -- Verify
   --
   -- Purpose:
   --    For testing purposes only. This procedure will verify the
   --    integrity of the data structure.
   -- Exceptions:
   --    Assertion_Error
   ---------------------------------------------------------------------
   procedure Verify
     (This              : in     Binary_Search_Tree);
      
   
private

   type RB_Color is (Red, Black);
   
   type RB_Node;
   type RB_Node_Access is access RB_Node;
   type RB_Node is
      record
         P              : RB_Node_Access;
         Left           : RB_Node_Access;
         Right          : RB_Node_Access;
         Count          : Positive_64 := 1;
         Color          : RB_Color;
         Key            : Key_Type;
         Value          : Element_Type;
      end record;
      
   type Binary_Search_Tree is new Ada.Finalization.Controlled with
      record
         Root           : RB_Node_Access;
      end record;


   procedure Initialize
     (Object            : in out Binary_Search_Tree);

   procedure Adjust
     (Object            : in out Binary_Search_Tree);

   procedure Finalize
     (Object            : in out Binary_Search_Tree);


end Utility.Binary_Search_Trees;
