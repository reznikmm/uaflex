limited with UAFLEX.Scanners;
with Parser_Tokens;
with UAFLEX.Lexer_Types;

package UAFLEX.Handlers is

   type Handler is abstract tagged limited null record;

   procedure Skip_Line
     (Self    : not null access Handler;
      Scanner : not null access UAFLEX.Scanners.Scanner'Class;
      Rule    : UAFLEX.Lexer_Types.Rule_Index;
      Token   : out Parser_Tokens.Token;
      Skip    : in out Boolean) is abstract;

   procedure On_Start
     (Self    : not null access Handler;
      Scanner : not null access UAFLEX.Scanners.Scanner'Class;
      Rule    : UAFLEX.Lexer_Types.Rule_Index;
      Token   : out Parser_Tokens.Token;
      Skip    : in out Boolean) is abstract;

   procedure On_Exclusive
     (Self    : not null access Handler;
      Scanner : not null access UAFLEX.Scanners.Scanner'Class;
      Rule    : UAFLEX.Lexer_Types.Rule_Index;
      Token   : out Parser_Tokens.Token;
      Skip    : in out Boolean) is abstract;

   procedure On_Name
     (Self    : not null access Handler;
      Scanner : not null access UAFLEX.Scanners.Scanner'Class;
      Rule    : UAFLEX.Lexer_Types.Rule_Index;
      Token   : out Parser_Tokens.Token;
      Skip    : in out Boolean) is abstract;

   procedure On_Section_End
     (Self    : not null access Handler;
      Scanner : not null access UAFLEX.Scanners.Scanner'Class;
      Rule    : UAFLEX.Lexer_Types.Rule_Index;
      Token   : out Parser_Tokens.Token;
      Skip    : in out Boolean) is abstract;

   procedure Skip
     (Self    : not null access Handler;
      Scanner : not null access UAFLEX.Scanners.Scanner'Class;
      Rule    : UAFLEX.Lexer_Types.Rule_Index;
      Token   : out Parser_Tokens.Token;
      Skip    : in out Boolean) is abstract;

   procedure On_Regexp
     (Self    : not null access Handler;
      Scanner : not null access UAFLEX.Scanners.Scanner'Class;
      Rule    : UAFLEX.Lexer_Types.Rule_Index;
      Token   : out Parser_Tokens.Token;
      Skip    : in out Boolean) is abstract;

   procedure End_Of_Macro
     (Self    : not null access Handler;
      Scanner : not null access UAFLEX.Scanners.Scanner'Class;
      Rule    : UAFLEX.Lexer_Types.Rule_Index;
      Token   : out Parser_Tokens.Token;
      Skip    : in out Boolean) is abstract;

   procedure End_Of_Name_List
     (Self    : not null access Handler;
      Scanner : not null access UAFLEX.Scanners.Scanner'Class;
      Rule    : UAFLEX.Lexer_Types.Rule_Index;
      Token   : out Parser_Tokens.Token;
      Skip    : in out Boolean) is abstract;

   procedure On_Name_2
     (Self    : not null access Handler;
      Scanner : not null access UAFLEX.Scanners.Scanner'Class;
      Rule    : UAFLEX.Lexer_Types.Rule_Index;
      Token   : out Parser_Tokens.Token;
      Skip    : in out Boolean) is abstract;

   procedure On_Regexp_2
     (Self    : not null access Handler;
      Scanner : not null access UAFLEX.Scanners.Scanner'Class;
      Rule    : UAFLEX.Lexer_Types.Rule_Index;
      Token   : out Parser_Tokens.Token;
      Skip    : in out Boolean) is abstract;

   procedure On_Section_End_2
     (Self    : not null access Handler;
      Scanner : not null access UAFLEX.Scanners.Scanner'Class;
      Rule    : UAFLEX.Lexer_Types.Rule_Index;
      Token   : out Parser_Tokens.Token;
      Skip    : in out Boolean) is abstract;

   procedure On_Action
     (Self    : not null access Handler;
      Scanner : not null access UAFLEX.Scanners.Scanner'Class;
      Rule    : UAFLEX.Lexer_Types.Rule_Index;
      Token   : out Parser_Tokens.Token;
      Skip    : in out Boolean) is abstract;

   procedure On_End_Of_Rule
     (Self    : not null access Handler;
      Scanner : not null access UAFLEX.Scanners.Scanner'Class;
      Rule    : UAFLEX.Lexer_Types.Rule_Index;
      Token   : out Parser_Tokens.Token;
      Skip    : in out Boolean) is abstract;

   type Handler_Access is access all Handler'Class;

end UAFLEX.Handlers;
