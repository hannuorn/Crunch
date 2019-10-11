with Utility.Test; use Utility.Test;
with Test_Utility.Test_Dynamic_Arrays;
with Test_Utility.Test_Binary_Search_Trees;


package body Test_Utility is

   procedure Test is

   begin
      Begin_Test("Utility");
      Test_Utility.Test_Dynamic_Arrays.Test;
      --Test_Utility.Test_Binary_Search_Trees.Test;
      End_Test;
   end Test;

end Test_Utility;
