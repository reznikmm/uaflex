--  SPDX-FileCopyrightText: 2008-2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
---------------------------------------------------------------------

with VSS.Characters;
with VSS.Regular_Expressions.ECMA_Parser;
with VSS.Regular_Expressions.Name_Sets;
with VSS.Strings.Character_Iterators;
with VSS.Unicode;

with UAFLEX.Character_Sets;

package body VSS.Regular_Expressions.ECMA_Parser_Wrap is

   use UAFLEX.Character_Sets;
   use UAFLEX.Regexps;
   use type VSS.Characters.General_Category;
   use type VSS.Unicode.Code_Point;

   type Node_Kind is (Set, Tree);

   type Node (Kind : Node_Kind := Set) is record
      case Kind is
         when Set =>
            Value : Character_Set;

         when Tree =>
            Items : Program;
      end case;
   end record;
   --  Character classes are folded into a set, anything else is a program.

   Assertion_Error : exception;

   function To_Program (Self : Node) return Program;

   function Create_Character
     (Value : VSS.Characters.Virtual_Character) return Node;

   function Create_Any_Character return Node;

   function Create_Character_Range
     (From, To : VSS.Characters.Virtual_Character) return Node;

   function Create_General_Category_Set
     (Value : Name_Sets.General_Category_Set) return Node;

   function Create_Simple_Assertion (Kind : Simple_Assertion_Kind) return Node;

   function Create_Sequence (Left, Right : Node) return Node;
   function Create_Alternative (Left, Right : Node) return Node;
   function Create_Star (Left : Node) return Node;
   function Create_Plus (Left : Node) return Node;
   function Create_Negated_Class (Left : Node) return Node;

   function Create_Group
     (Left : Node; From : Positive; To : Natural) return Node;

   function Create_Empty return Node;

   package Parser is new VSS.Regular_Expressions.ECMA_Parser (Node);

   type Category_Set_Array is
     array (VSS.Characters.General_Category) of Character_Set;

   function Category_Sets return Category_Set_Array;
   --  Split the whole code space by general category

   Cached_Sets : Category_Set_Array;
   Cached      : Boolean := False;

   ------------------------
   -- Create_Alternative --
   ------------------------

   function Create_Alternative (Left, Right : Node) return Node is
   begin
      if Left.Kind = Set and then Right.Kind = Set then
         return (Set, Left.Value or Right.Value);
      else
         return Result : Node := (Tree, To_Program (Left)) do
            Result.Items.Append_Vector (To_Program (Right));
            Result.Items.Append (Token'(Kind => Alternative));
         end return;
      end if;
   end Create_Alternative;

   --------------------------
   -- Create_Any_Character --
   --------------------------

   function Create_Any_Character return Node is
   begin
      return (Set, not Empty_Set);
   end Create_Any_Character;

   ----------------------
   -- Create_Character --
   ----------------------

   function Create_Character
     (Value : VSS.Characters.Virtual_Character) return Node is
   begin
      return (Set, To_Set (Value));
   end Create_Character;

   ----------------------------
   -- Create_Character_Range --
   ----------------------------

   function Create_Character_Range
     (From, To : VSS.Characters.Virtual_Character) return Node is
   begin
      return (Set, To_Set (From, To));
   end Create_Character_Range;

   ------------------
   -- Create_Empty --
   ------------------

   function Create_Empty return Node is
   begin
      return Result : Node := (Kind => Tree, Items => <>) do
         Result.Items.Append (Token'(Kind => Empty));
      end return;
   end Create_Empty;

   ---------------------------------
   -- Create_General_Category_Set --
   ---------------------------------

   function Create_General_Category_Set
     (Value : Name_Sets.General_Category_Set) return Node
   is
      Sets   : Category_Set_Array renames Cached_Sets;
      Result : Character_Set;
   begin
      if not Cached then
         Cached_Sets := Category_Sets;
         Cached := True;
      end if;

      for Category in Sets'Range loop
         if Name_Sets.Contains (Value, Category) then
            Result := Result or Sets (Category);
         end if;
      end loop;

      return (Set, Result);
   end Create_General_Category_Set;

   ------------------
   -- Create_Group --
   ------------------

   function Create_Group
     (Left : Node; From : Positive; To : Natural) return Node
   is
      pragma Unreferenced (From, To);
   begin
      return Left;
   end Create_Group;

   --------------------------
   -- Create_Negated_Class --
   --------------------------

   function Create_Negated_Class (Left : Node) return Node is
   begin
      return (Set, not Left.Value);
   end Create_Negated_Class;

   -----------------
   -- Create_Plus --
   -----------------

   function Create_Plus (Left : Node) return Node is
   begin
      return Result : Node := (Tree, To_Program (Left)) do
         Result.Items.Append (Token'(Kind => Plus));
      end return;
   end Create_Plus;

   ---------------------
   -- Create_Sequence --
   ---------------------

   function Create_Sequence (Left, Right : Node) return Node is
   begin
      return Result : Node := (Tree, To_Program (Left)) do
         Result.Items.Append_Vector (To_Program (Right));
         Result.Items.Append (Token'(Kind => Sequence));
      end return;
   end Create_Sequence;

   -----------------------------
   -- Create_Simple_Assertion --
   -----------------------------

   function Create_Simple_Assertion (Kind : Simple_Assertion_Kind) return Node
   is
   begin
      raise Assertion_Error with Kind'Image;
      return Create_Empty;
   end Create_Simple_Assertion;

   -----------------
   -- Create_Star --
   -----------------

   function Create_Star (Left : Node) return Node is
   begin
      return Result : Node := (Tree, To_Program (Left)) do
         Result.Items.Append (Token'(Kind => Star));
      end return;
   end Create_Star;

   -------------------
   -- Category_Sets --
   -------------------

   function Category_Sets return Category_Set_Array is
      Result : Category_Set_Array;
      Start  : VSS.Unicode.Code_Point := VSS.Unicode.Code_Point'First;
      --  First code point of the current run of the same category
      Last   : VSS.Characters.General_Category :=
        VSS.Characters.Get_General_Category
          (VSS.Characters.Virtual_Character'Base'Val (Start));
   begin
      for Code in
        VSS.Unicode.Code_Point'First + 1 .. VSS.Unicode.Code_Point'Last
      loop
         declare
            Category : constant VSS.Characters.General_Category :=
              VSS.Characters.Get_General_Category
                (VSS.Characters.Virtual_Character'Base'Val (Code));
         begin
            if Category /= Last then
               Result (Last) := Result (Last) or To_Set (Start, Code - 1);
               Start := Code;
               Last := Category;
            end if;
         end;
      end loop;

      Result (Last) :=
        Result (Last) or To_Set (Start, VSS.Unicode.Code_Point'Last);

      return Result;
   end Category_Sets;

   -----------
   -- Parse --
   -----------

   procedure Parse
     (Pattern : VSS.Strings.Virtual_String;
      Program : out UAFLEX.Regexps.Program;
      Error   : out VSS.Strings.Virtual_String)
   is
      Cursor : VSS.Strings.Character_Iterators.Character_Iterator :=
        Pattern.At_First_Character;
      Root   : Node;
   begin
      Program.Clear;
      Parser.Parse_Pattern (Cursor, Error, Root);

      if Error.Is_Empty then
         Program := To_Program (Root);
      end if;
   exception
      when Assertion_Error =>
         Error := "Assertions are not supported.";
   end Parse;

   ----------------
   -- To_Program --
   ----------------

   function To_Program (Self : Node) return Program is
   begin
      case Self.Kind is
         when Set  =>
            return Result : Program do
               Result.Append (Token'(Leaf, Self.Value));
            end return;

         when Tree =>
            return Self.Items;
      end case;
   end To_Program;

end VSS.Regular_Expressions.ECMA_Parser_Wrap;
