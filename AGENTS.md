# AGENTS.md

## Purpose

Unicode-aware lexical analyzer generator for Ada, similar to lex.

## Repository Map

- `source/`: Core library logic (`Uaflex.*` packages)
- `testsuite/`: Separate test suite crate
- `config/`: Build-time configuration artifacts written by Alire (do not edit manually)
- `.obj/`, `.lib/`: Build outputs (do not edit manually)

## Ground Rules

- Don't suppress exception with `null;` exception handler
   (one exception is `Libadalang.Common.Property_Error`).
- Don't introduce extra (sub-)type conversions, like Integer to Natural.
- Preserve existing style and naming conventions in nearby code. Don't use abbreviations.

## Build And Test Commands

Run from repository root unless noted otherwise.

- Compile core library:
  - `alr build`
- Compile/check one file (`<unit>.adb`):
  - `alr exec -- gprbuild -q -f -c -u -gnatc -P uaflex.gpr <unit>.adb '-cargs:ada' -gnatef`
- Fix code style warnings, force code style after edit:
  - `alr exec -- gnatformat --charset=utf-8 --no-subprojects -P uaflex.gpr`
- Build and run testsuite:
  - `alr -C testsuite/ run`

## Change Workflow For Agents

1. Read relevant package spec/body before editing. Read `*.adb` only if reading of corresponding `*.ads` is not enough.
2. Implement the smallest viable patch.
3. Re-run compile check for touched units.
4. Run targeted runtime/test command when behavior changes.
5. Report exactly what changed and what was validated.

## Ada-Specific Notes

- Prefer `VSS.Strings.Virtual_String` for string handling.
- Use predefined Ada container packages
  (for example, `Ada.Containers.Hashed_Sets`). Don't use Indefinite containers.
- Use Ada 2022 syntax if you can.
- Prefer conditional expressions over if-statements to keep nesting shallow, e.g.:
   ```
   Type_Decl : Libadalang.Analysis.Base_Type_Decl :=
     (if Type_Expr.Is_Null then Libadalang.Analysis.No_Base_Type_Decl
      else Type_Expr.P_Designated_Type_Decl);
   ```
- Use dot notation for calls on tagged/class-wide values where available
   (`Node.Kind`), rather than the prefixed subprogram form
   (`Libadalang.Common.Kind (Node)`).
- Place an explanatory comment for a declaration after it, not before.

## Output And Error Handling Expectations

- Diagnostics should be actionable and include path/context when possible.

## When Unsure

- Prefer conservative changes.
- Ask for clarification before large architectural rewrites.
- Document assumptions in the final update.
