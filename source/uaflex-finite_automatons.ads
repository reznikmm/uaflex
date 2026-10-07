--  SPDX-FileCopyrightText: 2008-2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
---------------------------------------------------------------------

with Ada.Containers.Ordered_Maps;
with Ada.Containers.Vectors;
with VSS.Strings;
with UAFLEX.Character_Sets;
with UAFLEX.Graphs;
with UAFLEX.Regexps;

package UAFLEX.Finite_Automatons is

   subtype State is UAFLEX.Graphs.Node_Index;
   use type State;

   package Vectors is new
     Ada.Containers.Vectors
       (Index_Type   => UAFLEX.Graphs.Edge_Identifier,
        Element_Type => UAFLEX.Character_Sets.Character_Set,
        "="          => UAFLEX.Character_Sets."=");

   subtype Rule_Index is Positive;

   package State_Maps is new
     Ada.Containers.Ordered_Maps
       (Key_Type     => State,
        Element_Type => Rule_Index);

   package Start_Maps is new
     Ada.Containers.Ordered_Maps
       (Key_Type     => VSS.Strings.Virtual_String,
        Element_Type => State,
        "<"          => VSS.Strings."<");

   type DFA is limited record
      Start         : Start_Maps.Map;
      Graph         : UAFLEX.Graphs.Graph;
      Edge_Char_Set : Vectors.Vector;
      Final         : State_Maps.Map;
   end record;

   type Rule_Index_Array is array (Positive range <>) of Rule_Index;

   type DFA_Constructor is tagged limited private;

   procedure Compile
     (Self    : in out DFA_Constructor;
      Start   : VSS.Strings.Virtual_String;
      List    : UAFLEX.Regexps.Program_Array;
      Actions : Rule_Index_Array);

   procedure Complete (Input : in out DFA_Constructor; Output : out DFA);

   procedure Minimize (Self : in out DFA);

private

   type DFA_Constructor is tagged limited record
      Start         : Start_Maps.Map;
      Graph         : UAFLEX.Graphs.Constructor.Graph;
      Edge_Char_Set : Vectors.Vector;
      Final         : State_Maps.Map;
   end record;

end UAFLEX.Finite_Automatons;
