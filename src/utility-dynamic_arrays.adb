with Ada.Unchecked_Deallocation;


package body Utility.Dynamic_Arrays is

   procedure Free is new Ada.Unchecked_Deallocation
      (Fixed_Array, Fixed_Array_Access);

   
   procedure Initialize
     (Object            : in out Dynamic_Array) is
      
   begin
      Object.Data := new Fixed_Array
         (Index'First .. Index'Val(Index'Pos(Index'First) + Initial_Size - 1));
      Object.First := Index'First;
      Object.Length := 0;
   end Initialize;
   
   
   procedure Adjust
     (Object            : in out Dynamic_Array) is
      
      New_Data          : Fixed_Array_Access;
      
   begin
      New_Data := new Fixed_Array(Object.Data'Range);
      if not Object.Is_Empty then
         New_Data(Object.First .. Object.Last) := 
            Object.Data(Object.First .. Object.Last);
      end if;
      Object.Data := New_Data;
   end Adjust;
   
      
   procedure Finalize
     (Object            : in out Dynamic_Array) is
      
   begin
      Free(Object.Data);
   end Finalize;

   
   function Get
     (DA                : in     Dynamic_Array)
                          return Fixed_Array is
      
   begin
      if DA.Is_Empty then
         return Empty_Fixed_Array;
      else
         return DA.Data(DA.First .. DA.Last);
      end if;
   end Get;


   procedure Set
     (DA                : in out Dynamic_Array;
      FA                : in     Fixed_Array) is
      
   begin
      Free(DA.Data);
      DA.Data := new Fixed_Array(FA'Range);
      DA.Data.all := FA;
      DA.First := FA'First;
      DA.Length := FA'Length;
   end Set;
   
   
   function Length
     (DA                : in     Dynamic_Array)
                          return Natural is
      
   begin
      return DA.Length;
   end Length;

   
   function Is_Empty
     (DA                : in     Dynamic_Array)
                          return Boolean is
      
   begin
      return DA.Length = 0;
   end Is_Empty;
   
   
   function First
     (DA                : in     Dynamic_Array)
                          return Index is
      
   begin
      return DA.First;
   end First;
   
   
   function Last
     (DA                : in     Dynamic_Array)
                          return Index is
      
   begin
      return Index'Val(Index'Pos(DA.First) + DA.Length - 1);
   end Last;
   
   
   function Get
     (DA                : in out Dynamic_Array;
      I                 : in     Index)
                          return Component is
      
   begin
      return DA.Data(I);
   end Get;

   
   procedure Set
     (DA                : in out Dynamic_Array;
      I                 : in	Index;
      C                 : in	Component) is
      
   begin
      DA.Data(I) := C;
   end Set;
   
   
   procedure Enlarge
     (DA                : in out Dynamic_Array) is
      
      Old_Size          : Natural := DA.Data'Length;
      New_Size          : Natural := 2*Old_Size;
      New_Max_Index     : Index := Index'Val(Index'Pos(DA.First) + New_Size - 1);
      New_Data          : Fixed_Array_Access;
      
   begin
      New_Data := new Fixed_Array(DA.First .. New_Max_Index);
      New_Data(DA.First .. DA.Last) := DA.Data(DA.First .. DA.Last);
      Free(DA.Data);
      DA.Data := New_Data;
   end Enlarge;


   function No_Space_At_The_End
     (DA                : in     Dynamic_Array)
                          return Boolean is
                          
   begin
      return Index'Pos(DA.First) + DA.Length > Index'Pos(DA.Data'Last);
   end No_Space_At_The_End;

   
   procedure Add
     (DA                : in out Dynamic_Array;
      C                 : in     Component) is
      
   begin
      if No_Space_At_The_End(DA) then
         Enlarge(DA);
      end if;
      DA.Length := DA.Length + 1;
      DA.Data(DA.Last) := C;
   end Add;
      
   
end Utility.Dynamic_Arrays;
