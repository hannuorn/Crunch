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
with Ada.Text_IO;
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
   

   procedure Put_Line
     (S                 : in     String) is
     
   begin
      Ada.Text_IO.Put_Line(Indent & S);
   end Put_Line;
   

   procedure Put
     (S                 : in     String) is
     
   begin
      Ada.Text_IO.Put(Indent & S);
   end Put;


   procedure Assert
     (Condition         : in     Boolean) is
     
   begin
      if Condition = FALSE then
         Ada.Assertions.Assert(Condition);
      end if;
   end Assert;
   
     
   procedure Assert
     (Condition         : in     Boolean;
      Message           : in     String) is
      
   begin
      if Condition = FALSE then
         Put_Line("ASSERT FAILURE: " & Message);
      end if;
      Ada.Assertions.Assert(Condition);
   end Assert;
   
   
   procedure Assert_Equals
     (Actual            : in     Natural;
      Expected          : in     Natural;
      Message           : in     String) is
      
      package Natural_Testing is new Utility.Test.Discrete_Types(Natural);
      
   begin
      if Actual /= Expected then
         Natural_Testing.Assert_Equals(Actual, Expected, Message);
      end if;
   end Assert_Equals;
   

   procedure Assert_Equals
     (Actual            : in     Natural_64;
      Expected          : in     Natural_64;
      Message           : in     String) is
      
      package Natural_64_Testing is new Utility.Test.Discrete_Types(Natural_64);
      
   begin
      if Actual /= Expected then
         Natural_64_Testing.Assert_Equals(Actual, Expected, Message);
      end if;
   end Assert_Equals;
   
   
   procedure Assert_Equals
     (Actual            : in     Boolean;
      Expected          : in     Boolean;
      Message           : in     String) is
      
      package Boolean_Testing is new Utility.Test.Discrete_Types(Boolean);
      
   begin
      if Actual /= Expected then
         Boolean_Testing.Assert_Equals(Actual, Expected, Message);
      end if;
   end Assert_Equals;
   

   procedure Begin_Test
     (Title             : in     String;
      Is_Leaf           : in     Boolean) is

   begin
      if Is_Leaf then
         Put(Title & "... ");
      else
         Put_Line(Title);
         Indent_Count := Indent_Count + 1;
      end if;
   end Begin_Test;
   
  
   procedure End_Test
     (Is_Leaf           : in     Boolean) is
   
   begin
      if Is_Leaf then
         Ada.Text_IO.Put_Line("ok");
      else
         Ada.Text_IO.Put_Line("");
         Indent_Count := Indent_Count - 1;
      end if;
   end End_Test;
   

end Utility.Test;
