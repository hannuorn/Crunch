pragma Assertion_Policy(Check);

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
      pragma Assert(Condition);
   end Assert;
   
     
   procedure Assert
     (Condition         : in     Boolean;
      Message           : in     String) is
      
   begin
      if Condition = FALSE then
         Print(Message);
      end if;
      pragma Assert(Condition);
   end Assert;
   

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
