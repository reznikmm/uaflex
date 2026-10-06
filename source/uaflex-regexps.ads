--  SPDX-FileCopyrightText: 2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

with Ada.Containers.Vectors;

with UAFLEX.Character_Sets;

package UAFLEX.Regexps is

   type Token_Kind is (Leaf, Sequence, Alternative, Star, Plus, Empty);

   type Token (Kind : Token_Kind := Empty) is record
      case Kind is
         when Leaf =>
            Set : UAFLEX.Character_Sets.Character_Set;

         when others =>
            null;
      end case;
   end record;
   --  Leaf matches one character from the set, Empty matches empty string.
   --  Sequence and Alternative combine two operands, Star and Plus take one.

   package Token_Vectors is new
     Ada.Containers.Vectors (Index_Type => Positive, Element_Type => Token);

   subtype Program is Token_Vectors.Vector;
   --  Regular expression in postfix form, operands precede the operator.
   --  For example, "a(b|c)*" is: a b c Alternative Star Sequence.

   type Program_Array is array (Positive range <>) of Program;

end UAFLEX.Regexps;
