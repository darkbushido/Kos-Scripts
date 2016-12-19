{
  local fitness is lex(
    "deorbit_fit", deorbit_fit@,
    "land_at_fit", land_at_fit@
  ).
  function deorbit_fit {
    parameter target_latlng, deltav.
    function fitness_fn {
      parameter data.
      local maneuver is make_node(list(data[0],0,0,deltav)).
      remove_any_nodes().
      add maneuver. wait 1.
      if not addons:tr:hasimpact { return -2^64. }
      return -abs(circle_distance(target_latlng, addons:tr:impactpos, ship:body:radius)).
    }
    return fitness_fn@.
  }
  function land_at_fit {
    parameter t, target_latlng.
    function fitness_fn {
      parameter data.
      local maneuver is make_node(list(t,0,0,data[0])).
      remove_any_nodes().
      add maneuver. wait 0.1.
      return -abs(circle_distance(target_latlng, addons:tr:impactpos, ship:body:radius)).
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
  function remove_any_nodes {until not hasnode {remove nextnode. wait 0.01.}}
  export(fitness).
}
