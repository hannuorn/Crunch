package Utility.Test is

   procedure Assert
     (Condition         : in     Boolean);
     
   procedure Assert
     (Condition         : in     Boolean;
      Message           : in     String);

   procedure Begin_Test
     (Title             : in     String);
  
   procedure End_Test;

end Utility.Test;
