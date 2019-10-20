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
with Ada.Float_Text_IO;
with Ada.Sequential_IO;
with Ada.Streams;             use Ada.Streams;
with Ada.Streams.Stream_IO;   use Ada.Streams.Stream_IO;
with Ada.Text_IO;             use Ada.Text_IO;
with Utility;                 use Utility;
with Utility.Dynamic_Arrays;
with Utility.Bits_and_Bytes;  use Utility.Bits_and_Bytes;
with Test_Utility;
with Test_Deflate;
with Deflate;                 use Deflate;
with Deflate.Compression;     use Deflate.Compression;
with Deflate.Decompression;   use Deflate.Decompression;
with Deflate.LZ77;            use Deflate.LZ77;


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
   
      use Dynamic_Bit_Arrays;
      
      Data              : Dynamic_Bit_Array;
--      B                 : Byte;
      C                 : Natural_64 := 0;
      
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
   
   
   procedure Read_File_as_Bytes
     (Name              : in     String;
      Data              : out    Dynamic_Byte_Array) is
      
      package Byte_Sequential_IO is new Ada.Sequential_IO (Byte);
      use Byte_Sequential_IO;
      use Dynamic_Byte_Arrays;
      
      F                 : Ada.Streams.Stream_IO.File_Type;
      Bytes             : Stream_Element_Array (1 .. 1_000_000);
      Last              : Stream_Element_Offset;
      
   begin
      Open(F, In_File, Name);
      Data.Expect_Size(Natural_64(Size(F)));
      while not End_of_File(F) loop
         Read(F, Bytes, Last);
         for I in Bytes'First .. Last loop
            Add(Data, Byte(Bytes(I)));
         end loop;
      end loop;
      Close(F);
   end Read_File_as_Bytes;
   

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
   
   
   procedure Write_File
     (Name              : in     String;
      Data              : in     Dynamic_Byte_Array) is
      
      package Byte_Sequential_IO is new Ada.Sequential_IO (Byte);
      use Byte_Sequential_IO;
      
      F                 : Byte_Sequential_IO.File_Type;
      C                 : Natural_64;
      
   begin
      Create(F, Out_File, Name);
      C := Data.First;
      while C <= Data.Last loop
         Write(F, Data.Get(C));
         C := C + 1;
      end loop;
      Close(F);
   end Write_File;
   
   
   procedure Crunch_Run is
   
      Bytes             : Dynamic_Byte_Array;
      Bits              : Dynamic_Bit_Array;
      Before            : Time;
      After             : Time;
      F                 : Float;
      LLDs              : Dynamic_LLD_Array;

   begin
      Put_Line("Crunch");
      Put_Line("");
      if Argument_Count = 2 then
         if Argument(1) = "-c" then
            Put_Line("Reading " & Argument(2) & "...");
            Before := Clock;
            Read_File_as_Bytes(Argument(2), Bytes);
            After := Clock;
            
            F := Float(Bytes.Length) / 1024.0**2;
            Put("Size:  ");
            Ada.Float_Text_IO.Put(F, Fore => 1, Aft => 2, Exp => 0);
            Put_Line(" MB");
            
            F := Float(Bytes.Length) / 1024.0**2 / Float(After - Before);
            Put("Reading speed: ");
            Ada.Float_Text_IO.Put(Item => F, Fore => 1, Aft => 2, Exp => 0);
            Put_Line(" MB/s");
            
            Put_Line("");
            Put_Line("Compressing...");
            
            Before := Clock;
            Compress(Bytes, Bits);
            After := Clock;
            
            F := Float(Bytes.Length) / Float(1024**2) / Float(After - Before);
            Put("Compressing speed: ");
            Ada.Float_Text_IO.Put(Item => F, Fore => 3, Aft => 2, Exp => 0);
            Put_Line(" MB/s");
            
            F := Float(Bits.Length) / 8.0 / 1024.0**2;
            Put("Compressed vs. original size:  ");
            Ada.Float_Text_IO.Put(Item => F, Fore => 1, Aft => 2, Exp => 0);
            Put(" MB  /  ");
            F := Float(Bytes.Length) / 1024.0**2;
            Ada.Float_Text_IO.Put(Item => F, Fore => 1, Aft => 2, Exp => 0);
            Put_Line("  MB");
            
            F := Float(Bits.Length/8) / Float(Bytes.Length) * 100.0;
            Put("Compression ratio: ");
            Ada.Float_Text_IO.Put(F, Fore => 3, Aft => 1, Exp => 0);
            Put_Line(" %");
            
            Put_Line("");
            
            Put_Line("Writing _crunch file...");
            Write_File(Argument(2) & "_crunch", Bits);
         elsif Argument(1) = "-d" then
            Put_Line("Decompressing " & Argument(2) & "...");
            Read_File(Argument(2), Bits);
            Decompress(Bits, Bytes);
            Write_File(Argument(2) & "_deco", Bytes);
         elsif Argument(1) = "-lz77" then
            Put_Line("Reading " & Argument(2) & "...");
            Before := Clock;
            Read_File_as_Bytes(Argument(2), Bytes);
            Deflate.LZ77.Compress(Bytes, LLDs);
         end if;
      end if;
   end Crunch_Run;
   

   procedure Crunch_Main is
      
   begin
      if Argument_Count = 1 and then Argument(1) = "-test" then
         Crunch_Test;
      elsif Argument_Count = 1 and then Argument(1) = "-demo" then
         Crunch_Demo;
      elsif Argument_Count = 2 then
         Crunch_Run;
      end if;
   end Crunch_Main;
   

end Crunch_Main_Program;
