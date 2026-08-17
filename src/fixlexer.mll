{
(* Shared lexer for the fixcalc/fixbag/shape output parsers.
   Replaces camlp4's dynamic keyword lexer with a fixed token set: the
   keyword set below is the union of all quoted literals that the four
   old camlp4 grammars registered globally (parse_cmd's keywords dropped
   along with that dead module), so tokenization matches the old shared
   camlp4 lexer exactly. *)
open Fixparser
exception Error of string
let kw s = match s with
  | "true" -> KW_TRUE
  | "forall" -> KW_FORALL
  | "exists" -> KW_EXISTS
  | "infer_spec" -> KW_INFER_SPEC
  | "exit" -> KW_EXIT
  | "shape" -> KW_SHAPE
  | "pre" -> KW_PRE
  | "post" -> KW_POST
  | "both" -> KW_BOTH
  | "in" -> KW_IN
  | "label" -> KW_LABEL
  | "hasValue" -> KW_HASVALUE
  | "AuxValue" -> KW_AUXVALUE
  | "SLS" -> KW_SLS
  | "SUMMARY" -> KW_SUMMARY
  | "next" -> KW_NEXT
  | "tl" -> KW_TL
  | "data" -> KW_DATA
  | _ -> if s.[0] = '_' || (s.[0] >= 'a' && s.[0] <= 'z') then LIDENT s else UIDENT s
}

let digit = ['0'-'9']
let ident_char = ['A'-'Z' 'a'-'z' '0'-'9' '_' '\'']

rule token = parse
  | [' ' '\t' '\r' '\n']+       { token lexbuf }
  | "(*"  { comment 0 lexbuf }
  | digit+ 'n'                  { NATIVEINT }
  | digit+ as s                 { INT s }
  | ['a'-'z' '_'] ident_char* as s { kw s }
  | ['A'-'Z'] ident_char* as s  { kw s }
  | "||"  { BARBAR }
  | "&&"  { ANDAND }
  | "<="  { LESSEQ }
  | ">="  { GREATEREQ }
  | "!="  { NEQ }
  | "->"  { ARROW }
  | "="   { EQUAL }
  | "<"   { LESS }
  | ">"   { GREATER }
  | "+"   { PLUS }
  | "-"   { MINUS }
  | "*"   { STAR }
  | "|"   { PIPE }
  | "{"   { LBRACE }
  | "}"   { RBRACE }
  | "["   { LBRACKET }
  | "]"   { RBRACKET }
  | ","   { COMMA }
  | ":"   { COLON }
  | ";"   { SEMI }
  | eof   { EOF }
  | _ as c { raise (Error (Printf.sprintf "fixlexer: bad char '%c'" c)) }

and comment depth = parse
  | "*)" { if depth = 0 then token lexbuf else comment (depth - 1) lexbuf }
  | "(*" { comment (depth + 1) lexbuf }
  | eof  { raise (Error "fixlexer: unterminated comment") }
  | _    { comment depth lexbuf }
