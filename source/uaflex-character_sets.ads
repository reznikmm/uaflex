--  SPDX-FileCopyrightText: 2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

with Ada.Containers.Vectors;

with VSS.Characters;
with VSS.Unicode;

package UAFLEX.Character_Sets is

   type Character_Set is tagged private;
   --  Set of Unicode code points. Stored as sorted list of disjoint ranges.

   Empty_Set : constant Character_Set;

   function To_Set (Low, High : VSS.Unicode.Code_Point) return Character_Set;
   --  Set of all code points from Low to High. Empty if Low > High.

   function To_Set
     (Value : VSS.Characters.Virtual_Character) return Character_Set;

   function To_Set
     (Low, High : VSS.Characters.Virtual_Character) return Character_Set;

   function "or" (Left, Right : Character_Set) return Character_Set;

   function "and" (Left, Right : Character_Set) return Character_Set;

   function "-" (Left, Right : Character_Set) return Character_Set;

   function "not" (Value : Character_Set) return Character_Set;

   function "=" (Left, Right : Character_Set) return Boolean;

   function Is_Empty (Self : Character_Set) return Boolean;

   function Is_Subset (Self, Other : Character_Set) return Boolean;
   --  Check if every code point of Self belongs to Other.

   function Has
     (Self : Character_Set; Value : VSS.Unicode.Code_Point) return Boolean;

private

   type Code_Point_Range is record
      Low  : VSS.Unicode.Code_Point;
      High : VSS.Unicode.Code_Point;
   end record;

   package Range_Vectors is new
     Ada.Containers.Vectors
       (Index_Type   => Positive,
        Element_Type => Code_Point_Range);

   type Character_Set is tagged record
      Ranges : Range_Vectors.Vector;
      --  Sorted, disjoint and not adjacent ranges
   end record;

   Empty_Set : constant Character_Set :=
     (Ranges => Range_Vectors.Empty_Vector);

end UAFLEX.Character_Sets;
