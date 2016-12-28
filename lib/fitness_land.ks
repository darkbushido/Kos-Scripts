{
  local cn is import("lib/circle_nav.ks").
  local fitness is lex(
    "deorbit_fit", deorbit_fit@
  ).
  function deorbit_fit {
    parameter target_latlng.
    function fitness_fn {
      parameter data.
      local maneuver is make_node(list(data[0],data[1],data[2],data[3])).
      remove_any_nodes().
      add maneuver. wait 0.1.
      if not addons:tr:hasimpact { return -2^64. }
      local deltav to -SHIP:VELOCITY:SURFACE:MAG/2.
      if BODY:ATM:EXISTS { set deltav to -SHIP:VELOCITY:SURFACE:MAG/20.}
      return round(gaussian2(
        cn["distance"](target_latlng, addons:tr:impactpos, ship:body:radius),0,ship:body:radius,
        maneuver:deltav:mag, deltav, 2*ship:velocity:surface:mag),4).
    }
    return fitness_fn@.
  }
  function make_node { parameter d. return node(d[0], d[1], d[2], d[3]). }
  function gaussian2 {
    parameter v1, t1, w1, v2, t2, w2.
    return constant:e^(-1 * ((v1-t1)^2 / (2*w1^2) + (v2-t2)^2 / (2*w2^2))).
  }
  function remove_any_nodes {until not hasnode {remove nextnode. wait 0.01.}}
  export(fitness).
}
