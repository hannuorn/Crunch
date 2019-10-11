------------------------------------------------------------------------
--
--       Copyright (c) 2019, Hannu Örn
--       All rights reserved.
--
-- Author: Hannu Örn
--
------------------------------------------------------------------------

pragma Assertion_Policy(Check);

with Ada.Assertions;
with Ada.Text_IO;       use Ada.Text_IO;
with Utility.Test.Discrete_Types;


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
         Print("ASSERT FAILURE: " & Message);
      end if;
      Ada.Assertions.Assert(Condition);
   end Assert;
   
   
   package Natural_Testing    is new Utility.Test.Discrete_Types(Natural);
   package Natural_64_Testing is new Utility.Test.Discrete_Types(Natural_64);
   package Boolean_Testing    is new Utility.Test.Discrete_Types(Boolean);
   
   procedure Assert_Equals
     (Actual            : in     Natural;
      Expected          : in     Natural;
      Message           : in     String) 
      renames Natural_Testing.Assert_Equals;

   procedure Assert_Equals
     (Actual            : in     Natural_64;
      Expected          : in     Natural_64;
      Message           : in     String) 
      renames Natural_64_Testing.Assert_Equals;

   procedure Assert_Equals
     (Actual            : in     Boolean;
      Expected          : in     Boolean;
      Message           : in     String)
      renames Boolean_Testing.Assert_Equals;


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
