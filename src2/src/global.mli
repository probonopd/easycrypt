(* -------------------------------------------------------------------- *)
open Symbols
open Parsetree

(* -------------------------------------------------------------------- *)
module Module : sig
  type eobj = [
    | `PEVar of (symbol list * pty)
    | `PEFun of (function_decl * function_body)
  ]

  val start  : symbol -> unit
  val closed : unit   -> unit
  val abort  : unit   -> unit
  val extend : eobj   -> unit
end
