(* Mutable fixcalc-parsing state, shared between the fixparser grammar
   actions and the Parse_fix wrapper API. Was module-level state in the
   old parse_fix.ml. *)
open Hipsleek_common
open VarGen
open Cpure
open Globals
open Gen

class ['a] fix_type_stack_pr (epr:'a->string) (eq:'a->'a->bool) =
  object (self)
    inherit ['a] stack_pr "type_stack_pr" epr eq as super
    method get_spec_var_ident var p =
      let same_sv sv =
        match sv,p with
        | SpecVar (_,id,Primed),Primed
        | SpecVar (_,id,Unprimed),Unprimed -> id=var
        | _ -> false
      in
      try
        super # find same_sv
      with
        Not_found->
        Cpure.SpecVar (UNK,var,p)
  end

let fix_tlist = new fix_type_stack_pr string_of_spec_var eq_spec_var

let fix_get_var var tl =
  if is_substr "PRI" var
  then
    let var = String.sub var 3 (String.length var - 3) in
    tl # get_spec_var_ident var Primed
  else tl # get_spec_var_ident var Unprimed

let fix_add_prefix var prefix = match var with
  | SpecVar (t,id,p) -> SpecVar (t,prefix ^ id,p)

let fix_is_node var = match var with
  | Var (SpecVar (_,id,_), _) -> id=self
  | _ -> false

let fix_get_node var = match var with
  | Var (SpecVar (_,id,_), _) ->
    if id=self then id else
      String.sub id 3 (String.length id - 3)
  | _ -> report_error no_pos "Expected a pointer variable"

let fix_is_rec_node _ = false

(* the dummy var NATIVEINT tokens parse into (see fix_exp -> NATIVEINT) *)
let fix_is_abc e = match e with
  | Var (SpecVar (Named "abc", _, _), _) -> true
  | _ -> false

let fix_get_rec_node var = match var with
  | Var (SpecVar (_,id,_), _) -> String.sub id 6 (String.length id - 6)
  | _ -> report_error no_pos "Expected a recursive pointer variable"

let fix_get_type_list_for_fixcalc_output (f:Cpure.formula) =
  let f = Trans_arr.translate_array_one_formula f in
  let rec helper_e e =
    match e with
    | Add (e1,e2,loc)
    | Subtract (e1,e2,loc)
    | Mult (e1,e2,loc)
    | Div (e1,e2,loc)->
      (helper_e e1) @ (helper_e e2)
    | Var (sv,_)->
      [sv]
    | _ -> []
  in
  let helper_b (p,ba) =
    match p with
    | BConst _
    | BVar _
    | Frm _
    | XPure _
    | LexVar _
    | RelForm _ ->
      []
    | Lt (e1,e2,loc)
    | Lte (e1,e2,loc)
    | Gt (e1,e2,loc)
    | Gte (e1,e2,loc)
    | Eq (e1,e2,loc)
    | Neq (e1,e2,loc) ->
      (helper_e e1) @ (helper_e e2)
    | _ ->
      []
  in
  let rec helper f =
    match f with
    | BForm (b,fl)->
      helper_b b
    | And (f1,f2,_)
    | Or (f1,f2,_,_)->
      (helper f1)@(helper f2)
    | AndList lst->
      failwith "get_type_list_for_fixcalc_output: AndList To Be Implemented, can use [] as default"
    | Not (nf,_,_)
    | Forall (_,nf,_,_)
    | Exists (_,nf,_,_)->
      helper nf
  in
  helper f

let fix_initialize_tlist_from_fpairlist fpairlst =
  fix_tlist # push_list ( List.fold_left (fun r (f1,f2,_) -> r@(fix_get_type_list_for_fixcalc_output f1)@(fix_get_type_list_for_fixcalc_output f2)) []  fpairlst)
