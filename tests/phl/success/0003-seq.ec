module M = {
  var y : int
  proc f(x:int) : int = {
    y = x;
    y = 1;
    return y;
  }
}.

lemma foo : hoare [M.f : true ==> res = 1 /\ M.y = 1 ].
proof.
 proc.
 seq 1 : (M.y = x).
 admit.
 admit.
qed.