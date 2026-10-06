--  SPDX-FileCopyrightText: 2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

package body UAFLEX.Character_Sets is

   use type VSS.Unicode.Code_Point;

   function Scalar_Values return Character_Set;
   --  All code points except surrogates, the universe for "not"

   procedure Append_Merged
     (Result : in out Range_Vectors.Vector; Item : Code_Point_Range);
   --  Append Item, which must not start before the last range of Result,
   --  merging it with the last range when they overlap or are adjacent.

   -------------------
   -- Append_Merged --
   -------------------

   procedure Append_Merged
     (Result : in out Range_Vectors.Vector; Item : Code_Point_Range) is
   begin
      if Result.Is_Empty or else Item.Low > Result.Last_Element.High + 1 then
         Result.Append (Item);
      elsif Item.High > Result.Last_Element.High then
         Result (Result.Last_Index).High := Item.High;
      end if;
   end Append_Merged;

   ---------
   -- "-" --
   ---------

   function "-" (Left, Right : Character_Set) return Character_Set
   is (Left and not Right);

   -----------
   -- "and" --
   -----------

   function "and" (Left, Right : Character_Set) return Character_Set is
      Result : Character_Set;
      L      : Positive := 1;
      R      : Positive := 1;
   begin
      while L <= Left.Ranges.Last_Index and R <= Right.Ranges.Last_Index loop
         declare
            Left_Range  : constant Code_Point_Range := Left.Ranges (L);
            Right_Range : constant Code_Point_Range := Right.Ranges (R);
            Low         : constant VSS.Unicode.Code_Point :=
              VSS.Unicode.Code_Point'Max (Left_Range.Low, Right_Range.Low);
            High        : constant VSS.Unicode.Code_Point :=
              VSS.Unicode.Code_Point'Min (Left_Range.High, Right_Range.High);
         begin
            if Low <= High then
               Result.Ranges.Append (Code_Point_Range'(Low, High));
            end if;

            if Left_Range.High < Right_Range.High then
               L := L + 1;
            else
               R := R + 1;
            end if;
         end;
      end loop;

      return Result;
   end "and";

   -----------
   -- "not" --
   -----------

   function "not" (Value : Character_Set) return Character_Set is
      Result : Character_Set;
      Next   : VSS.Unicode.Code_Point := VSS.Unicode.Code_Point'First;
      --  First code point not yet classified
      Done   : Boolean := False;
      --  Set when Next would pass Code_Point'Last
   begin
      for Item of Value.Ranges loop
         if Item.Low > Next then
            Result.Ranges.Append (Code_Point_Range'(Next, Item.Low - 1));
         end if;

         if Item.High = VSS.Unicode.Code_Point'Last then
            Done := True;
         else
            Next := Item.High + 1;
         end if;
      end loop;

      if not Done then
         Result.Ranges.Append
           (Code_Point_Range'(Next, VSS.Unicode.Code_Point'Last));
      end if;

      return Result and Scalar_Values;
   end "not";

   ----------
   -- "or" --
   ----------

   function "or" (Left, Right : Character_Set) return Character_Set is
      Result : Character_Set;
      L      : Positive := 1;
      R      : Positive := 1;
   begin
      while L <= Left.Ranges.Last_Index or R <= Right.Ranges.Last_Index loop
         if R > Right.Ranges.Last_Index
           or else (L <= Left.Ranges.Last_Index
                    and then Left.Ranges (L).Low <= Right.Ranges (R).Low)
         then
            Append_Merged (Result.Ranges, Left.Ranges (L));
            L := L + 1;
         else
            Append_Merged (Result.Ranges, Right.Ranges (R));
            R := R + 1;
         end if;
      end loop;

      return Result;
   end "or";

   ---------
   -- "=" --
   ---------

   function "=" (Left, Right : Character_Set) return Boolean
   is (Range_Vectors."=" (Left.Ranges, Right.Ranges));

   ---------
   -- Has --
   ---------

   function Has
     (Self : Character_Set; Value : VSS.Unicode.Code_Point) return Boolean
   is
      Low  : Natural := 1;
      High : Natural := Self.Ranges.Last_Index;
   begin
      while Low <= High loop
         declare
            Middle : constant Positive := (Low + High) / 2;
            Item   : constant Code_Point_Range := Self.Ranges (Middle);
         begin
            if Value < Item.Low then
               High := Middle - 1;
            elsif Value > Item.High then
               Low := Middle + 1;
            else
               return True;
            end if;
         end;
      end loop;

      return False;
   end Has;

   --------------
   -- Is_Empty --
   --------------

   function Is_Empty (Self : Character_Set) return Boolean
   is (Self.Ranges.Is_Empty);

   ---------------
   -- Is_Subset --
   ---------------

   function Is_Subset (Self, Other : Character_Set) return Boolean
   is (Is_Empty (Self - Other));

   -------------------
   -- Scalar_Values --
   -------------------

   function Scalar_Values return Character_Set is
   begin
      return Result : Character_Set do
         Result.Ranges.Append (Code_Point_Range'(0, 16#D7FF#));
         Result.Ranges.Append
           (Code_Point_Range'(16#E000#, VSS.Unicode.Code_Point'Last));
      end return;
   end Scalar_Values;

   ------------
   -- To_Set --
   ------------

   function To_Set (Low, High : VSS.Unicode.Code_Point) return Character_Set is
   begin
      return Result : Character_Set do
         if Low <= High then
            Result.Ranges.Append (Code_Point_Range'(Low, High));
         end if;
      end return;
   end To_Set;

   ------------
   -- To_Set --
   ------------

   function To_Set
     (Value : VSS.Characters.Virtual_Character) return Character_Set
   is (To_Set (Value, Value));

   ------------
   -- To_Set --
   ------------

   function To_Set
     (Low, High : VSS.Characters.Virtual_Character) return Character_Set
   is (To_Set
         (VSS.Characters.Virtual_Character'Pos (Low),
          VSS.Characters.Virtual_Character'Pos (High)));

end UAFLEX.Character_Sets;
