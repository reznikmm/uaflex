package UAFlex is

   procedure Run
     (Input_File : String;
      Pkg_Name   : String;
      Output_Dir : String);

   procedure Error (Msg, Text : String := "");

end UAFlex;
