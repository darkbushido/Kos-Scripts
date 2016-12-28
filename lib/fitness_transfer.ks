{
  local fitness is lex(
    "trans_fit",transfer_fit@,"cor_fit",correction_fit@
  ).
  function transfer_fit {
    parameter tb, target_inc, target_periapsis.
    function fitness_fn {
      parameter data.
      local maneuver is make_node(data). remove_any_nodes().
      add maneuver. wait 0.01.
      if not t_to(maneuver, tb) return -2^64.
      return gaussian2(
        maneuver:orbit:nextpatch:inclination, target_inc, 360,
        maneuver:orbit:nextpatch:periapsis, target_periapsis, tb:soiradius
      ).
    }
    return fitness_fn@.
  }
  function correction_fit {
    parameter ct, tb, target_inc, target_periapsis.
    function fitness_fn {
      parameter data.
      if data = 0 return -2^64.
      local maneuver is make_node(list(ct,0,0,data[0])).
      local fitness is 0.
      remove_any_nodes().
      add maneuver. wait 0.01.
      if not t_to(maneuver, tb) return -2^64.
      return gaussian( maneuver:orbit:nextpatch:periapsis, target_periapsis, tb:soiradius ).
    }
    return fitness_fn@.
  }
  function gaussian {
    parameter v, t, w.
    return constant:e^(-1 * (v-t)^2 / (2*w^2)).
  }
  function gaussian2 {
    parameter v1, t1, w1, v2, t2, w2.
    return constant:e^(-1 * ((v1-t1)^2 / (2*w1^2) + (v2-t2)^2 / (2*w2^2))).
  }
  function t_to {parameter m, tb. return (m:orbit:hasnextpatch and m:orbit:nextpatch:body = tb).}
  function make_node {parameter data. return node(data[0], data[1], data[2], data[3]).}
  function remove_any_nodes {until not hasnode {remove nextnode. wait 0.01.}}
  export(fitness).
}
