{
  local fitness is lex(
    "periapsis_fit", periapsis_fit@,
    "correction_fit", correction_fit@
  ).
  function periapsis_fit {
    parameter target_body, target_periapsis.
    function fitness_fn {
      parameter data.
      local maneuver is make_node(data).
      remove_any_nodes().
      add maneuver. wait 0.01.
      if not t_to(maneuver, target_body) return -2^64.
      return -abs(maneuver:orbit:nextpatch:periapsis - target_periapsis).
    }
    return fitness_fn@.
  }
  function correction_fit {
    parameter ct, target_body, target_periapsis.
    function fitness_fn {
      parameter data.
      if data = 0
        return -2^64.
      local maneuver is make_node(list(ct,0,0,data[0])).
      local fitness is 0.
      remove_any_nodes().
      add maneuver. wait 0.01.
      if maneuver:orbit:hasnextpatch and (maneuver:orbit:nextpatch:body = target_body)
        return -abs(maneuver:orbit:nextpatch:periapsis - target_periapsis).
      else return -2^64.
    }
    return fitness_fn@.
  }
  function closest_approach {
    parameter tb, st, et.
    local ss is slope_at(tb, st).
    local es is slope_at(tb, et).
    local mt is (st + et) / 2.
    local ms is slope_at(tb, mt).
    until (et - st < 0.1) or ms < 0.1 {
      if (ms * ss) > 0 set st to mt.
      else set et to mt.
      set mt to (st + et) / 2.
      set ms to slope_at(tb, mt).
    }
    return sep_at(tb, mt).
  }
  function slope_at {parameter tb, at_t. return (sep_at(tb, at_t + 1) - sep_at(tb, at_t - 1)) / 2.}
  function sep_at {parameter tb, at_t. return (positionat(ship, at_t) - positionat(tb, at_t)):mag.}
  function t_to {parameter m, tb. return (m:orbit:hasnextpatch and m:orbit:nextpatch:body = tb).}
  function make_node {parameter maneuver. return node(maneuver[0], maneuver[1], maneuver[2], maneuver[3]).}
  function remove_any_nodes {until not hasnode {remove nextnode. wait 0.01.}}
  export(fitness).
}
