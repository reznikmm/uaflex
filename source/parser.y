--  SPDX-FileCopyrightText: 2008-2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
---------------------------------------------------------------------


%token Name Name_List_End Start Excl_Start Section_End Regexp Action
%with UAFLEX.Nodes;
{
   subtype YYSType is UAFLEX.Nodes.Node;
}

%%

file: definitions_section rule_section
;

definitions_section: macro_list Section_End;

macro_list:
  |
  macro_list macro
;

macro: Name_Token Regexp_Token
{
  UAFLEX.Nodes.Macros.Insert ($1.Value, $2.Value);
}
  | Start name_list Name_List_End
{
  UAFLEX.Nodes.Add_Start_Conditions ($2.List, False);
}
  | Excl_Start name_list Name_List_End
{
  UAFLEX.Nodes.Add_Start_Conditions ($2.List, True);
}
;

name_list: Name_Token
{
  $$ := UAFLEX.Nodes.Empty_Name_List;
  $$.List.Append ($1.Value);
}

  |  name_list Name_Token
{
  $1.List.Append ($2.Value);
  $$ := $1;
}
;

rule_section: rule_list Section_End
;

rule_list:
  |
  rule_list rule
{
  UAFLEX.Nodes.Add_Rule ($2.Regexp, $2.Action, Line);
}

;

rule: Regexp_Token Action_Token
  { $$ := (UAFLEX.Nodes.Rule, $1.Value, $2.Value); }
;

Name_Token: Name
  { $$ := UAFLEX.Nodes.To_Node (Get_Text); }
;

Regexp_Token: Regexp
  { $$ := UAFLEX.Nodes.To_Node (Get_Text); Line := Handler.Get_Line; }
;

Action_Token: Action
  { $$ := UAFLEX.Nodes.To_Action (Get_Text); }
;

%%
with UAFLEX.Scanners;
with UAFLEX.Handler;
##
   Scanner : aliased UAFLEX.Scanners.Scanner;
   Handler : aliased UAFLEX.Handler.Handler;
   procedure YYParse;
##
with Ada.Wide_Wide_Text_IO;
with UAFLEX.Nodes;
with VSS.Strings;
##
procedure yyerror (X : Wide_Wide_String) is
begin
  Ada.Wide_Wide_Text_IO.Put_Line
   (X & " on line" & Positive'Wide_Wide_Image (Handler.Get_Line));
end;

function YYLex return Token is
   Result : Token;
begin
   Scanner.Get_Token (Result);
   return Result;
end YYLex;

Line : Positive;

function Get_Text return VSS.Strings.Virtual_String is
  (VSS.Strings.To_Virtual_String (Scanner.Get_Text));
