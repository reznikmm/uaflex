--  SPDX-FileCopyrightText: 2008-2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
---------------------------------------------------------------------

with UAFLEX.Finite_Automatons;
with VSS.Strings;

package UAFLEX.Generator.Tables is

   type State_Map is
     array (UAFLEX.Finite_Automatons.State range <>)
     of UAFLEX.Finite_Automatons.State;
   --  Map from original states to remaped states

   procedure Map_Final_Dead_Ends
     (DFA            : UAFLEX.Finite_Automatons.DFA;
      First_Dead_End : out UAFLEX.Finite_Automatons.State;
      First_Final    : out UAFLEX.Finite_Automatons.State;
      Dead_End_Map   : out State_Map);
   --  Remap final states without any further edges to the end of state range

   procedure Split_To_Distinct
     (List   : UAFLEX.Finite_Automatons.Vectors.Vector;
      Result : out UAFLEX.Finite_Automatons.Vectors.Vector);

   procedure Go
     (DFA            : UAFLEX.Finite_Automatons.DFA;
      Dead_End_Map   : State_Map;
      First_Dead_End : UAFLEX.Finite_Automatons.State;
      First_Final    : UAFLEX.Finite_Automatons.State;
      Unit           : VSS.Strings.Virtual_String;
      File           : String;
      Types          : VSS.Strings.Virtual_String;
      Scanner        : VSS.Strings.Virtual_String;
      Classes        : UAFLEX.Finite_Automatons.Vectors.Vector);

   procedure Types
     (DFA            : UAFLEX.Finite_Automatons.DFA;
      Dead_End_Map   : State_Map;
      First_Dead_End : UAFLEX.Finite_Automatons.State;
      First_Final    : UAFLEX.Finite_Automatons.State;
      Unit           : VSS.Strings.Virtual_String;
      File           : String;
      Classes        : UAFLEX.Finite_Automatons.Vectors.Vector);

end UAFLEX.Generator.Tables;
