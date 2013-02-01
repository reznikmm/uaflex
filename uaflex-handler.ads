with UAFLEX.Handlers;
with UAFLEX.Lexer_Types;
with Parser_Tokens;
limited with UAFLEX.Scanners;

package UAFLEX.Handler is
   type Handler is new UAFLEX.Handlers.Handler with private;

   procedure Skip
     (Self    : not null access Handler;
      Scanner : not null access UAFLEX.Scanners.Scanner'Class;
      Rule    : Lexer_Types.Rule_Index;
      Token   : out Parser_Tokens.Token;
      Skip    : in out Boolean) is null;

   procedure Skip_Line
     (Self    : not null access Handler;
      Scanner : not null access UAFLEX.Scanners.Scanner'Class;
      Rule    : Lexer_Types.Rule_Index;
      Token   : out Parser_Tokens.Token;
      Skip    : in out Boolean);

   procedure On_Start
     (Self    : not null access Handler;
      Scanner : not null access UAFLEX.Scanners.Scanner'Class;
      Rule    : Lexer_Types.Rule_Index;
      Token   : out Parser_Tokens.Token;
      Skip    : in out Boolean);

   procedure On_Exclusive
     (Self    : not null access Handler;
      Scanner : not null access UAFLEX.Scanners.Scanner'Class;
      Rule    : Lexer_Types.Rule_Index;
      Token   : out Parser_Tokens.Token;
      Skip    : in out Boolean);

   procedure On_Name
     (Self    : not null access Handler;
      Scanner : not null access UAFLEX.Scanners.Scanner'Class;
      Rule    : Lexer_Types.Rule_Index;
      Token   : out Parser_Tokens.Token;
      Skip    : in out Boolean);

   procedure On_Section_End
     (Self    : not null access Handler;
      Scanner : not null access UAFLEX.Scanners.Scanner'Class;
      Rule    : Lexer_Types.Rule_Index;
      Token   : out Parser_Tokens.Token;
      Skip    : in out Boolean);

   procedure On_Regexp
     (Self    : not null access Handler;
      Scanner : not null access UAFLEX.Scanners.Scanner'Class;
      Rule    : Lexer_Types.Rule_Index;
      Token   : out Parser_Tokens.Token;
      Skip    : in out Boolean);

   procedure End_Of_Macro
     (Self    : not null access Handler;
      Scanner : not null access UAFLEX.Scanners.Scanner'Class;
      Rule    : Lexer_Types.Rule_Index;
      Token   : out Parser_Tokens.Token;
      Skip    : in out Boolean);

   procedure End_Of_Name_List
     (Self    : not null access Handler;
      Scanner : not null access UAFLEX.Scanners.Scanner'Class;
      Rule    : Lexer_Types.Rule_Index;
      Token   : out Parser_Tokens.Token;
      Skip    : in out Boolean);

   procedure On_Name_2
     (Self    : not null access Handler;
      Scanner : not null access UAFLEX.Scanners.Scanner'Class;
      Rule    : Lexer_Types.Rule_Index;
      Token   : out Parser_Tokens.Token;
      Skip    : in out Boolean);

   procedure On_Regexp_2
     (Self    : not null access Handler;
      Scanner : not null access UAFLEX.Scanners.Scanner'Class;
      Rule    : Lexer_Types.Rule_Index;
      Token   : out Parser_Tokens.Token;
      Skip    : in out Boolean);

   procedure On_Section_End_2
     (Self    : not null access Handler;
      Scanner : not null access UAFLEX.Scanners.Scanner'Class;
      Rule    : Lexer_Types.Rule_Index;
      Token   : out Parser_Tokens.Token;
      Skip    : in out Boolean);

   procedure On_Action
     (Self    : not null access Handler;
      Scanner : not null access UAFLEX.Scanners.Scanner'Class;
      Rule    : Lexer_Types.Rule_Index;
      Token   : out Parser_Tokens.Token;
      Skip    : in out Boolean);

   procedure On_End_Of_Rule
     (Self    : not null access Handler;
      Scanner : not null access UAFLEX.Scanners.Scanner'Class;
      Rule    : Lexer_Types.Rule_Index;
      Token   : out Parser_Tokens.Token;
      Skip    : in out Boolean);

   function Get_Line (Self : Handler) return Positive;

private

   procedure New_Line
     (Self    : not null access Handler'Class;
      Scanner : not null access UAFLEX.Scanners.Scanner'Class);

   procedure Check_New_Line (Self : not null access Handler'Class);

   type Handler is new UAFLEX.Handlers.Handler with record
      Line      : Positive := 1;
      Line_Feed : Boolean := False;  --  The token is last in line
   end record;

end UAFLEX.Handler;
