require import Int.

module M = {
  fun f(x : int, y : int) : int = {
    var r : int = x + y;
    return r;
  }

  fun g(a : int) : int = {
    var z : int;

    z := f(a, a);
    return z;
  }
}.

lemma e : equiv[M.g ~ M.g : a{1} = a{2} ==> res{1} = res{2}].
proof.
  fun.
  inline {1} M.f.
  inline {2} M.f.
  wp; skip; trivial.
save.
