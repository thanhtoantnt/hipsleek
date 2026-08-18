(* Infer-style debug helpers: real functions, no cppo.
   Call-site file:line is not stamped (pass __LOC__ if you need it). *)

let x_add f x y = f x y
let x_add_1 f x = f x
let x_add_0 f = f
let x_add_3 f a b c = f a b c

let x_binfo_hp = Debug.binfo_hprint
let x_binfo_pp = Debug.binfo_pprint
let x_binfo_zp = Debug.binfo_zprint
let x_tinfo_hp = Debug.tinfo_hprint
let x_tinfo_pp = Debug.tinfo_pprint
let x_tinfo_zp = Debug.tinfo_zprint
let x_dinfo_hp = Debug.dinfo_hprint
let x_dinfo_pp = Debug.dinfo_pprint
let x_dinfo_zp = Debug.dinfo_zprint
let x_winfo_pp = Debug.winfo_pprint
let x_winfo_hp = Debug.binfo_hprint
let x_winfo_zp = Debug.binfo_zprint
let x_info_hp = Debug.binfo_hprint
let x_info_pp = Debug.binfo_pprint
let x_info_zp = Debug.binfo_zprint
let n_binfo_hp = Debug.binfo_hprint
let n_binfo_pp = Debug.binfo_pprint
let n_binfo_zp = Debug.binfo_zprint

let x_ninfo_hp _ _ _ = ()
let x_ninfo_pp _ _ = ()
let x_ninfo_zp _ _ = ()

let y_info_hp = Debug.y_binfo_hprint
let y_info_pp = Debug.y_binfo_pprint
let y_binfo_hp = Debug.y_binfo_hprint
let y_binfo_pp = Debug.y_binfo_pprint
let y_binfo_zp = Debug.y_binfo_zprint
let y_tinfo_hp = Debug.y_tinfo_hprint
let y_tinfo_pp = Debug.y_tinfo_pprint
let y_tinfo_zp = Debug.y_tinfo_zprint
let y_dinfo_hp = Debug.y_dinfo_hprint
let y_dinfo_pp = Debug.y_dinfo_pprint
let y_dinfo_zp = Debug.y_dinfo_zprint
let y_winfo_pp = Debug.y_winfo_pprint
let y_winfo_hp = Debug.y_binfo_hprint
let y_winfo_zp = Debug.y_binfo_zprint
let y_ninfo_hp _ _ = ()
let y_ninfo_pp _ = ()
let y_ninfo_zp _ = ()

let y_bres_hp f r = Debug.y_binfo_hprint f r; r
let y_tres_hp f r = Debug.y_tinfo_hprint f r; r

let x_report_error _ s = failwith s
let x_todo s = Debug.y_binfo_pprint ("TODO: " ^ s)
let x_nodo s = Debug.y_tinfo_pprint ("TODO: " ^ s)
let x_warn s = Debug.y_binfo_pprint ("WARNING: " ^ s)
let x_fail s = failwith s
