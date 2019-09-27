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
with Test_Utility.Test_Dynamic_Arrays;
with Deflate;                 use Deflate;
with Deflate.Huffman;
with Deflate.Fixed_Huffman;


package body Crunch_Main_Program is


   procedure Crunch_Test is
   
      procedure Test_Crunch is
      
      begin
         Put_Line(Natural_64'Image(Natural_64'Last));
         Put_Line("Test_Crunch...");
         Put_Line("Test_Dynamic_Arrays...");
         Test_Utility.Test_Dynamic_Arrays.Test;
      end Test_Crunch;
   
   
      type Natural_Array is array (Natural range <>) of Natural;
      Empty_Natural_Array : constant Natural_Array (1 .. 0) := (others => 0);
      
      package Dynamic_Natural_Arrays is new Utility.Dynamic_Arrays(
         Natural, Natural, Natural_Array, Empty_Natural_Array);

      type Characters_ABCDEFGH is new Character range 'A' .. 'H';
      package Character_Huffman is new Deflate.Huffman(Characters_ABCDEFGH);
      use Character_Huffman;
      
      DA	         : Dynamic_Natural_Arrays.Dynamic_Array;
      HC          : Huffman_Code;
      HT          : Huffman_Tree;
      D           : Dictionary;
      Found       : Boolean;
      S           : Characters_ABCDEFGH;

   begin
      Put_Line("Crunch");
      Put_Line("");
      Put_Line("Some dumb testing...");
      Test_Crunch;
      Put_Line("");
      Put_Line("Demonstrating RFC 3.2.2.");
      Put_Line("Alphabet is ABCDEFGH");
      Put_Line("Building Huffman tree from bit lengths (3, 3, 3, 3, 3, 2, 4, 4)");
      HT.Build((3, 3, 3, 3, 3, 2, 4, 4));
      Put_Line("Codes in the tree:");
      Put_Line("");
      D := Code_Values(HT);
      for S in D'Range loop
         Put(Character(S));
         Put_Line(" = " & To_String(D(S)));
      end loop;
      Put_Line("");
      HC.Set((0, 1, 0, 1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1, 1, 1, 1,
              1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0));
      Put_Line("Coded bits = " & To_String(HC));
      Put("Decoded string: ");
      
      loop
         HT.Find(HC, Found, S);
         exit when not Found;
         Put(Character(S));
         declare
            B     : Bit_Array := HC.Get;
         begin
            HC.Set(B(B'First + Natural_64(D(S).Length) .. B'Last));
         end;
      end loop;
      Put_Line("");
      Put_Line("");
      Put_Line("Brilliant!");
      Put_Line("Goodbye.");
   end Crunch_Test;


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
   

   procedure Crunch_Main is
      
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
   end Crunch_Main;
   

end Crunch_Main_Program;
