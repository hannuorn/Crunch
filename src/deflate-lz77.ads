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
with Utility.Dynamic_Arrays;
with Utility.Controlled_Accesses;
with Deflate.Literal_Length_and_Distance;
use  Deflate.Literal_Length_and_Distance;

package Deflate.LZ77 is

   subtype Tribyte is Byte_Array (1 .. 3);
   
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
   
   subtype Tribyte_Tree is Tribyte_Trees.Binary_Search_Tree;

   procedure Not_Implemented;
   
   type Literal_Length_Distance (Is_Literal : Boolean := TRUE) is
      record
         case Is_Literal is
            when TRUE =>
               Literal              : Byte;
            when FALSE =>
               Length               : Deflate_Length;
               Distance             : Deflate_Distance;
         end case;
      end record;
   
   type LLD_Array is array (Natural_64 range <>) of Literal_Length_Distance;
   
   Empty_LLD_Array            : constant LLD_Array (1 .. 0) := 
     (others => (TRUE, 0));
   
   package Dynamic_LLD_Arrays is new Dynamic_Arrays
     (Component_Type    => Literal_Length_Distance,
      Index_Type        => Natural_64,
      Fixed_Array       => LLD_Array,
      Empty_Fixed_Array => Empty_LLD_Array,
      Initial_Size      => 16);
   
   subtype Dynamic_LLD_Array is Dynamic_LLD_Arrays.Dynamic_Array;

   
   procedure Compress
     (Input             : in     Dynamic_Byte_Array;
      Output            : out    Dynamic_LLD_Array);
   
end Deflate.LZ77;
