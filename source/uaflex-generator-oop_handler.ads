--  SPDX-FileCopyrightText: 2008-2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
---------------------------------------------------------------------


with VSS.Strings;
with VSS.String_Vectors;

package UAFLEX.Generator.OOP_Handler is

   procedure Go
     (Actions : VSS.String_Vectors.Virtual_String_Vector;
      File    : String;
      Types   : VSS.Strings.Virtual_String;
      Unit    : VSS.Strings.Virtual_String;
      Scanner : VSS.Strings.Virtual_String;
      Tokens  : VSS.Strings.Virtual_String);

   procedure On_Accept
     (Actions : VSS.String_Vectors.Virtual_String_Vector;
      File    : String;
      Types   : VSS.Strings.Virtual_String;
      Handler : VSS.Strings.Virtual_String;
      Scanner : VSS.Strings.Virtual_String;
      Tokens  : VSS.Strings.Virtual_String);

end UAFLEX.Generator.OOP_Handler;
