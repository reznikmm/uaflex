package UAFLEX.Lexer_Types is
   pragma Preelaborate;

   type State is mod +85;
   subtype Valid_State is State range 0 .. State'Last - 1;

   DEF : constant State := 0;
   INITIAL : constant State := 4;
   INRULE : constant State := 19;
   NAMELIST : constant State := 25;
   SECT2 : constant State := 29;

   type Character_Class is mod +20;

   type Rule_Index is range 0 .. 19;

end UAFLEX.Lexer_Types;
