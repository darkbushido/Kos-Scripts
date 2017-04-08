{
  local cn is import("lib/circle_nav.ks").
  local m is import("lib/math_gaussian.ks").
  local node_exec is import("lib/node_exec.ks").
  local fitness is lex(
    "deorbit_fit", deorbit_fit@
  ).
  function deorbit_fit {
    parameter target_latlng.
    function fitness_fn {
      parameter data.
      local n is node_exec["make"](list(data[0],data[1],data[2],data[3])).
      node_exec["clean"]().
      add n. wait 0.1.
      if not addons:tr:hasimpact { return -2^64. }
      local deltav to -SHIP:VELOCITY:SURFACE:MAG/2.
      if BODY:ATM:EXISTS { set deltav to -SHIP:VELOCITY:SURFACE:MAG/20.}
      return round(mg["gaussian2"](
        cn["distance"](target_latlng, addons:tr:impactpos, ship:body:radius),0,ship:body:radius,
        n:deltav:mag, deltav, 2*ship:velocity:surface:mag),4).
    }
    return fitness_fn@.
  }
  export(fitness).
}
