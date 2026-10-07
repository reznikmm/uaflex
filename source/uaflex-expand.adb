--  SPDX-FileCopyrightText: 2008-2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
---------------------------------------------------------------------

with Ada.Wide_Wide_Text_IO;
with UAFLEX.Nodes;
with VSS.Characters;
with VSS.Regular_Expressions;
with VSS.String_Vectors;
with VSS.Strings.Character_Iterators;
with VSS.Strings.Conversions;

package body UAFLEX.Expand is

   use type VSS.Characters.Virtual_Character;

   procedure Expand_Macro
     (Text : in out VSS.Strings.Virtual_String; Line : Positive);

   procedure To_Regexp (Text : in out VSS.Strings.Virtual_String);

   Macro_1 : constant Wide_Wide_String := "^\{([a-zA-Z][a-zA-Z0-9_]*)\}";
   Macro_2 : constant Wide_Wide_String := "[^pP]\{([a-zA-Z][a-zA-Z0-9_]*)\}";
   Macro_3 : constant Wide_Wide_String :=
     "[^\\][pP]\{([a-zA-Z][a-zA-Z0-9_]*)\}";

   Macro_Pattern : constant Wide_Wide_String :=
     Macro_1 & '|' & Macro_2 & '|' & Macro_3;

   Macro_Reference : constant VSS.Strings.Virtual_String :=
     VSS.Strings.To_Virtual_String (Macro_Pattern);

   Macro : constant VSS.Regular_Expressions.Regular_Expression :=
     VSS.Regular_Expressions.To_Regular_Expression (Macro_Reference);

   function Is_Syntax (Item : VSS.Characters.Virtual_Character) return Boolean
   is (Item
       in '\'
        | '^'
        | '$'
        | '.'
        | '*'
        | '+'
        | '?'
        | '('
        | ')'
        | '['
        | ']'
        | '{'
        | '}'
        | '|');
   --  Characters, which have a special meaning in ECMAScript regexp, and
   --  can be escaped by a backslash.

   function Is_Escape (Item : VSS.Characters.Virtual_Character) return Boolean
   is (Item
       in 'a'
        | 'e'
        | 'f'
        | 'n'
        | 'r'
        | 't'
        | 'v'
        | 'c'
        | 'u'
        | 'U'
        | 'p'
        | 'P');

   ------------------
   -- Expand_Macro --
   ------------------

   procedure Expand_Macro
     (Text : in out VSS.Strings.Virtual_String; Line : Positive)
   is
      Found : constant VSS.Regular_Expressions.Regular_Expression_Match :=
        Macro.Match (Text);
      Index : Positive := 1;
   begin
      if not Found.Has_Match then
         return;
      end if;

      for J in 1 .. 3 loop
         if Found.Has_Capture (J) then
            Index := J;
         end if;
      end loop;

      declare
         Name : constant VSS.Strings.Virtual_String := Found.Captured (Index);
         Pos  : constant Nodes.Macro_Maps.Cursor := Nodes.Macros.Find (Name);
      begin
         if Nodes.Macro_Maps.Has_Element (Pos) then
            declare
               First : VSS.Strings.Character_Iterators.Character_Iterator :=
                 Text.At_Character (Found.First_Marker (Index));
               --  Opening brace is just before the macro name
               Last  : VSS.Strings.Character_Iterators.Character_Iterator :=
                 Text.At_Character (Found.Last_Marker (Index));
               --  Closing brace is just after the macro name
            begin
               if First.Backward and then Last.Forward then
                  declare
                     Result : VSS.Strings.Virtual_String :=
                       Text.Head_Before (First);
                  begin
                     Result.Append (Nodes.Macro_Maps.Element (Pos));
                     Result.Append (Text.Tail_After (Last));
                     Text := Result;
                  end;
               end if;
            end;
         else
            Ada.Wide_Wide_Text_IO.Put_Line
              ("Line "
               & Natural'Wide_Wide_Image (Line)
               & " Macro's definition not found for: "
               & VSS.Strings.Conversions.To_Wide_Wide_String (Name));
            Nodes.Success := False;

            return;
         end if;

         Expand_Macro (Text, Line);
      end;
   end Expand_Macro;

   -------------
   -- RegExps --
   -------------

   procedure RegExps is
      Result : VSS.String_Vectors.Virtual_String_Vector;
   begin
      for J in 1 .. Nodes.Rules.Length loop
         declare
            Item : VSS.Strings.Virtual_String := Nodes.Rules.Element (J);
         begin
            Expand_Macro (Item, Nodes.Lines.Element (J));
            To_Regexp (Item);
            Result.Append (Item);
         end;
      end loop;

      Nodes.Rules := Result;
   end RegExps;

   ---------------
   -- To_Regexp --
   ---------------

   procedure To_Regexp (Text : in out VSS.Strings.Virtual_String) is
      type States is (Normal, In_Quote, Masked, Class, Category);
      --  [/First/ ^ /C1/ x /c2/ - /c3/ y ]
      type Class_States is (First, C1, C2, C3);
      Result   : VSS.Strings.Virtual_String;
      State    : States := Normal;
      In_Class : Class_States;
      Cursor   : VSS.Strings.Character_Iterators.Character_Iterator :=
        Text.At_First_Character;
   begin
      while Cursor.Has_Element loop
         declare
            Item : constant VSS.Characters.Virtual_Character := Cursor.Element;
         begin
            case State is
               when Normal   =>
                  if Item = '"' then
                     State := In_Quote;
                  elsif Item = '\' then
                     State := Masked;
                     In_Class := First;
                  elsif Item = '[' then
                     Result.Append (Item);
                     State := Class;
                     In_Class := First;
                  else
                     Result.Append (Item);
                  end if;

               when In_Quote =>
                  if Item = '"' then
                     State := Normal;
                  else
                     if Is_Syntax (Item) then
                        Result.Append ('\');
                     end if;

                     Result.Append (Item);
                  end if;

               when Masked   =>
                  if Is_Syntax (Item)
                    or Is_Escape (Item)
                    or (In_Class /= First and Item = '-')
                  then
                     Result.Append ('\');
                     Result.Append (Item);
                  else
                     Result.Append (Item);
                  end if;

                  if In_Class = First then
                     State := Normal;
                  else
                     State := Class;
                  end if;

               when Class    =>
                  if Item = ']' then
                     if In_Class = C3 then
                        Result.Append ("\-");
                     end if;

                     Result.Append (Item);
                     State := Normal;
                  elsif Item = '[' then
                     if In_Class = C3 then
                        Result.Append ("\-");
                     end if;

                     Result.Append (Item);
                     In_Class := C1;
                     State := Category;
                  elsif In_Class = First and Item = ':' then
                     Result.Append (Item);
                     State := Category;
                  elsif In_Class = First and Item = '^' then
                     Result.Append (Item);
                     In_Class := C1;
                  elsif In_Class = C2 and Item = '-' then
                     In_Class := C3;
                  else
                     if In_Class = C3 then
                        Result.Append ("-");
                        In_Class := C1;
                     else
                        In_Class := C2;
                     end if;

                     if Item = '\' then
                        State := Masked;
                     elsif Is_Syntax (Item) or Item = '-' then
                        Result.Append ('\');
                        Result.Append (Item);
                     else
                        Result.Append (Item);
                     end if;
                  end if;

               when Category =>
                  Result.Append (Item);

                  if Item = ']' then
                     if In_Class = First then
                        State := Normal;
                     else
                        State := Class;
                     end if;
                  end if;
            end case;
         end;

         exit when not Cursor.Forward;
      end loop;

      Text := Result;
   end To_Regexp;

end UAFLEX.Expand;
