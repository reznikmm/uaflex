--  SPDX-FileCopyrightText: 2008-2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
---------------------------------------------------------------------


with Ada.Wide_Wide_Text_IO;
with VSS.Characters;
with VSS.Strings.Character_Iterators;
with VSS.Strings.Conversions;

package body UAFLEX.Nodes is

   use type VSS.Characters.Virtual_Character;
   use type VSS.Strings.Character_Count;

   --------------
   -- Add_Rule --
   --------------

   procedure Add_Rule
     (RegExp : VSS.Strings.Virtual_String;
      Action : VSS.Strings.Virtual_String;
      Line   : Positive)
   is
      procedure Add
        (Name      : VSS.Strings.Virtual_String;
         Condition : in out Start_Condition);

      procedure Add_Inclusive
        (Name      : VSS.Strings.Virtual_String;
         Condition : in out Start_Condition);

      procedure Each_Inclusive (Cursor : Start_Condition_Maps.Cursor);

      function Get_Action (Text : VSS.Strings.Virtual_String) return Positive;

      Text  : VSS.Strings.Virtual_String := RegExp;
      Index : Positive;

      ---------
      -- Add --
      ---------

      procedure Add
        (Name : VSS.Strings.Virtual_String; Condition : in out Start_Condition)
      is
         pragma Unreferenced (Name);
      begin
         Condition.Rules.Append (Index);
      end Add;

      -------------------
      -- Add_Inclusive --
      -------------------

      procedure Add_Inclusive
        (Name : VSS.Strings.Virtual_String; Condition : in out Start_Condition)
      is
      begin
         if not Condition.Exclusive then
            Add (Name, Condition);
         end if;
      end Add_Inclusive;

      --------------------
      -- Each_Inclusive --
      --------------------

      procedure Each_Inclusive (Cursor : Start_Condition_Maps.Cursor) is
      begin
         Conditions.Update_Element (Cursor, Add_Inclusive'Access);
      end Each_Inclusive;

      --------------------
      -- Get_Action --
      --------------------

      function Get_Action (Text : VSS.Strings.Virtual_String) return Positive
      is
      begin
         for J in 1 .. Actions.Length loop
            if Actions.Element (J) = Text then
               return J;
            end if;
         end loop;

         Actions.Append (Action);

         return Actions.Length;
      end Get_Action;
   begin
      Indexes.Append (Get_Action (Action));
      Index := Rules.Length + 1;

      if Text.Starts_With ("<") then
         declare
            Cursor : VSS.Strings.Character_Iterators.Character_Iterator :=
              Text.At_First_Character;
         begin
            while Cursor.Has_Element and then Cursor.Element /= '>' loop
               exit when not Cursor.Forward;
            end loop;

            if not Cursor.Has_Element then
               Ada.Wide_Wide_Text_IO.Put_Line
                 ("Line:"
                  & Natural'Wide_Wide_Image (Line)
                  & " "
                  & "Missing '>' in start conditions: "
                  & VSS.Strings.Conversions.To_Wide_Wide_String (Text));
               Success := False;

               return;
            end if;

            declare
               Prefix     : constant VSS.Strings.Virtual_String :=
                 Text.Head_Before (Cursor);
               --  "<" and start conditions
               Conditions : constant VSS.Strings.Virtual_String :=
                 Prefix.Tail_After (Prefix.At_First_Character);
               List       :
                 constant VSS.String_Vectors.Virtual_String_Vector :=
                   Conditions.Split (',');
            begin
               for J in 1 .. List.Length loop
                  declare
                     Condition : constant VSS.Strings.Virtual_String :=
                       List.Element (J);
                     Position  : constant Start_Condition_Maps.Cursor :=
                       Nodes.Conditions.Find (Condition);
                  begin
                     if Start_Condition_Maps.Has_Element (Position) then
                        Nodes.Conditions.Update_Element (Position, Add'Access);
                     else
                        Ada.Wide_Wide_Text_IO.Put_Line
                          ("Line:"
                           & Natural'Wide_Wide_Image (Line)
                           & " "
                           & "No such start condition: "
                           & VSS.Strings.Conversions.To_Wide_Wide_String
                               (Condition));
                        Success := False;
                     end if;
                  end;
               end loop;
            end;

            Text := Text.Tail_After (Cursor);
         end;
      else
         Conditions.Iterate (Each_Inclusive'Access);
      end if;

      Rules.Append (Text);
      Lines.Append (Line);
   end Add_Rule;

   --------------------------
   -- Add_Start_Conditions --
   --------------------------

   procedure Add_Start_Conditions
     (List : VSS.String_Vectors.Virtual_String_Vector; Exclusive : Boolean) is
   begin
      for J in 1 .. List.Length loop
         Conditions.Insert (List.Element (J), (Exclusive, others => <>));
      end loop;
   end Add_Start_Conditions;

   function To_Node (Value : VSS.Strings.Virtual_String) return Node is
   begin
      return (Text, Value);
   end To_Node;

   function To_Action (Value : VSS.Strings.Virtual_String) return Node is
      First : VSS.Strings.Character_Iterators.Character_Iterator :=
        Value.At_First_Character;
      Last  : VSS.Strings.Character_Iterators.Character_Iterator :=
        Value.At_Last_Character;
   begin
      if Value.Character_Length < 3 then
         return To_Node (VSS.Strings.Empty_Virtual_String);
      elsif First.Forward and then Last.Backward then
         return To_Node (Value.Slice (First, Last));
      else
         return To_Node (VSS.Strings.Empty_Virtual_String);
      end if;
   end To_Action;

end UAFLEX.Nodes;
