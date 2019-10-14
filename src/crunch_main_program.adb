------------------------------------------------------------------------
--
--       Copyright (c) 2019, Hannu Örn
--       All rights reserved.
--
-- Author: Hannu Örn
--
------------------------------------------------------------------------

 
------------------------------------------------------------------------
--
-- package Crunch_Main_Program
-- 
-- Implementation Notes:
--    None.
--
------------------------------------------------------------------------

with Ada.Calendar;            use Ada.Calendar;
with Ada.Command_Line;        use Ada.Command_Line;
with Ada.Direct_IO;
with Ada.Sequential_IO;
with Ada.Streams;             use Ada.Streams;
with Ada.Streams.Stream_IO;   use Ada.Streams.Stream_IO;
with Ada.Text_IO;             use Ada.Text_IO;
with Utility;                 use Utility;
with Utility.Dynamic_Arrays;
with Utility.Bit_Arrays;      use Utility.Bit_Arrays;
with Test_Utility;
with Test_Deflate;
with Deflate;                 use Deflate;
with Deflate.Compression;     use Deflate.Compression;
--with Deflate.Huffman;
--with Deflate.Fixed_Huffman;


package body Crunch_Main_Program is


   procedure Crunch_Test is
   
   begin
      Put_Line("Crunch - test mode");
      Put_Line("Running unit tests...");
      Put_Line("");
      Test_Utility.Test;
      Test_Deflate.Test;
   end Crunch_Test;


   procedure Crunch_Demo is
   
   begin
      Put_Line("Crunch - demo mode");
      Put_Line("");
      Run_Demo;
   end Crunch_Demo;
   
   
   procedure Read_File
     (Name              : in     String;
      Data              : out    Dynamic_Bit_Array) is
      
      package Byte_Sequential_IO is new Ada.Sequential_IO (Byte);
      use Byte_Sequential_IO;
      package Byte_Direct_IO is new Ada.Direct_IO (Byte);
      use Byte_Direct_IO;
      
      F                 : Ada.Streams.Stream_IO.File_Type;
      Bytes             : Stream_Element_Array (1 .. 1000000);
      Last              : Stream_Element_Offset;
      
   begin
      Open(F, In_File, Name);
      Data.Expect_Size(8*Natural_64(Size(F)));
      while not End_Of_File(F) loop
         Read(F, Bytes, Last);
         for I in Bytes'First .. Last loop
            Add(Data, Byte(Bytes(I)));
         end loop;
      end loop;
      Close(F);
   end Read_File;


   procedure Write_File
     (Name              : in     String;
      Data              : in     Dynamic_Bit_Array) is
      
      package Byte_Sequential_IO is new Ada.Sequential_IO (Byte);
      use Byte_Sequential_IO;
      
      F                 : Byte_Sequential_IO.File_Type;
      C                 : Natural_64;
      B                 : Byte;
      
   begin
      Create(F, Out_File, Name);
      C := Data.First;
      while C <= Data.Last loop
         Read_Byte(Data, C, B);
         Write(F, B);
      end loop;
      Close(F);
   end Write_File;
   
   
   procedure Crunch_Run is
   
      File              : Dynamic_Bit_Array;
      Compressed        : Dynamic_Bit_Array;
      Before            : Time;
      After             : Time;
      F                 : Float;

   begin
      Put_Line("Crunch");
      Put_Line("");
      if Argument_Count = 1 then
         Put_Line("Reading " & Argument(1) & "...");
         Before := Clock;
         Read_File(Argument(1), File);
         After := Clock;
         F := Float(File.Length)/8.0/1024.0/1024.0/Float(After - Before);
         Put_Line("Size: " & Natural_64'Image(File.Length/8) & " bytes");
         Put_Line("Reading time: " & Duration'Image(After - Before) & " seconds");
         Put_Line("Speed: " & Float'Image(F) & " MB/s ");
         Put_Line("");
         Put_Line("Compressing...");
         Before := Clock;
         Compress(File, Compressed);
         After := Clock;
         F := Float(File.Length)/8.0/1024.0/1024.0/Float(After - Before);
         Put_Line("Compression speed: " & Float'Image(F) & " MB/s");
         Put_Line("");
         Put_Line("Writing _crunch...");
         Write_File(Argument(1) & "_crunch", Compressed);
      end if;
   end Crunch_Run;
   

   procedure Crunch_Main is
      
   begin
      if Argument_Count = 1 and then Argument(1) = "-test" then
         Crunch_Test;
      elsif Argument_Count = 1 and then Argument(1) = "-demo" then
         Crunch_Demo;
      else
         Crunch_Run;
      end if;
   end Crunch_Main;
   

end Crunch_Main_Program;
