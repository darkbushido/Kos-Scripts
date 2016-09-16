{

  local fitness_functions is lex(
    "version", "0.1.0",
    "seek", seek@
  ).
  function circular_fitness {
    parameter data.
    local maneuver is node(time:seconds + eta:apoapsis, 0, 0, data[0]).
    local fitness is 0.
    add maneuver. wait 0.01.
    set fitness to -maneuver:orbit:eccentricity.
    remove_any_nodes().
    return fitness.
  }
  export(fitness).
}
