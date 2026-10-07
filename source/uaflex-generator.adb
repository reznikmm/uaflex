--  SPDX-FileCopyrightText: 2008-2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
---------------------------------------------------------------------


package body UAFLEX.Generator is

   function Image (X : Natural) return Wide_Wide_String is
      Text : constant Wide_Wide_String := Natural'Wide_Wide_Image (X);
   begin
      return Text (2 .. Text'Last);
   end Image;

end UAFLEX.Generator;
