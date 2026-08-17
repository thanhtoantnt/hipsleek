(* Wrapper: keeps the old Parse_fixbag.parse_fix API on top of the shared
   menhir grammar (fixparser.mly). *)
open Hipsleek_common
open Cpure
open Gen

let parse_fix s =
  let lexbuf = Lexing.from_string s in
  Fixparser.fixbag_expression Fixlexer.token lexbuf
