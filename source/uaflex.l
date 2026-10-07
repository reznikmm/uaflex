--  SPDX-FileCopyrightText: 2008-2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
---------------------------------------------------------------------


%x INRULE SECT2 DEF NAMELIST

NAME           [a-zA-Z][a-zA-Z0-9_]*
SPACE          [\t ]+
OPTSPACE       [\t ]*
NO_SPACE       [^\n\t ]+
CLASS          "["[^\n\]]+"]"
STRING         \"[^"\n]*\"
MASKED_SPACE   "\\ "
ADA_STRING     \"([^"]+|\"\")*\"

%%

{OPTSPACE}"--"[^\n]*\n					{Skip_Line}
"%"[Ss](tart)?						{On_Start}
"%"[Xx]							{On_Exclusive}
{NAME}							{On_Name}
"%%"[^\n]*\n						{On_Section_End}
{OPTSPACE}\n						{Skip_Line}

<DEF>{SPACE}						{Skip}
<DEF>[^ \t\n][^\n]*					{On_Regexp}
<DEF>\n							{End_Of_Macro}

<NAMELIST>\n						{End_Of_Name_List}
<NAMELIST>{NAME}					{On_Name_2}
<NAMELIST>{SPACE}					{Skip}

<SECT2>{OPTSPACE}"--"[^\n]*\n				{Skip_Line}
<SECT2>({NO_SPACE}|{CLASS}|{STRING}|{MASKED_SPACE})+	{On_Regexp_2}
<SECT2>{OPTSPACE}\n					{Skip_Line}
<SECT2>"%%"[^\n]*\n					{On_Section_End_2}

<INRULE>\{([^}"]+|{ADA_STRING})*\}			{On_Action}
<INRULE>{SPACE}						{Skip}
<INRULE>{OPTSPACE}\n					{On_End_Of_Rule}

%%
