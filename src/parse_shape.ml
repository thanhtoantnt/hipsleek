(* Wrapper: keeps the old Parse_shape.parse_shape API on top of the shared
   menhir grammar (fixparser.mly). *)
open Hipsleek_common
open Cformula
open Gen

let parse_shape s =
  let lexbuf = Lexing.from_string s in
  Fixparser.shape_expression Fixlexer.token lexbuf
