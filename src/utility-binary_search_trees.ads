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
   
   function Get
     (This              : in     Binary_Search_Tree;
      Key               : in     Key_Type)
                          return Element_Type;
   
   
private

   type RB_Color is (Red, Black);
   
   type RB_Node;
   type RB_Node_Access is access RB_Node;
   type RB_Node is
      record
         P              : RB_Node_Access;
         Left           : RB_Node_Access;
         Right          : RB_Node_Access;
         Key            : Key_Type;
         Color          : RB_Color;
         Count          : Positive_64 := 1;
      end record;
      
   type Binary_Search_Tree is new Ada.Finalization.Controlled with
      record
         Root           : RB_Node_Access;
      end record;


end Utility.Binary_Search_Trees;
