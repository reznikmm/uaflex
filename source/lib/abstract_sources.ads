--  SPDX-FileCopyrightText: 2008-2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
---------------------------------------------------------------------


package Abstract_Sources is

   type Code_Unit_32 is mod 2**32;

   type Abstract_Source is limited interface;

   Error         : constant Code_Unit_32 := 16#7FFFFFFF#;
   End_Of_Input  : constant Code_Unit_32 := 16#7FFFFFFE#;
   End_Of_Data   : constant Code_Unit_32 := 16#7FFFFFFD#;
   End_Of_Buffer : constant Code_Unit_32 := 16#7FFFFFFC#;

   type Source_Access is access all Abstract_Source'Class;

   not overriding function Get_Next
    (Self : not null access Abstract_Source) return Code_Unit_32 is abstract;

end Abstract_Sources;
