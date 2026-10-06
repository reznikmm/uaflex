------------------------------------------------------------------------------
--                                                                          --
--                            Matreshka Project                             --
--                                                                          --
--         Localization, Internationalization, Globalization for Ada        --
--                                                                          --
--                              Tools Component                             --
--                                                                          --
------------------------------------------------------------------------------
--                                                                          --
-- Copyright © 2011-2015, Vadim Godunko <vgodunko@gmail.com>                --
-- All rights reserved.                                                     --
--                                                                          --
-- Redistribution and use in source and binary forms, with or without       --
-- modification, are permitted provided that the following conditions       --
-- are met:                                                                 --
--                                                                          --
--  * Redistributions of source code must retain the above copyright        --
--    notice, this list of conditions and the following disclaimer.         --
--                                                                          --
--  * Redistributions in binary form must reproduce the above copyright     --
--    notice, this list of conditions and the following disclaimer in the   --
--    documentation and/or other materials provided with the distribution.  --
--                                                                          --
--  * Neither the name of the Vadim Godunko, IE nor the names of its        --
--    contributors may be used to endorse or promote products derived from  --
--    this software without specific prior written permission.              --
--                                                                          --
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS      --
-- "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT        --
-- LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR    --
-- A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT     --
-- HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,   --
-- SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED --
-- TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR   --
-- PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF   --
-- LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING     --
-- NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS       --
-- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.             --
--                                                                          --
------------------------------------------------------------------------------
--  $Revision$ $Date$
------------------------------------------------------------------------------

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
