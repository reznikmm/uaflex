--  SPDX-FileCopyrightText: 2008-2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
---------------------------------------------------------------------

with VSS.String_Vectors;
with VSS.Strings;
with Ada.Containers.Ordered_Maps;
with Ada.Containers.Vectors;
with UAFLEX.Regexps;

package UAFLEX.Nodes is

   type Node_Kind is (Text, Rule, Macro, Name_List);

   type Node (Kind : Node_Kind := Node_Kind'First) is record
      case Kind is
         when Text =>
            Value : VSS.Strings.Virtual_String;

         when Rule =>
            Regexp : VSS.Strings.Virtual_String;
            Action : VSS.Strings.Virtual_String;

         when Macro =>
            Name : VSS.Strings.Virtual_String;
            Text : VSS.Strings.Virtual_String;

         when Name_List =>
            List : VSS.String_Vectors.Virtual_String_Vector;
      end case;
   end record;

   subtype Rule_Node is Node (Rule);

   function To_Node (Value : VSS.Strings.Virtual_String) return Node;
   function To_Action (Value : VSS.Strings.Virtual_String) return Node;

   Empty_Name_List : constant Node (Name_List) :=
     (Kind => Name_List,
      List => VSS.String_Vectors.Empty_Virtual_String_Vector);

   use type VSS.Strings.Virtual_String;

   package Macro_Maps is new
     Ada.Containers.Ordered_Maps
       (VSS.Strings.Virtual_String,   --  Macro name
        VSS.Strings.Virtual_String);  --  Macro value

   package Positive_Vectors is new
     Ada.Containers.Vectors (Index_Type => Positive, Element_Type => Positive);

   type Start_Condition is record
      Exclusive : Boolean;
      Rules     : Positive_Vectors.Vector;
   end record;

   package Start_Condition_Maps is new
     Ada.Containers.Ordered_Maps
       (VSS.Strings.Virtual_String,   --  Condition name
        Start_Condition);

   type Program_Array_Access is access all UAFLEX.Regexps.Program_Array;

   --  List of regexp from input file
   Rules      : VSS.String_Vectors.Virtual_String_Vector;
   --  List of DISTINCT action from input file
   Actions    : VSS.String_Vectors.Virtual_String_Vector;
   --  Map rule index to action index
   Indexes    : Positive_Vectors.Vector;
   --  Map rule index to input file line number
   Lines      : Positive_Vectors.Vector;
   --  Map condition name to Start_Condition
   Conditions : Start_Condition_Maps.Map;
   --  Map macros name to macros value
   Macros     : Macro_Maps.Map;
   --  Array of compiled regexps
   Regexp     : Program_Array_Access;

   Success : Boolean := True;

   procedure Add_Start_Conditions
     (List : VSS.String_Vectors.Virtual_String_Vector; Exclusive : Boolean);

   procedure Add_Rule
     (RegExp : VSS.Strings.Virtual_String;
      Action : VSS.Strings.Virtual_String;
      Line   : Positive);

end UAFLEX.Nodes;
