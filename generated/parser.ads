with UAFLEX.Scanners;
with UAFLEX.Handler;
package Parser is
   Scanner : aliased UAFLEX.Scanners.Scanner;
   Handler : aliased UAFLEX.Handler.Handler;
   procedure YYParse;
end Parser;
