------------------------------------------------------------------------
--
--       Copyright (c) 2019, Hannu Örn
--       All rights reserved.
--
-- Author: Hannu Örn
--
------------------------------------------------------------------------

with Utility;                 use Utility;
with Utility.Binary_Search_Trees;
with Utility.Controlled_Accesses;


package Deflate.LZ77 is

   type Tribyte is array (1 .. 3) of Byte;
   
   -- List of locations where a tribyte can be found
   
   package Tribyte_Location_Trees is new Utility.Binary_Search_Trees
      (Natural_64, Natural_64, "<", "=");
      
   subtype Tribyte_Location_Tree is Tribyte_Location_Trees.Binary_Search_Tree;
   type Tribyte_Location_Tree_Access is access Tribyte_Location_Tree;
      
   -- Tree of tribytes, given a tribyte, gives list of locations for it

   package Tribyte_Location_Tree_Controlled_Accesses is 
         new Controlled_Accesses
               (Tribyte_Location_Tree, Tribyte_Location_Tree_Access);
   subtype Tribyte_Location_Tree_Controlled_Access is
         Tribyte_Location_Tree_Controlled_Accesses.Controlled_Access;
               
   package Tribyte_Trees is new Utility.Binary_Search_Trees
      (Tribyte, Tribyte_Location_Tree_Controlled_Access, "<", "=");

   procedure Not_Implemented;
   
end Deflate.LZ77;
