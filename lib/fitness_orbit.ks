{
  local node_exec is import("lib/node_exec.ks").
  local fitness is lex(
    "transfer_fit", transfer_fit@
  ).
  function transfer_fit {
    parameter t, target_alt, a is true.
    function fitness_fn {
      parameter d. local n is node_exec["make"](list(t,0,0,d[0])).
      if a
        return -abs(n:orbit:apoapsis - target_alt).
      else
        return -abs(n:orbit:periapsis - target_alt).
    }
    return fitness_fn@.
  }
  export(fitness).
}
