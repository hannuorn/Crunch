with Ada.Finalization;


generic

   type Object is limited private;
   type Name is access Object;
   
   
package Utility.Controlled_Accesses is

   type Controlled_Access is tagged private;

   procedure Assume_Control
     (This                 : out    Controlled_Access;
      X                    : in     Name);
     
   function Access_to
     (This                 : in     Controlled_Access)
                             return Name;

   function Create           return Controlled_Access;
   
         
private

   type Counter is
      record
         Count             : Natural;
         Data              : Name;
      end record;
   type Counter_Access is access Counter;
   
   type Controlled_Access is new Ada.Finalization.Controlled with 
      record
         Counter           : Counter_Access;
      end record;

   procedure Initialize
     (This                 : in out Controlled_Access);

   procedure Adjust
     (This                 : in out Controlled_Access);

   procedure Finalize
     (This                 : in out Controlled_Access);

end Utility.Controlled_Accesses;
