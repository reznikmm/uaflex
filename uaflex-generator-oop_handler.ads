with League.Strings;
with League.String_Vectors;

package UAFLEX.Generator.OOP_Handler is

   procedure Go
     (Actions : League.String_Vectors.Universal_String_Vector;
      File    : String;
      Types   : League.Strings.Universal_String;
      Unit    : League.Strings.Universal_String;
      Scanner : League.Strings.Universal_String;
      Tokens  : League.Strings.Universal_String);

   procedure On_Accept
     (Actions : League.String_Vectors.Universal_String_Vector;
      File    : String;
      Types   : League.Strings.Universal_String;
      Handler : League.Strings.Universal_String;
      Scanner : League.Strings.Universal_String;
      Tokens  : League.Strings.Universal_String);

end UAFLEX.Generator.OOP_Handler;
