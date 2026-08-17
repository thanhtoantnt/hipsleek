/*
  Merged ocamlyacc grammar replacing the camlp4 EXTEND grammars in
  parse_fix.ml, parse_fixbag.ml and parse_shape.ml (parse_cmd.ml had no
  live callers and was deleted). Semantic actions are copied verbatim;
  nonterminals are prefixed per family. One shared lexer (fixlexer.mll).
*/
%{
open Hipsleek_common
open VarGen
open Cformula
open Cpure
open Globals
open Gen
open Fixstate

let loc = no_pos



(* ---- parse_fixbag helpers (was parse_fixbag.ml) ---- *)
let fixbag_tlist=[]

let fixbag_get_var var =
  if String.contains_from var 0 '_' then
    let sv = String.sub var 1 (String.length var - 1) in
    Typeinfer.get_spec_var_ident fixbag_tlist sv Unprimed
  else if is_substr "PRI" var
  then Typeinfer.get_spec_var_ident fixbag_tlist (String.sub var 3 (String.length var - 3)) Primed
  else Typeinfer.get_spec_var_ident fixbag_tlist var Unprimed

let fixbag_is_node var = match var with
  | Var (SpecVar (_,id,_), _) -> is_substr "NOD" id || id=self
  | _ -> false

let fixbag_get_node var = match var with
  | Var (SpecVar (_,id,_), _) ->
    if id=self then id else
      String.sub id 3 (String.length id - 3)
  | _ -> report_error no_pos "Expected a pointer variable"

(* ---- parse_shape helpers (was parse_shape.ml) ---- *)
let shape_gen_conj x y = normalize 1 x y loc

let shape_parse_lbl x = match x with
  | None -> ("",-1)
  | Some (1,n) -> (!domain_name,int_of_string n)
  | Some _ -> ("",-1)
%}

%token <string> INT LIDENT UIDENT
%token NATIVEINT EOF
%token BARBAR ANDAND LESSEQ GREATEREQ NEQ ARROW
%token EQUAL LESS GREATER PLUS MINUS STAR PIPE
%token LBRACE RBRACE LBRACKET RBRACKET COMMA COLON SEMI
%token KW_TRUE KW_FORALL KW_EXISTS KW_IN KW_LABEL KW_HASVALUE KW_AUXVALUE
%token KW_SLS KW_SUMMARY KW_NEXT KW_TL KW_DATA
%token KW_INFER_SPEC KW_EXIT KW_SHAPE KW_PRE KW_POST KW_BOTH

