module M = { 
  proc f() : unit = {}
}.

lemma foo : hoare [M.f : true ==> false].
proof.
  conseq ( _: false ==> false).
  smt.
  smt.
  admit.
qed.