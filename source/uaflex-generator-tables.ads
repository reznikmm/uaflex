------------------------------------------------------------------------------
--                                                                          --
--                            Matreshka Project                             --
--                                                                          --
--         Localization, Internationalization, Globalization for Ada        --
--                                                                          --
--                              Tools Component                             --
--                                                                          --
------------------------------------------------------------------------------
--                                                                          --
-- Copyright © 2012-2017, Vadim Godunko <vgodunko@gmail.com>                --
-- All rights reserved.                                                     --
--                                                                          --
-- Redistribution and use in source and binary forms, with or without       --
-- modification, are permitted provided that the following conditions       --
-- are met:                                                                 --
--                                                                          --
--  * Redistributions of source code must retain the above copyright        --
--    notice, this list of conditions and the following disclaimer.         --
--                                                                          --
--  * Redistributions in binary form must reproduce the above copyright     --
--    notice, this list of conditions and the following disclaimer in the   --
--    documentation and/or other materials provided with the distribution.  --
--                                                                          --
--  * Neither the name of the Vadim Godunko, IE nor the names of its        --
--    contributors may be used to endorse or promote products derived from  --
--    this software without specific prior written permission.              --
--                                                                          --
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS      --
-- "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT        --
-- LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR    --
-- A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT     --
-- HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,   --
-- SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED --
-- TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR   --
-- PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF   --
-- LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING     --
-- NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS       --
-- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.             --
--                                                                          --
------------------------------------------------------------------------------
--  $Revision$ $Date$
------------------------------------------------------------------------------
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
