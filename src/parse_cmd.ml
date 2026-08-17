(* Wrapper: keeps the old Parse_cmd.parse_cmd API (hip REPL) on top of the
   shared menhir grammar (fixparser.mly). *)
open Hipsleek_common
open Iformula
open Gen

let parse_cmd s =
  let lexbuf = Lexing.from_string s in
  Fixparser.cmd_expression Fixlexer.token lexbuf
