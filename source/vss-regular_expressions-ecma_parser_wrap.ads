--  SPDX-FileCopyrightText: 2008-2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
---------------------------------------------------------------------

--  VSS.Regular_Expressions.ECMA_Parser is a private generic child, so it can
--  be named only inside the hierarchy of VSS.Regular_Expressions. This child
--  instantiates the parser to produce a UAFLEX.Regexps.Program.

with UAFLEX.Regexps;

package VSS.Regular_Expressions.ECMA_Parser_Wrap is

   procedure Parse
     (Pattern : VSS.Strings.Virtual_String;
      Program : out UAFLEX.Regexps.Program;
      Error   : out VSS.Strings.Virtual_String);
   --  Parse ECMAScript regular expression. Error is empty on success.
   --  Assertions (^, $, \b, \B) are reported as errors. The dot matches any
   --  character, including the line terminators.

end VSS.Regular_Expressions.ECMA_Parser_Wrap;
