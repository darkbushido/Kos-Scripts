{
  local fitness is lex(
    "apoapsis_fit", apoapsis_fit@
  ).
  function apoapsis_fit {
    parameter t, target_apoapsis.
    function fitness_fn {
      parameter data.
      local maneuver is make_node(list(t,0,0,data[0])).
      remove_any_nodes().
      add maneuver. wait 0.01.
      return -abs(maneuver:orbit:apoapsis - target_apoapsis).
    }
    return fitness_fn@.
  }
  function make_node {parameter maneuver. return node(maneuver[0], maneuver[1], maneuver[2], maneuver[3]).}
  function remove_any_nodes {until not hasnode {remove nextnode. wait 0.01.}}
  export(fitness).
}
