import why3 "bool" "Bool"
  op "xorb" as "^^".

lemma xorb_spec : forall b1 b2, b1 ^^ b2 <=> b1 = !b2
by [].

op xorb : bool -> bool -> bool = (^^).

lemma xorb_associative : forall b1 b2 b3, (b1 ^^ b2) ^^ b3 = b1 ^^ (b2 ^^ b3)
by [].

require import Real. 
require import Distr.

(** Uniform distribution on booleans *)
theory Dbool.

  op dbool : bool distr.

  axiom mu_def : forall (p:bool cPred), 
    mu dbool p = (1%r / 2%r) * charfun p true + (1%r / 2%r) * charfun p false.
 
  lemma supp_def : forall (b:bool), in_supp b dbool.
  proof.
    intros b; delta in_supp mu_x beta.
    rewrite (mu_def (cPeq b)).
    delta; simplify; trivial.
  qed.
  
  lemma mu_x_def : forall (b:bool), mu_x dbool b = 1%r / 2%r.
  proof.
    intros b.
    delta mu_x; simplify.
    rewrite (mu_def (cPeq b)).
    delta; simplify; trivial.
  qed.

  lemma lossless : weight dbool = 1%r by [].

end Dbool.
