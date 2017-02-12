{
  local node_exec is import("lib/node_exec.ks").
  local fitness is lex(
    "apo_fit", apo_fit@, "per_fit", per_fit@
  ).
  function apo_fit {
    parameter t, target_ap.
    function fitness_fn {
      parameter d. local n is make_node(list(t,0,0,d[0])). node_exec["clean"](). add n. wait 0.01.
      return -abs(n:orbit:apoapsis - target_ap).}
    return fitness_fn@.
  }
  function per_fit {
    parameter t, target_pe.
    function fitness_fn {
      parameter d. local n is make_node(list(t,0,0,d[0])). node_exec["clean"](). add n. wait 0.01.
      return -abs(n:orbit:periapsis - target_pe).}
    return fitness_fn@.
  }
  function make_node { parameter d. return node(d[0], d[1], d[2], d[3]). }
  export(fitness).
}
