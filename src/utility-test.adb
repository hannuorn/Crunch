pragma Assertion_Policy(Check);

with Ada.Assertions;
with Ada.Text_IO;       use Ada.Text_IO;


package body Utility.Test is

   Indent_Width         : constant Natural := 3;
   Indent_Count         : Natural := 0;
   
   
   function Indent return String is
   
      S                 : String (1 .. Indent_Width * Indent_Count)
                           := (others => ' ');
      
   begin
      return S;
   end Indent;
   

   procedure Print
     (S                 : in     String) is
     
   begin
      Put_Line(Indent & S);
   end Print;
   

   procedure Assert
     (Condition         : in     Boolean) is
     
   begin
      Ada.Assertions.Assert(Condition);
   end Assert;
   
     
   procedure Assert
     (Condition         : in     Boolean;
      Message           : in     String) is
      
   begin
      if Condition = FALSE then
         Print(Message);
      end if;
      Ada.Assertions.Assert(Condition);
   end Assert;
   
                          
   procedure Assert_Equals
     (Actual            : in     Data_Type;
      Expected          : in     Data_Type;
      Message           : in     String) is
      
   begin
      if not (Actual = Expected) then
         Print(
               Message & ", expected = " & Data_Type'Image(Expected) & 
               ", actual = " & Data_Type'Image(Actual));
      end if;
      Ada.Assertions.Assert(Actual = Expected);
   end Assert_Equals;
   

   procedure Begin_Test
     (Title             : in     String) is
     
   begin
      Print(Title);
      Indent_Count := Indent_Count + 1;
   end Begin_Test;
   
  
   procedure End_Test is
   
   begin
      Indent_Count := Indent_Count - 1;
   end End_Test;
   

end Utility.Test;
