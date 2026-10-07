--  SPDX-FileCopyrightText: 2008-2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
---------------------------------------------------------------------


with Abstract_Sources;
with Ada.Strings.Wide_Wide_Unbounded;

package String_Sources is

   type String_Source is new Abstract_Sources.Abstract_Source with private;

   overriding function Get_Next
     (Self : not null access String_Source)
     return Abstract_Sources.Code_Unit_32;

   procedure Create
     (Self : out String_Source;
      Text : Wide_Wide_String);

private

   type String_Source is new Abstract_Sources.Abstract_Source with record
      Text  : Ada.Strings.Wide_Wide_Unbounded.Unbounded_Wide_Wide_String;
      Index : Positive := 1;
      --  Position of the next character to return
   end record;

end String_Sources;
