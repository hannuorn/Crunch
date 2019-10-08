package Utility.Test is

   procedure Assert
     (Condition         : in     Boolean);
     
   procedure Assert
     (Condition         : in     Boolean;
      Message           : in     String);

   generic 
      type Data_Type is range <>;
      
   procedure Assert_Equals
     (Actual            : in     Data_Type;
      Expected          : in     Data_Type;
      Message           : in     String);

   procedure Begin_Test
     (Title             : in     String);
  
   procedure End_Test;

end Utility.Test;
