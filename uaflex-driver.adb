with Ada.Command_Line;            use Ada.Command_Line;

procedure UAFlex.Driver is
begin
   if Argument_Count /= 3 then
      Error ("Usage: uaflex input_file package_name output_dir");
      return;
   end if;

   UAFlex.Run
     (Input_File => Argument (1),
      Pkg_Name   => Argument (2),
      Output_Dir => Argument (3));

end UAFlex.Driver;
