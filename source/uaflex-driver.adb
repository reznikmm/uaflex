--  SPDX-FileCopyrightText: 2008-2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
---------------------------------------------------------------------


with Ada.Command_Line;
with Ada.Wide_Wide_Text_IO;
with VSS.Application;
with VSS.String_Vectors;
with VSS.Strings;

with UAFLEX.Run;

procedure UAFLEX.Driver is

   procedure Read_Arguments;

   procedure Print_Usage;

   function "+" (Item : Wide_Wide_String) return VSS.Strings.Virtual_String
   renames VSS.Strings.To_Virtual_String;

   Handler : VSS.Strings.Virtual_String;
   Input   : VSS.Strings.Virtual_String;
   Tokens  : VSS.Strings.Virtual_String;
   Types   : VSS.Strings.Virtual_String;
   Scanner : VSS.Strings.Virtual_String;

   -----------------
   -- Print_Usage --
   -----------------

   procedure Print_Usage is
      use Ada.Wide_Wide_Text_IO;
   begin
      Put_Line (Standard_Error, "Usage: uaflex <unit-options> input_file");
      Put_Line (Standard_Error, "  where <unit-options> contains:");
      Put_Line
        (Standard_Error,
         "    --types Types_Unit - unit for type and condition declarations");
      Put_Line
        (Standard_Error,
         "    --handler Handler_Unit - unit for abstract handler declaration");
      Put_Line
        (Standard_Error,
         "    --scanner Scanner_Unit - unit where scanner is located");
      Put_Line
        (Standard_Error,
         "    --tokens Tokens_Unit - unit where Token type is declared");
   end Print_Usage;

   --------------------
   -- Read_Arguments --
   --------------------

   procedure Read_Arguments is
      use type VSS.Strings.Virtual_String;

      Arguments  : constant VSS.String_Vectors.Virtual_String_Vector :=
        VSS.Application.Arguments;
      Is_Types   : constant VSS.Strings.Virtual_String := +"--types";
      Is_Scanner : constant VSS.Strings.Virtual_String := +"--scanner";
      Is_Tokens  : constant VSS.Strings.Virtual_String := +"--tokens";
      Is_Handler : constant VSS.Strings.Virtual_String := +"--handler";

      Last  : constant Natural := Arguments.Length;
      Index : Positive := 1;
   begin
      while Index <= Last loop
         declare
            Next : constant VSS.Strings.Virtual_String :=
              Arguments.Element (Index);
         begin
            if Index = Last then
               Input := Next;
            elsif Next = Is_Types then
               Index := Index + 1;
               Types := Arguments.Element (Index);
            elsif Next = Is_Scanner then
               Index := Index + 1;
               Scanner := Arguments.Element (Index);
            elsif Next = Is_Tokens then
               Index := Index + 1;
               Tokens := Arguments.Element (Index);
            elsif Next = Is_Handler then
               Index := Index + 1;
               Handler := Arguments.Element (Index);
            end if;

            Index := Index + 1;
         end;
      end loop;
   end Read_Arguments;

   Success : Boolean;
begin
   Read_Arguments;

   if Handler.Is_Empty
     or Input.Is_Empty
     or Tokens.Is_Empty
     or Types.Is_Empty
     or Scanner.Is_Empty
   then
      Print_Usage;
      return;
   end if;

   UAFLEX.Run (Handler, Input, Tokens, Types, Scanner, Success);

   if not Success then
      Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure);
   end if;

end UAFLEX.Driver;
