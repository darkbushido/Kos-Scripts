{
  local fitness is lex(
    "deorbit_fit", deorbit_fit@
  ).
  function deorbit_fit {
    parameter target_latlng.
    function fitness_fn {
      parameter data.
      local maneuver is make_node(list(data[0],data[1],data[2],data[3])).
      remove_any_nodes().
      add maneuver. wait 0.5.
      if not addons:tr:hasimpact { return -2^64. }
      return round(gaussian2(
        circle_distance(target_latlng, addons:tr:impactpos, ship:body:radius),0,ship:body:radius,
        maneuver:deltav:mag, ship:velocity:surface:mag/20, ship:velocity:surface:mag),4).
    }
    return fitness_fn@.
  }
  function make_node {
    parameter d.
    return node(d[0], d[1], d[2], d[3]).
  }
  function circle_distance {
    parameter p1, p2, radius.
    local A is sin((p1:lat-p2:lat)/2)^2 + cos(p1:lat)*cos(p2:lat)*sin((p1:lng-p2:lng)/2)^2.
    return radius*constant():PI*arctan2(sqrt(A),sqrt(1-A))/90.
  }
  function gaussian2 {
    parameter v1, t1, w1, v2, t2, w2.
    return constant:e^(-1 * ((v1-t1)^2 / (2*w1^2) + (v2-t2)^2 / (2*w2^2))).
  }
  function remove_any_nodes {until not hasnode {remove nextnode. wait 0.01.}}
  export(fitness).
}
