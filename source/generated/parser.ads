--  SPDX-FileCopyrightText: 2008-2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
---------------------------------------------------------------------

with UAFLEX.Scanners;
with UAFLEX.Handler;
package Parser is
   Scanner : aliased UAFLEX.Scanners.Scanner;
   Handler : aliased UAFLEX.Handler.Handler;
   procedure YYParse;
end Parser;
