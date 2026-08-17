(* Wrapper: keeps the old module API (parse_fix, initialize_tlist_from_fpairlist)
   on top of the shared menhir grammar (fixparser.mly). *)
open Hipsleek_common
open Cpure
open Gen

let parse_fix_raw s =
  let lexbuf = Lexing.from_string s in
  Fixparser.fix_expression Fixlexer.token lexbuf

let parse_fix s =
  Debug.no_1 "parse_fix" pr_id (pr_list !Cpure.print_formula) parse_fix_raw s

let initialize_tlist_from_fpairlist = Fixstate.fix_initialize_tlist_from_fpairlist
