{
  local m is import("lib/math_gaussian.ks").
  local fitness is lex(
    "trans_fit",trans_fit@,"cor_fit",cor_fit@, "cor_per_fit", cor_per_fit@
  ).
  function trans_fit {
    parameter tb, ti, tp.
    function fitness_fn {
      parameter data.
      local n is make_node(data).
      if not t_to(n, tb) return -2^64.
      return m["gaussian2"](
        n:orbit:nextpatch:inclination, ti, 180,
        n:orbit:nextpatch:periapsis, tp, tb:soiradius/2
      ).
    }
    return fitness_fn@.
  }
  function cor_fit {
    parameter ct, tb, ti, tp.
    function fitness_fn {
      parameter data.
      local n is make_node(list(ct,data[0],data[1],data[2])).
      if not t_to(n, tb) return -2^64.
      return m["gaussian2"](
        n:orbit:nextpatch:inclination, ti, 180,
        n:orbit:nextpatch:periapsis, tp, tb:soiradius/2
      ).
    }
    return fitness_fn@.
  }
  function cor_per_fit {
    parameter ct, tb, tp.
    function fitness_fn {
      parameter data.
      local n is make_node(list(ct,data[0],data[1],data[2])).
      if not t_to(n, tb) return -2^64.
      return m["gaussian"](n:orbit:nextpatch:periapsis, tp, 2^32).
    }
    return fitness_fn@.
  }
  function t_to {parameter m, tb. return (m:orbit:hasnextpatch and m:orbit:nextpatch:body = tb).}
  function make_node {
    parameter d is list(0,0,0,0).
    remove_any_nodes(). wait 0.
    local n to node(d[0], d[1], d[2], d[3]). wait 0. add n. return n.
  }
  function remove_any_nodes {until not hasnode {remove nextnode. wait 0.01.}}
  export(fitness).
}
