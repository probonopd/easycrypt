module type I = {
}.

lemma L : forall (M <: I), true.
proof.
 intros M;smt.
qed.
