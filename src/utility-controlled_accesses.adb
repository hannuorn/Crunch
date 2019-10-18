with Ada.Unchecked_Deallocation;


package body Utility.Controlled_Accesses is


   procedure Assume_Control
     (This                 : out    Controlled_Access;
      X                    : in     Name) is
      
   begin
      This.Counter := new Counter;
      This.Counter.Count := 1;
      This.Counter.Data := X;
   end Assume_Control;
   

   function Access_to
     (This                 : in     Controlled_Access)
                             return Name is
                             
   begin
      return This.Counter.Data;
   end Access_to;
   
   
   function Create           return Controlled_Access is
   
      X                    : Name;
      CA                   : Controlled_Access;
      
   begin
      X := new Object;
      Assume_Control(CA, X);
      return CA;
   end Create;
   
   
   procedure Initialize
     (This                 : in out Controlled_Access) is
     
   begin
      null;
   end Initialize;
   

   procedure Adjust
     (This                 : in out Controlled_Access) is
     
   begin
      if This.Counter /= null then
         This.Counter.Count := This.Counter.Count + 1;
      end if;
   end Adjust;
   

   procedure Finalize
     (This                 : in out Controlled_Access) is
     
      procedure Free is new Ada.Unchecked_Deallocation
            (Counter, Counter_Access);
      procedure Free is new Ada.Unchecked_Deallocation
            (Object, Name);
            
      C                    : Natural;
      
   begin
      if This.Counter /= null then
         C := This.Counter.Count;
         if C = 1 then
            Free(This.Counter.Data);
            Free(This.Counter);
         else
            This.Counter.Count := C - 1;
         end if;
      end if;
   end Finalize;

   
end Utility.Controlled_Accesses;
