--  SPDX-FileCopyrightText: 2008-2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
---------------------------------------------------------------------

with Parser;

with Ada.Directories;
with Ada.Streams.Stream_IO;
with Ada.Strings.UTF_Encoding;
with Ada.Wide_Wide_Text_IO;
with UAFLEX.Expand;
with UAFLEX.Generator.Tables;
with UAFLEX.Generator.OOP_Handler;
with UAFLEX.Nodes;
with VSS.String_Vectors;
with VSS.Transformers.Casing;
with UAFLEX.Finite_Automatons;
with UAFLEX.Regexps;
with VSS.Regular_Expressions.ECMA_Parser_Wrap;
with VSS.Strings;
with VSS.Strings.Conversions;

with String_Sources;

procedure UAFLEX.Run
  (Handler : VSS.Strings.Virtual_String;
   Input   : VSS.Strings.Virtual_String;
   Tokens  : VSS.Strings.Virtual_String;
   Types   : VSS.Strings.Virtual_String;
   Scanner : VSS.Strings.Virtual_String;
   Success : out Boolean)
is
   use type VSS.Strings.Virtual_String;

   procedure Each_Condition (Cursor : Nodes.Start_Condition_Maps.Cursor);
   procedure Each
     (Name : VSS.Strings.Virtual_String; Condition : Nodes.Start_Condition);

   function Read_File (File_Name : String) return VSS.Strings.Virtual_String;

   function To_String (Item : VSS.Strings.Virtual_String) return String
   is (VSS.Strings.Conversions.To_UTF_8_String (Item));

   function To_File_Name
     (Item : VSS.Strings.Virtual_String; Extension : Wide_Wide_String)
      return String;

   function "+" (Item : Wide_Wide_String) return VSS.Strings.Virtual_String
   renames VSS.Strings.To_Virtual_String;

   DFA : UAFLEX.Finite_Automatons.DFA_Constructor;

   ----------
   -- Each --
   ----------

   procedure Each
     (Name : VSS.Strings.Virtual_String; Condition : Nodes.Start_Condition)
   is
      Rule         : Positive;
      Actions      :
        UAFLEX.Finite_Automatons.Rule_Index_Array
          (1 .. Condition.Rules.Last_Index);
      Reg_Exp_List :
        UAFLEX.Regexps.Program_Array (1 .. Condition.Rules.Last_Index);
   begin
      for J in Actions'Range loop
         Rule := Condition.Rules.Element (J);
         Actions (J) := Rule;
         Reg_Exp_List (J) := Nodes.Regexp (Rule);
      end loop;

      DFA.Compile (Name, Reg_Exp_List, Actions);
   end Each;

   --------------------
   -- Each_Condition --
   --------------------

   procedure Each_Condition (Cursor : Nodes.Start_Condition_Maps.Cursor) is
   begin
      Nodes.Start_Condition_Maps.Query_Element (Cursor, Each'Access);
   end Each_Condition;

   ---------------
   -- Read_File --
   ---------------

   function Read_File (File_Name : String) return VSS.Strings.Virtual_String is
      Size : constant Ada.Directories.File_Size :=
        Ada.Directories.Size (File_Name);

      File : Ada.Streams.Stream_IO.File_Type;
      Data : Ada.Strings.UTF_Encoding.UTF_8_String (1 .. Natural (Size));
   begin
      Ada.Streams.Stream_IO.Open
        (File, Ada.Streams.Stream_IO.In_File, File_Name);
      String'Read (Ada.Streams.Stream_IO.Stream (File), Data);
      Ada.Streams.Stream_IO.Close (File);

      return VSS.Strings.Conversions.To_Virtual_String (Data);
   end Read_File;

   ------------------
   -- To_File_Name --
   ------------------

   function To_File_Name
     (Item : VSS.Strings.Virtual_String; Extension : Wide_Wide_String)
      return String
   is
      List : VSS.String_Vectors.Virtual_String_Vector;
      Name : VSS.Strings.Virtual_String;
   begin
      List :=
        Item.Transform (VSS.Transformers.Casing.To_Lowercase).Split ('.');
      Name := List.Join ('-');
      Name.Append (VSS.Strings.To_Virtual_String (Extension));
      return VSS.Strings.Conversions.To_UTF_8_String (Name);
   end To_File_Name;

   Initial : VSS.String_Vectors.Virtual_String_Vector;
   Source  : aliased String_Sources.String_Source;
   Classes : UAFLEX.Finite_Automatons.Vectors.Vector;
begin
   Source.Create
     (VSS.Strings.Conversions.To_Wide_Wide_String
        (Read_File (To_String (Input))));
   Parser.Scanner.Set_Source (Source'Unchecked_Access);
   Parser.Scanner.Set_Handler (Parser.Handler'Unchecked_Access);

   Initial.Append ("INITIAL");
   Nodes.Add_Start_Conditions (Initial, False);

   Parser.YYParse;

   if not Nodes.Success then
      Success := False;
      return;
   end if;

   Expand.RegExps;

   if not Nodes.Success then
      Success := False;
      return;
   end if;

   Nodes.Regexp := new UAFLEX.Regexps.Program_Array (1 .. Nodes.Rules.Length);

   for J in 1 .. Nodes.Rules.Length loop
      declare
         Error : VSS.Strings.Virtual_String;
      begin
         VSS.Regular_Expressions.ECMA_Parser_Wrap.Parse
           (VSS.Strings.To_Virtual_String
              (VSS.Strings.Conversions.To_Wide_Wide_String
                 (Nodes.Rules.Element (J))),
            Nodes.Regexp (J),
            Error);

         if not Error.Is_Empty then
            Ada.Wide_Wide_Text_IO.Put_Line
              ("Line "
               & Natural'Wide_Wide_Image (Nodes.Lines.Element (J))
               & " error on compile regexp '"
               & VSS.Strings.Conversions.To_Wide_Wide_String
                   (Nodes.Rules.Element (J))
               & "'");
            Ada.Wide_Wide_Text_IO.Put_Line
              (VSS.Strings.Conversions.To_Wide_Wide_String (Error));
            Nodes.Success := False;
         end if;
      end;
   end loop;

   if not Nodes.Success then
      Success := False;
      return;
   end if;

   Nodes.Conditions.Iterate (Each_Condition'Access);

   declare
      X : UAFLEX.Finite_Automatons.DFA;
   begin
      DFA.Complete (Output => X);
      UAFLEX.Finite_Automatons.Minimize (X);
      Generator.Tables.Split_To_Distinct (X.Edge_Char_Set, Classes);

      declare
         Map   : Generator.Tables.State_Map (1 .. X.Graph.Node_Count);
         Dead  : UAFLEX.Finite_Automatons.State;
         Final : UAFLEX.Finite_Automatons.State;
      begin
         Generator.Tables.Map_Final_Dead_Ends (X, Dead, Final, Map);

         Generator.Tables.Types
           (X, Map, Dead, Final, Types, To_File_Name (Types, ".ads"), Classes);

         Generator.Tables.Go
           (X,
            Map,
            Dead,
            Final,
            +"Tables",
            To_File_Name
              (Scanner & VSS.Strings.Virtual_String'(".Tables"), ".adb"),
            Types,
            Scanner,
            Classes);
      end;
   end;

   Generator.OOP_Handler.Go
     (Nodes.Actions,
      To_File_Name (Handler, ".ads"),
      Types,
      Handler,
      Scanner,
      Tokens);

   Generator.OOP_Handler.On_Accept
     (Nodes.Actions,
      To_File_Name
        (Scanner & VSS.Strings.Virtual_String'(".On_Accept"), ".adb"),
      Types,
      Handler,
      Scanner,
      Tokens);

   Success := True;
end UAFLEX.Run;
