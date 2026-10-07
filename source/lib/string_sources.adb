--  SPDX-FileCopyrightText: 2008-2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
---------------------------------------------------------------------


package body String_Sources is

   --------------
   -- Get_Next --
   --------------

   overriding function Get_Next
     (Self : not null access String_Source)
      return Abstract_Sources.Code_Unit_32
   is
   begin
      if Self.Index <= Ada.Strings.Wide_Wide_Unbounded.Length (Self.Text) then
         return Result : Abstract_Sources.Code_Unit_32 do
            Result :=
              Wide_Wide_Character'Pos
                (Ada.Strings.Wide_Wide_Unbounded.Element
                   (Self.Text, Self.Index));
            Self.Index := Self.Index + 1;
         end return;
      else
         return Abstract_Sources.End_Of_Input;
      end if;
   end Get_Next;

   ------------
   -- Create --
   ------------

   procedure Create
     (Self : out String_Source;
      Text : Wide_Wide_String) is
   begin
      Self.Text := Ada.Strings.Wide_Wide_Unbounded.To_Unbounded_Wide_Wide_String (Text);
      Self.Index := 1;
   end Create;

end String_Sources;
