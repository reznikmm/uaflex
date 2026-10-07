--  SPDX-FileCopyrightText: 2008-2026 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
---------------------------------------------------------------------


package body UAFLEX.Finite_Automatons is

   use type UAFLEX.Regexps.Token_Kind;

   type Position is new Natural;
   --  Position is index of a literal element of regexp
   --  for example: (a|b)*abb
   --                1 2  345

   --  Map each literal to corresponding character set
   type Character_Set_Map is
     array (Position range <>) of UAFLEX.Character_Sets.Character_Set;

   function Count_Positions (Item : UAFLEX.Regexps.Program) return Position;
   --  Return count of literal elements in given regexp

   function Count_Positions
     (List : UAFLEX.Regexps.Program_Array) return Position;
   --  Return count of positions for all regexps in List, including one
   --  fictive terminating symbol for each regexp

   -------------
   -- Compile --
   -------------

   procedure Compile
     (Self    : in out DFA_Constructor;
      Start   : VSS.Strings.Virtual_String;
      List    : UAFLEX.Regexps.Program_Array;
      Actions : Rule_Index_Array)
   is
      Max_Pos : constant Position := Count_Positions (List);

      type Position_Set is array (1 .. Max_Pos) of Boolean;

      Empty : constant Position_Set := (others => False);

      subtype Finish_Position is Position range 1 .. List'Length;

      type Position_Set_Array is array (1 .. Max_Pos) of Position_Set;

      Follow : Position_Set_Array := (others => Empty);
      Chars  : Character_Set_Map (1 .. Max_Pos);

      procedure Add_To_Follow (First : Position_Set; Last : Position_Set);
      --  Update Follow array according to First and Last position sets

      function Get_Follows
        (Set  : Position_Set;
         Map  : Character_Set_Map;
         Char : UAFLEX.Character_Sets.Character_Set) return Position_Set;
      --  Get positions set reachable from Set on input belong to Char

      procedure Split_To_Distinct_Sets
        (Set  : Position_Set;
         Map  : Character_Set_Map;
         List : out Vectors.Vector);
      --  Fill character set List with non-intersected subsets of
      --  characters in Map (Set)

      procedure Make_DFA
        (Graph : in out UAFLEX.Graphs.Constructor.Graph;
         Start : out State;
         Edges : in out Vectors.Vector;
         Final : in out State_Maps.Map;
         First : Position_Set;
         Map   : Character_Set_Map);

      function Singleton (Index : Position) return Position_Set;

      procedure Walk
        (Item     : UAFLEX.Regexps.Program;
         Pos      : in out Position;
         Nullable : out Boolean;
         First    : out Position_Set;
         Last     : out Position_Set);
      --  Evaluate postfix program. Assign positions to leafs, update
      --  Follow array and return Nullable, First and Last of the whole
      --  program.

      -------------------
      -- Add_To_Follow --
      -------------------

      procedure Add_To_Follow (First : Position_Set; Last : Position_Set) is
      begin
         for J in Last'Range loop
            if Last (J) then
               Follow (J) := Follow (J) or First;
            end if;
         end loop;
      end Add_To_Follow;

      -----------------
      -- Get_Follows --
      -----------------

      function Get_Follows
        (Set  : Position_Set;
         Map  : Character_Set_Map;
         Char : UAFLEX.Character_Sets.Character_Set) return Position_Set
      is
         Result : Position_Set := Empty;
      begin
         for J in Set'Range loop
            if Set (J) and then Char.Is_Subset (Map (J)) then
               Result := Result or Follow (J);
            end if;
         end loop;

         return Result;
      end Get_Follows;

      --------------
      -- Make_DFA --
      --------------

      procedure Make_DFA
        (Graph : in out UAFLEX.Graphs.Constructor.Graph;
         Start : out State;
         Edges : in out Vectors.Vector;
         Final : in out State_Maps.Map;
         First : Position_Set;
         Map   : Character_Set_Map)
      is
         use UAFLEX.Graphs.Constructor;

         function New_Node (Set : Position_Set) return Node;
         --  Allocate new state/node, add it to Final if needed

         package Maps is new Ada.Containers.Ordered_Maps (Position_Set, Node);

         --------------
         -- New_Node --
         --------------

         function New_Node (Set : Position_Set) return Node is
            Result : constant Node := Graph.New_Node;
            Index  : Rule_Index;
         begin
            if Set (Finish_Position) /= (Finish_Position => False) then
               for J in Finish_Position loop
                  if Set (J) then
                     Index := Actions (Positive (J));
                     exit;
                  end if;
               end loop;

               Final.Insert (Result.Index, Index);
            end if;

            return Result;
         end New_Node;

         Marked     : Maps.Map;
         Not_Marked : Maps.Map;
      begin
         declare
            First_Node : constant Node := New_Node (First);
         begin
            Start := First_Node.Index;
            Not_Marked.Insert (First, First_Node);
         end;

         while not Not_Marked.Is_Empty loop
            declare
               Source : constant Node := Not_Marked.First_Element;
               Set    : constant Position_Set := Not_Marked.First_Key;
               List   : Vectors.Vector;
            begin
               Not_Marked.Delete_First;
               Marked.Insert (Set, Source);
               Split_To_Distinct_Sets (Set, Map, List);

               for J in List.First_Index .. List.Last_Index loop
                  declare
                     use type Ada.Containers.Count_Type;

                     Target : Node;
                     Cursor : Maps.Cursor;
                     Next   : constant Position_Set :=
                       Get_Follows (Set, Map, List.Element (J));
                  begin
                     if Next /= Empty then
                        Cursor := Marked.Find (Next);

                        if Maps.Has_Element (Cursor) then
                           Target := Maps.Element (Cursor);
                        else
                           Cursor := Not_Marked.Find (Next);

                           if Maps.Has_Element (Cursor) then
                              Target := Maps.Element (Cursor);
                           else
                              Target := New_Node (Next);
                              Not_Marked.Insert (Next, Target);
                           end if;
                        end if;

                        --  Let's suppose edge allocation in sequent order
                        Edges.Set_Length (Edges.Length + 1);

                        Edges.Replace_Element
                          (Index    => Source.New_Edge (Target),
                           New_Item => List.Element (J));

                     end if;
                  end;
               end loop;
            end;
         end loop;
      end Make_DFA;

      ----------------------------
      -- Split_To_Distinct_Sets --
      ----------------------------

      procedure Split_To_Distinct_Sets
        (Set  : Position_Set;
         Map  : Character_Set_Map;
         List : out Vectors.Vector) is
      begin
         for J in Set'Range loop
            if Set (J) then
               declare
                  use UAFLEX.Character_Sets;
                  Rest : Character_Set := Map (J);
               begin
                  for K in List.First_Index .. List.Last_Index loop
                     declare
                        Item         : constant Character_Set :=
                          List.Element (K);
                        Intersection : constant Character_Set := Item and Rest;
                     begin
                        if not Intersection.Is_Empty then
                           declare
                              Extra : constant Character_Set := Item - Rest;
                           begin
                              if not Extra.Is_Empty then
                                 List.Append (Extra);
                              end if;

                              Rest := Rest - Item;
                              List.Replace_Element (K, Intersection);
                           end;
                        end if;
                     end;
                  end loop;

                  if not Rest.Is_Empty then
                     List.Append (Rest);
                  end if;
               end;
            end if;
         end loop;
      end Split_To_Distinct_Sets;

      ---------------
      -- Singleton --
      ---------------

      function Singleton (Index : Position) return Position_Set is
      begin
         return Result : Position_Set := Empty do
            Result (Index) := True;
         end return;
      end Singleton;

      ----------
      -- Walk --
      ----------

      procedure Walk
        (Item     : UAFLEX.Regexps.Program;
         Pos      : in out Position;
         Nullable : out Boolean;
         First    : out Position_Set;
         Last     : out Position_Set)
      is
         type Operand is record
            Nullable : Boolean;
            First    : Position_Set;
            Last     : Position_Set;
         end record;

         package Operand_Vectors is new
           Ada.Containers.Vectors (Positive, Operand);

         Stack : Operand_Vectors.Vector;
         Right : Operand;
         Left  : Operand;
      begin
         for Token of Item loop
            case Token.Kind is
               when UAFLEX.Regexps.Leaf                       =>
                  Chars (Pos) := Token.Set;
                  Stack.Append
                    (Operand'
                       (Nullable => False,
                        First    => Singleton (Pos),
                        Last     => Singleton (Pos)));
                  Pos := Pos + 1;

               when UAFLEX.Regexps.Empty                      =>
                  Stack.Append
                    (Operand'
                       (Nullable => True, First => Empty, Last => Empty));

               when UAFLEX.Regexps.Sequence                   =>
                  Right := Stack.Last_Element;
                  Stack.Delete_Last;
                  Left := Stack.Last_Element;
                  Stack.Delete_Last;
                  Add_To_Follow (Right.First, Left.Last);

                  Stack.Append
                    (Operand'
                       (Nullable => Left.Nullable and Right.Nullable,
                        First    =>
                          (if Left.Nullable
                           then Left.First or Right.First
                           else Left.First),
                        Last     =>
                          (if Right.Nullable
                           then Left.Last or Right.Last
                           else Right.Last)));

               when UAFLEX.Regexps.Alternative                =>
                  Right := Stack.Last_Element;
                  Stack.Delete_Last;
                  Left := Stack.Last_Element;
                  Stack.Delete_Last;

                  Stack.Append
                    (Operand'
                       (Nullable => Left.Nullable or Right.Nullable,
                        First    => Left.First or Right.First,
                        Last     => Left.Last or Right.Last));

               when UAFLEX.Regexps.Star | UAFLEX.Regexps.Plus =>
                  Left := Stack.Last_Element;
                  Add_To_Follow (Left.First, Left.Last);

                  Stack.Reference (Stack.Last_Index).Nullable :=
                    Token.Kind = UAFLEX.Regexps.Star or Left.Nullable;
            end case;
         end loop;

         Nullable := Stack.Last_Element.Nullable;
         First := Stack.Last_Element.First;
         Last := Stack.Last_Element.Last;
      end Walk;

      Pos    : Position := Position (List'Length) + 1;
      First  : Position_Set := Empty;
      Result : State;
   begin
      for J in List'Range loop
         declare
            Item_Nullable : Boolean;
            Item_First    : Position_Set;
            Item_Last     : Position_Set;
            Result_First  : Position_Set := Empty;
         begin
            Walk (List (J), Pos, Item_Nullable, Item_First, Item_Last);
            First := First or Item_First;
            --  Fictive termination symbol:
            Result_First (Finish_Position (J)) := True;
            Add_To_Follow (Result_First, Item_Last);

            if Item_Nullable then
               First := First or Result_First;
            end if;
         end;
      end loop;

      Make_DFA
        (Self.Graph, Result, Self.Edge_Char_Set, Self.Final, First, Chars);

      Self.Start.Insert (Start, Result);
   end Compile;

   --------------
   -- Complete --
   --------------

   procedure Complete (Input : in out DFA_Constructor; Output : out DFA) is
   begin
      Output.Start := Input.Start;
      Input.Graph.Complete (Output => Output.Graph);
      Output.Edge_Char_Set := Input.Edge_Char_Set;
      Output.Final := Input.Final;
   end Complete;

   ---------------------
   -- Count_Positions --
   ---------------------

   function Count_Positions
     (List : UAFLEX.Regexps.Program_Array) return Position
   is
      Result : Position := Position (List'Length);
      --  Terminate each regexp with fictive symbol
   begin
      for Item of List loop
         Result := Result + Count_Positions (Item);
      end loop;

      return Result;
   end Count_Positions;

   ---------------------
   -- Count_Positions --
   ---------------------

   function Count_Positions (Item : UAFLEX.Regexps.Program) return Position is
      Result : Position := 0;
   begin
      for Token of Item loop
         if Token.Kind = UAFLEX.Regexps.Leaf then
            Result := Result + 1;
         end if;
      end loop;

      return Result;
   end Count_Positions;

   --------------
   -- Minimize --
   --------------

   procedure Minimize (Self : in out DFA) is

      function Intersection
        (Left, Right : UAFLEX.Character_Sets.Character_Set)
         return UAFLEX.Character_Sets.Character_Set
      renames UAFLEX.Character_Sets."and";

      package Graphs renames UAFLEX.Graphs;

      function Check_Equive_Class (X, Y : State) return Boolean;

      type State_Pair is array (1 .. 2) of State;

      use type UAFLEX.Graphs.Edge_Identifier;

      package State_Pair_Maps is new
        Ada.Containers.Ordered_Maps
          (State_Pair,
           UAFLEX.Graphs.Edge_Identifier);

      Last        : constant State := Self.Graph.Node_Count;
      Error_State : constant State := Last + 1;

      type Equive_Array is array (1 .. Error_State) of State;
      Equive      : Equive_Array := (others => 1);
      Next_Equive : Equive_Array := (others => 1);

      function Check_Equive_Class (X, Y : State) return Boolean is
         Node_X : constant Graphs.Node := Self.Graph.Get_Node (X);
         Node_Y : constant Graphs.Node := Self.Graph.Get_Node (Y);
      begin
         for I in Node_X.First_Edge_Index .. Node_X.Last_Edge_Index loop
            declare
               use UAFLEX.Character_Sets;

               Edge_X : constant Graphs.Edge := Self.Graph.Get_Edge (I);
               Jump_X : constant State := Edge_X.Target_Node.Index;
               Sym_X  : UAFLEX.Character_Sets.Character_Set :=
                 Self.Edge_Char_Set.Element (Edge_X.Edge_Id);
            begin
               for J in Node_Y.First_Edge_Index .. Node_Y.Last_Edge_Index loop
                  declare
                     Edge_Y : constant Graphs.Edge := Self.Graph.Get_Edge (J);
                     Sym_Y  : constant UAFLEX.Character_Sets.Character_Set :=
                       Self.Edge_Char_Set.Element (Edge_Y.Edge_Id);
                     Jump_Y : constant State := Edge_Y.Target_Node.Index;
                  begin
                     if not Intersection (Sym_X, Sym_Y).Is_Empty then
                        if Equive (Jump_X) /= Equive (Jump_Y) then
                           return False;
                        else
                           Sym_X := Sym_X - Sym_Y;
                        end if;
                     end if;
                  end;
               end loop;

               if not Sym_X.Is_Empty
                 and Equive (Jump_X) /= Equive (Error_State)
               then
                  return False;
               end if;
            end;
         end loop;

         return True;
      end Check_Equive_Class;

      Current_Equive_Class : State'Base;
      Prev_Equive_Class    : State := 1;
      Found                : Boolean;

   begin
      Init_Equive_Classes :
      for J in 1 .. Last loop
         if Self.Final.Contains (J) then
            Equive (J) := State (Self.Final.Element (J) + 1);
            Prev_Equive_Class := State'Max (Prev_Equive_Class, Equive (J));
         end if;
      end loop Init_Equive_Classes;

      Try_Split_Equive_Classes :
      loop
         Current_Equive_Class := 0;

         Set_Equive_Classes :
         for I in 1 .. Last loop
            Found := False;

            Find_Existent_Class :
            for J in 1 .. I - 1 loop
               if Equive (I) = Equive (J)
                 and then Self.Final.Contains (I) = Self.Final.Contains (J)
               then
                  Found :=
                    Check_Equive_Class (I, J)
                    and then Check_Equive_Class (J, I);

                  if Found then
                     Next_Equive (I) := Next_Equive (J);
                     exit Find_Existent_Class;
                  end if;
               end if;
            end loop Find_Existent_Class;

            if not Found then
               Current_Equive_Class := Current_Equive_Class + 1;
               Next_Equive (I) := Current_Equive_Class;
            end if;
         end loop Set_Equive_Classes;

         Current_Equive_Class := Current_Equive_Class + 1;
         Next_Equive (Error_State) := Current_Equive_Class;

         exit Try_Split_Equive_Classes when
           Prev_Equive_Class = Current_Equive_Class;

         Prev_Equive_Class := Current_Equive_Class;
         Equive := Next_Equive;
      end loop Try_Split_Equive_Classes;

      --  Create_DFA

      declare
         procedure Each_Start (Cursor : Start_Maps.Cursor);

         use UAFLEX.Graphs.Constructor;
         Result : Graph;
         Edges  : Vectors.Vector;
         Map    : State_Pair_Maps.Map;
         Final  : State_Maps.Map;
         Nodes  : array (1 .. Current_Equive_Class - 1) of Node;

         ----------------
         -- Each_Start --
         ----------------

         procedure Each_Start (Cursor : Start_Maps.Cursor) is
            Old : constant State := Start_Maps.Element (Cursor);
         begin
            Self.Start.Replace_Element (Cursor, Nodes (Equive (Old)).Index);
         end Each_Start;

      begin
         for K in Nodes'Range loop
            Nodes (K) := Result.New_Node;
         end loop;

         for I in 1 .. Last loop
            declare
               use type Ada.Containers.Count_Type;

               procedure Append_Chars
                 (X : in out UAFLEX.Character_Sets.Character_Set);

               Edge_J : Graphs.Edge;

               ------------------
               -- Append_Chars --
               ------------------

               procedure Append_Chars
                 (X : in out UAFLEX.Character_Sets.Character_Set)
               is
                  use UAFLEX.Character_Sets;
               begin
                  X := X or Self.Edge_Char_Set.Element (Edge_J.Edge_Id);
               end Append_Chars;

               Node_X : constant Graphs.Node := Self.Graph.Get_Node (I);
               Edge   : Graphs.Edge_Identifier;
               Pair   : State_Pair;
               Cursor : State_Pair_Maps.Cursor;
            begin
               for J in Node_X.First_Edge_Index .. Node_X.Last_Edge_Index loop
                  Edge_J := Self.Graph.Get_Edge (J);
                  Pair (1) := Equive (I);
                  Pair (2) := Equive (Edge_J.Target_Node.Index);
                  Cursor := Map.Find (Pair);

                  if State_Pair_Maps.Has_Element (Cursor) then
                     Edges.Update_Element
                       (State_Pair_Maps.Element (Cursor), Append_Chars'Access);
                  else
                     Edge := Nodes (Pair (1)).New_Edge (Nodes (Pair (2)));
                     Map.Insert (Pair, Edge);
                     Edges.Set_Length (Edges.Length + 1);

                     Edges.Replace_Element
                       (Edge, Self.Edge_Char_Set.Element (Edge_J.Edge_Id));
                  end if;
               end loop;

               if Self.Final.Contains (I) then
                  Final.Include
                    (Nodes (Equive (I)).Index, Self.Final.Element (I));
               end if;
            end;
         end loop;

         Self.Start.Iterate (Each_Start'Access);
         Self.Graph.Clear;
         Result.Complete (Output => Self.Graph);
         Self.Edge_Char_Set := Edges;
         Self.Final := Final;
      end;
   end Minimize;

end UAFLEX.Finite_Automatons;
