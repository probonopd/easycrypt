(* -------------------------------------------------------------------- *)
open EcUtils
open EcTypes
open EcTypesmod
open EcDecl
open EcParsetree

module NameGen = EcUidgen.NameGen

(* -------------------------------------------------------------------- *)
let (~$) = format_of_string

(* -------------------------------------------------------------------- *)
let err pp_elt x =
  Format.fprintf Format.err_formatter "%a" pp_elt x

(* -------------------------------------------------------------------- *)
let pp_located loc pp_elt fmt x =
  Format.fprintf fmt "%s: %a" (Location.tostring loc) pp_elt x

(* -------------------------------------------------------------------- *)
let pp_id pp_elt fmt x =
  Format.fprintf fmt "%a" pp_elt x

(* -------------------------------------------------------------------- *)
let pp_paren pp_elt fmt x =
  Format.fprintf fmt "(%a)" pp_elt x

(* --------------------------------------------------------------------  *)
let pp_opt_pre  () = format_of_string ""
let pp_opt_post () = format_of_string ""

let pp_option
    ?(pre=pp_opt_pre ())
    ?(post=pp_opt_post ()) pp_elt fmt x =

  oiter x
    (fun x ->
      Format.fprintf fmt "%(%)%a%(%)" pre pp_elt x post)

(* -------------------------------------------------------------------- *)
let pp_list_pre  () = format_of_string "@["
let pp_list_post () = format_of_string "@]"
let pp_list_sep  () = format_of_string ""

let pp_list
    ?(pre=pp_list_pre ())
    ?(sep=pp_list_sep ())
    ?(post=pp_list_post ()) pp_elt =

  let rec pp_list fmt = function
    | []      -> ()
    | x :: xs -> Format.fprintf fmt "%(%)%a%a" sep pp_elt x pp_list xs
  in
    fun fmt xs ->
      match xs with
      | []      -> ()
      | x :: xs -> Format.fprintf fmt "%(%)%a%a%(%)" pre pp_elt x pp_list xs post

(* -------------------------------------------------------------------- *)
let rec pp_qsymbol fmt = function
  | ([]    , x) -> Format.fprintf fmt "%s" x
  | (n :: p, x) -> Format.fprintf fmt "%s:>%a" n pp_qsymbol (p, x)

(* -------------------------------------------------------------------- *)
let rec pp_path fmt = function
  | EcPath.Pident x      -> Format.fprintf fmt "%s" (EcIdent.name x)
  | EcPath.Pqname (p, x) -> Format.fprintf fmt "%a:>%s" pp_path p (EcIdent.name x)

(* -------------------------------------------------------------------- *)
let pp_ident fmt id = 
  Format.fprintf fmt "%s" (EcIdent.name id)

(* -------------------------------------------------------------------- *)
let pp_path_in_env _env fmt id =       (* FIXME *)
  Format.fprintf fmt "%s" (EcIdent.name id)

(* -------------------------------------------------------------------- *)
let pp_type (uidmap : NameGen.t) =
  let rec pp_type btuple fmt = function
    | Tbase Tunit      -> Format.fprintf fmt "unit"
    | Tbase Tbool      -> Format.fprintf fmt "bool"
    | Tbase Tint       -> Format.fprintf fmt "int"
    | Tbase Treal      -> Format.fprintf fmt "real"
    | Tbase Tbitstring -> Format.fprintf fmt "bitstring"

    | Ttuple tys ->
        let pp = if btuple then pp_paren else pp_id in
          pp (pp_list ~sep:(~$"*") (pp_type true))
            fmt tys

    | Tconstr (name, tyargs) -> begin
        match tyargs with
        | []     -> Format.fprintf fmt "%a" pp_path name
        | [t]    -> Format.fprintf fmt "%a %a" (pp_type true) t pp_path name
        | tyargs -> Format.fprintf fmt "(%a) %a"
                      (pp_list ~sep:(~$", ") (pp_type false)) tyargs
                      pp_path name
    end

    | Tvar id -> (* FIXME *)
        Format.fprintf fmt "%s" (EcIdent.name id)

    | Tunivar id ->
        Format.fprintf fmt "#%s" (NameGen.get uidmap id)

  in
    pp_type

(* -------------------------------------------------------------------- *)
let pp_type ?(vmap : _ option) =
  let uidmap =
    match vmap with
    | None        -> NameGen.create ()
    | Some uidmap -> uidmap
  in
    pp_type uidmap false

(* -------------------------------------------------------------------- *)
let pp_tydecl env fmt (p, td) =
  let vmap = EcUidgen.NameGen.create () in

  let pp_params fmt = function
    | []   -> ()
    | [id] -> pp_ident fmt id
    | lid  -> Format.fprintf fmt "(%a)" (pp_list ~sep:(", ") pp_ident) lid  in

  let pp_body fmt ty =
    pp_option ~pre:" = " (pp_type ~vmap) fmt ty in

  Format.fprintf fmt "type %a%a%a."
    pp_params td.tyd_params pp_ident (EcPath.basename p) pp_body td.tyd_type

(* -------------------------------------------------------------------- *)
let pp_optyparams fmt lid = 
  match lid with
  | [] -> ()
  | _  -> Format.fprintf fmt "[%a]" (pp_list ~sep:(", ") pp_ident) lid

(* -------------------------------------------------------------------- *)
let pp_dom fmt =
  let vmap = NameGen.create () in
    function
    | []  -> Format.fprintf fmt "()"
    | [t] -> pp_type fmt t
    | lt  -> Format.fprintf fmt "(%a)" (pp_list ~sep:(", ") (pp_type ~vmap)) lt

(* -------------------------------------------------------------------- *)
let pp_opdecl fmt (p, d) =
  let vmap = EcUidgen.NameGen.create () in

  let str_kind op =
    let x = if (op_ctnt op) then "cnst" else "op" in
    let x = if op.op_prob then "p"^x else x in
      x
  in

  let pp_decl fmt d = ()
(*
    match d.op_body with
    | None ->
        if d.op_ctnt then 
          Format.fprintf fmt ": %a" (pp_type ~vmap) (snd d.op_sig)
        else 
          Format.fprintf fmt ": %a -> %a" 
            pp_tparams (fst d.op_sig) (pp_type ~vmap) (snd d.op_sig)
    | Some (id,e) ->
      if d.op_ctnt then
        Format.fprintf fmt ": %a = %a" (pp_type ~vmap) (snd d.op_sig) pp
      else
        assert false
*)
  in
    Format.fprintf fmt "%s %a%a %a."
      (str_kind d) pp_optyparams d.op_params pp_path p
      pp_decl d
