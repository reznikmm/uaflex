--  SPDX-FileCopyrightText: 2008-2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
---------------------------------------------------------------------

package UAFLEX.Lexer_Types is
   pragma Preelaborate;

   type State is mod +86;
   subtype Looping_State is State range 0 .. 72;
   subtype Final_State is State range 28 .. State'Last - 1;

   Error_State : constant State := State'Last;

   DEF : constant State := 0;
   INITIAL : constant State := 1;
   INRULE : constant State := 10;
   NAMELIST : constant State := 13;
   SECT2 : constant State := 14;

   type Character_Class is mod +20;

   type Rule_Index is range 0 .. 19;

end UAFLEX.Lexer_Types;
