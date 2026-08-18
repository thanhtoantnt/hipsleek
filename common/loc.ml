(* Camlp4-Loc compatibility shim over camlp5's Ploc.
   camlp4 -> camlp5 migration: keeps the old call sites (Loc.mk, no_pos
   seeding, start_pos/stop_pos/shift, of_lexbuf) working. *)

type t = Ploc.t

let mk (_ : string) : t = Ploc.dummy
let ghost = Ploc.dummy

let shift = Ploc.shift
let merge l1 l2 = Ploc.encl l1 l2

exception Exc_located of t * exn

let print ppf (l : t) = Format.fprintf ppf "%s" (Ploc.string_of_location l)

let move _side n (l : t) : t =
  Ploc.make (Ploc.first_pos l + n) (Ploc.last_pos l + n)
    (Ploc.line_nb l, Ploc.bol_pos l)

let start_pos (l : t) : Lexing.position =
  { Lexing.pos_fname = Ploc.file_name l;
    pos_lnum = Ploc.line_nb l;
    pos_bol = Ploc.bol_pos l;
    pos_cnum = Ploc.first_pos l }

let stop_pos (l : t) : Lexing.position =
  { Lexing.pos_fname = Ploc.file_name l;
    pos_lnum = Ploc.line_nb_last l;
    pos_bol = Ploc.bol_pos_last l;
    pos_cnum = Ploc.last_pos l }

let to_string = Ploc.string_of_location

let of_lexbuf (lb : Lexing.lexbuf) : t =
  Ploc.make
    (lb.Lexing.lex_abs_pos + lb.Lexing.lex_start_pos)
    (lb.Lexing.lex_abs_pos + lb.Lexing.lex_curr_pos)
    (lb.Lexing.lex_curr_p.Lexing.pos_lnum, lb.Lexing.lex_curr_p.Lexing.pos_bol)