(* start rules end with a physical EOF token: without it, the list-without-
   separator shapes make the end-of-sentence ambiguous and menhir suppresses
   the reduce-on-# actions (end-of-stream conflicts), rejecting all input *)
%start fix_expression fixbag_expression shape_expression cmd_expression
%type <Cpure.formula list> fix_expression
%type <Cpure.formula list> fixbag_expression
%type <Cformula.formula list> shape_expression
%type <string * (bool * Iformula.struc_formula option * string option)> cmd_expression

%left BARBAR
%left ANDAND
%left PLUS MINUS
%left STAR

%%

/* =============== parse_fix =============== */

fix_expression:
  | x = nonempty_list(fix_or_formula) EOF  { x }
;

fix_or_formula:
  | x = fix_or_formula BARBAR y = fix_or_formula  { mkOr x y None loc }
  | x = fix_and_formula                       { x }
;

fix_and_formula:
  | x = fix_and_formula ANDAND y = fix_and_formula  { mkAnd x y loc }
  | x = fix_formula                            { x }
;

fix_formula:
  | x = fix_exp EQUAL y = fix_exp
      { let tmp =
          if fix_is_abc x || fix_is_abc y then
            BConst (true, loc)  (* nativeint junk: old NATIVEINT rules *)
          else
            let plain () = match x, y with
              | IConst a, IConst b ->
                if a = b then BConst (true,loc) else BConst (false,loc)
              | _ -> Eq (x, y, loc)
            in
            if not !Globals.old_parse_fix then plain ()
            else match x, y with
            | IConst _, _ | _, IConst _ -> plain ()
            | _ ->
              if fix_is_node x && fix_is_node y then
                Eq (Var(fix_get_var (fix_get_node x) fix_tlist, loc),
                    Var(fix_get_var (fix_get_node y) fix_tlist, loc), loc)
              else
              if fix_is_node x && fix_is_rec_node y then
                Eq (Var(fix_get_var (fix_get_node x) fix_tlist, loc),
                    Var(fix_add_prefix (fix_get_var (fix_get_rec_node y) fix_tlist) "REC", loc), loc)
              else
              if fix_is_node y && fix_is_rec_node x then
                Eq (Var(fix_get_var (fix_get_node y) fix_tlist, loc),
                    Var(fix_add_prefix (fix_get_var (fix_get_rec_node x) fix_tlist) "REC", loc), loc)
              else
              if fix_is_rec_node x && fix_is_rec_node y then
                Eq (Var(fix_add_prefix (fix_get_var (fix_get_rec_node x) fix_tlist) "REC", loc),
                    Var(fix_add_prefix (fix_get_var (fix_get_rec_node y) fix_tlist) "REC", loc), loc)
              else plain ()
        in BForm ((tmp, None), None) }
  | x = fix_exp NEQ y = fix_exp
      { let tmp = if fix_is_abc x || fix_is_abc y then BConst (true, loc) else Neq (x, y, loc) in
        BForm ((tmp, None), None) }
  | x = fix_exp LESS y = fix_exp
      { let tmp =
          if fix_is_abc x || fix_is_abc y then BConst (true, loc)
          else
            let go k = if !Globals.old_parse_fix then k else Lt (x, y, loc) in
            go (
              if fix_is_node y && is_zero x then
                Neq (Var(fix_get_var (fix_get_node y) fix_tlist, loc), Null loc, loc)
              else if fix_is_node x && is_one y then
                Eq (Var(fix_get_var (fix_get_node x) fix_tlist, loc), Null loc, loc)
              else if is_self_var y then
                Neq (Var(fix_get_var "self" fix_tlist, loc), Null loc, loc)
              else Lt (x, y, loc))
        in BForm ((tmp, None), None) }
  | x = fix_exp GREATER y = fix_exp
      { let tmp =
          if fix_is_abc x || fix_is_abc y then BConst (true, loc)
          else
            let go k = if !Globals.old_parse_fix then k else Gt (x, y, loc) in
            go (
              if fix_is_node x && is_zero y then
                Neq (Var(fix_get_var (fix_get_node x) fix_tlist, loc), Null loc, loc)
              else if fix_is_node y && is_one x then
                Eq (Var(fix_get_var (fix_get_node y) fix_tlist, loc), Null loc, loc)
              else if is_self_var x then
                Neq (Var(fix_get_var "self" fix_tlist, loc), Null loc, loc)
              else Gt (x, y, loc))
        in BForm ((tmp, None), None) }
  | x = fix_exp LESSEQ y = fix_exp
      { let tmp =
          if fix_is_abc x || fix_is_abc y then BConst (true, loc)
          else
            let go k = if !Globals.old_parse_fix then k else Lte (x, y, loc) in
            go (
              if fix_is_node x && is_zero y then
                Eq (Var(fix_get_var (fix_get_node x) fix_tlist, loc), Null loc, loc)
              else if fix_is_node y && is_one x then
                Neq (Var(fix_get_var (fix_get_node y) fix_tlist, loc), Null loc, loc)
              else if is_self_var x then
                Eq (Var(fix_get_var "self" fix_tlist, loc), Null loc, loc)
              else Lte (x, y, loc))
        in BForm ((tmp, None), None) }
  | x = fix_exp GREATEREQ y = fix_exp
      { let tmp =
          if fix_is_abc x || fix_is_abc y then BConst (true, loc)
          else
            let go k = if !Globals.old_parse_fix then k else Gte (x, y, loc) in
            go (
              if fix_is_node y && is_zero x then
                Eq (Var(fix_get_var (fix_get_node y) fix_tlist, loc), Null loc, loc)
              else if fix_is_node x && is_one y then
                Neq (Var(fix_get_var (fix_get_node x) fix_tlist, loc), Null loc, loc)
              else if is_self_var y then
                Eq (Var(fix_get_var "self" fix_tlist, loc), Null loc, loc)
              else Gte (x, y, loc))
        in BForm ((tmp, None), None) }
;

fix_exp:
  | x = fix_exp PLUS y = fix_exp   { Add (x, y, loc) }
  | x = fix_exp MINUS y = fix_exp  { Subtract (x, y, loc) }
  | x = INT STAR y = fix_exp
      { let ni=IConst (int_of_string x, loc)
        in Mult (ni, y, loc) }
  | x = fix_specvar                { Var (x, loc) }
  | x = INT                        { IConst (int_of_string x, loc) }
  | NATIVEINT                      { Var (SpecVar(Named "abc", "abc", Unprimed),loc) }
;

fix_specvar:
  | x = LIDENT { fix_get_var x fix_tlist }
  | x = UIDENT
      { if is_substr "REC" x
        then
          fix_add_prefix (fix_get_var (String.sub x 3 (String.length x - 3)) fix_tlist) "REC"
        else fix_get_var x fix_tlist }
;

/* =============== parse_fixbag =============== */

fixbag_expression:
  | x = nonempty_list(fixbag_or_formula) EOF  { x }
;

fixbag_or_formula:
  | x = fixbag_or_formula BARBAR y = fixbag_or_formula  { mkOr x y None loc }
  | x = fixbag_formula                          { x }
  | KW_TRUE                                     { mkTrue loc }
;

fixbag_formula:
  | x = fixbag_formula ANDAND y = fixbag_formula  { mkAnd x y loc }
  | x = fixbag_pformula                  { x }
;

fixbag_pformula:
  | x = fixbag_exp LESSEQ y = fixbag_exp
      { if is_res_var x && is_zero y then
          Not (BForm ((BVar (fixbag_get_var "res", loc), None), None), None, loc)
        else if is_res_var y && is_one x then
          BForm ((BVar (fixbag_get_var "res", loc), None), None)
        else
          let tmp =
            if fixbag_is_node x && is_zero y then
              BForm((Eq (Var(fixbag_get_var (fixbag_get_node x), loc), Null loc, loc),None),None)
            else if fixbag_is_node y && is_one x then
              BForm((Neq (Var(fixbag_get_var (fixbag_get_node y), loc), Null loc, loc),None),None)
            else if is_self_var x then
              BForm((Eq (Var(fixbag_get_var "self", loc), Null loc, loc) ,None),None)
            else
              match (x,y) with
              | (Var _, Var _) -> BForm ((BagSub (x, y, loc), None), None)
              | (Bag _, Var _) -> BForm ((BagSub (x, y, loc), None), None)
              | _ -> mkTrue loc
          in tmp }
  | x = fixbag_exp GREATEREQ y = fixbag_exp
      { if is_res_var y && is_zero x then
          Not (BForm ((BVar (fixbag_get_var "res", loc), None), None), None, loc)
        else
        if is_res_var x && is_one y then
          BForm ((BVar (fixbag_get_var "res", loc), None), None)
        else
          let tmp =
            if fixbag_is_node y && is_zero x then
              BForm((Eq (Var(fixbag_get_var (fixbag_get_node y), loc), Null loc, loc),None),None)
            else
            if fixbag_is_node x && is_one y then
              BForm((Neq (Var(fixbag_get_var (fixbag_get_node x), loc), Null loc, loc),None),None)
            else
            if is_self_var y then
              BForm((Eq (Var(fixbag_get_var "self", loc), Null loc, loc),None),None)
            else
              match (x,y) with
              | (Var _, Var _) -> BForm ((BagSub (y, x, loc), None), None)
              | (Var _, Bag _) -> BForm ((BagSub (y, x, loc), None), None)
              | _ -> mkTrue loc
          in tmp }
  | x = fixbag_exp EQUAL y = fixbag_exp
      { match (x,y) with
        | (FConst _, _) -> mkTrue loc
        | (_, FConst _) -> mkTrue loc
        | _ -> BForm ((Eq (x, y, loc), None), None) }
  | x = fixbag_exp NEQ y = fixbag_exp
      { BForm ((Neq (x, y, loc), None), None) }
  | KW_FORALL x = fixbag_exp KW_IN y = fixbag_exp COLON z = fixbag_pformula
      { match (x,z) with
        | (Var (v1,_), BForm ((Neq(Var(v2,_),Var(v3,_),_),_),_)) ->
          let res =
            if eq_spec_var v1 v2 then BagNotIn (v3,y,loc) else
            if eq_spec_var v1 v3 then BagNotIn (v2,y,loc) else BConst(true,loc)
          in BForm ((res,None),None)
        | (Var (v1,_), BForm ((Eq(Var(v2,_),Var(v3,_),_),_),_)) ->
          if eq_spec_var v1 v2 then mkForall [v1]
              (mkOr (BForm ((BagNotIn (v1,y,loc),None),None))
                 (BForm ((Eq (Var (v1,loc),Var (v3,loc),loc),None),None)) None loc) None loc else
          if eq_spec_var v1 v3 then mkForall [v1]
              (mkOr (BForm ((BagNotIn (v1,y,loc),None),None))
                 (BForm ((Eq (Var (v1,loc),Var (v2,loc),loc),None),None)) None loc) None loc else mkTrue loc
        | _ -> mkTrue loc }
  | KW_EXISTS x = fixbag_exp KW_IN y = fixbag_exp COLON z = fixbag_pformula
      { let res =
          match (x,z) with
          | (Var (v1,_), BForm ((Eq(Var(v2,_),Var(v3,_),_),_),_)) ->
            if eq_spec_var v1 v2 then BagIn (v3,y,loc) else
            if eq_spec_var v1 v3 then BagIn (v2,y,loc) else BConst(true,loc)
          | _ -> BConst(true,loc)
        in BForm ((res,None),None) }
;

fixbag_exp:
  | x = fixbag_exp PLUS y = fixbag_exp  { BagUnion([x; y], loc) }
  | x = fixbag_specvar                  { Var (x,loc) }
  | PIPE x = fixbag_specvar PIPE        { FConst (0.0,loc) }
  | LBRACE RBRACE                       { Bag ([], loc) }
  | LBRACE x = ne_fixbag_bag_items RBRACE { Bag (x, loc) }
  | x = INT                             { IConst (int_of_string x, loc) }
;

ne_fixbag_bag_items:
  | x = fixbag_exp { [x] }
  | x = fixbag_exp COMMA xs = ne_fixbag_bag_items { x :: xs }
;

fixbag_specvar:
  | x = UIDENT { fixbag_get_var x }
  | x = LIDENT { fixbag_get_var x }
;

/* =============== parse_shape =============== */

shape_expression:
  | x = nonempty_list(shape_summaries) EOF  { x }
;

shape_summaries:
  | KW_SUMMARY x = shape_summary  { x }
;

shape_summary:
  | x = list(shape_fml)  { List.fold_left shape_gen_conj (formula_of_heap HEmp loc) x }
;

shape_fml:
  | LBRACE x = shape_pred RBRACE SEMI  { x }
  | x = shape_ptr LBRACKET KW_LABEL EQUAL y = shape_ptr RBRACKET SEMI
      { formula_of_pure_formula (mkEqVar x y loc) loc }
  | x = shape_ptr ARROW y = shape_ptr LBRACKET shape_lbl RBRACKET SEMI
      { formula_of_pure_formula (mkEqVar x y loc) loc }
;

shape_pred:
  | x = shape_lbl SEMI y = shape_preddef nonempty_list(shape_preddef)
      { let typ,size = shape_parse_lbl x in
        let heap = mkViewNode y typ [] loc in
        let pure = match size with
          | 1 -> mkNeqVar y Cpure.SV.zero loc
          | _ -> mkTrue loc
        in
        normalize_combine_heap (formula_of_pure_formula pure loc) heap }
;

shape_preddef:
  | x = shape_ptr LBRACKET KW_LABEL EQUAL shape_ptr RBRACKET SEMI  { x }
  | x = shape_ptr ARROW shape_ptr LBRACKET shape_lbl RBRACKET SEMI  { x }
;

shape_ptr:
  | x = shape_id  { SpecVar (Named "GenNode", x, Unprimed) }
;

shape_lbl:
  | KW_LABEL EQUAL KW_HASVALUE  { None }
  | KW_LABEL EQUAL KW_AUXVALUE  { None }
  | KW_LABEL EQUAL KW_SLS size = INT PLUS  { Some(1,size) }
  | KW_LABEL EQUAL LBRACKET PLUS INT RBRACKET  { None }
;

shape_id:
  | x = INT      { x }
  | x = LIDENT   { x }
  | x = UIDENT   { x }
  | KW_NEXT x = INT  { x }
  | KW_TL x = INT    { x }
  | KW_DATA x = INT  { x }
;

/* =============== parse_cmd (hip REPL commands) =============== */

cmd_expression:
  | KW_INFER_SPEC x = cmd_id LBRACKET cmd = cmd_cmd RBRACKET EOF  { (x, cmd) }
  | KW_EXIT EOF  { ("", (false, None, None)) }
;

cmd_cmd:
  | LESS x = cmd_id COMMA KW_SHAPE GREATER  { (true, None, Some x) }
  | transpec = cmd_opt_transpec postx = cmd_infer_xpost
      { (false, Some (Iformula.mkEInfer postx transpec loc), None) }
;

cmd_infer_xpost:
  | KW_PRE   { Some false }
  | KW_POST  { Some true }
  | KW_BOTH  { None }
;

cmd_opt_transpec:
  | t = option(cmd_transpec)  { match t with Some v -> v | None -> None }
;

cmd_transpec:
  | old_view_name = cmd_id ARROW new_view_name = cmd_id COMMA
      { Some (old_view_name, new_view_name) }
;

cmd_id:
  | x = LIDENT  { x }
  | x = UIDENT  { x }
;
