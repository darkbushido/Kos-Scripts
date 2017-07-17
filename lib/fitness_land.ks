{
  local mg is import("lib/math_gaussian.ks").
  local m is import("lib/math.ks").
  local cn is import("lib/circle_nav.ks").
  local node_exec is import("lib/node_exec.ks").
  local fitness is lex("atmo_impact_fit", atmo_impact_fit@, "deorbit_fit", deorbit_fit@).

  function atmo_impact_fit {
    parameter geo, deltaV.
    function fitness_fn {
      parameter data.
      node_exec["clean"]().
      node_exec["make"](list(data[0],0,0,deltaV)).
      local wait_t to TIME:seconds + 5.
      wait until TIME:seconds > wait_t OR addons:tr:hasImpact.
      if addons:tr:hasImpact {
        local dist to round(cn["distance"](addons:tr:impactpos, geo, ship:body:radius),2).
        return -dist.
        // return mg["gaussian"](dist, 0, (2 * constant():PI * ship:body:radius)).
      } else { return -2^64. }
    }
    return fitness_fn@.
  }
  function deorbit_fit {
    parameter geo.
    function fitness_fn {
      parameter data.
      node_exec["clean"]().
      node_exec["make"](data).
      local m_ap_time is time:seconds + nextnode:eta + (nextnode:orbit:period / 2).
      local trgt_pos is m["geo_pos_at"](m_ap_time,geo:altitudeposition(1000)).
      local ship_pos is positionat(ship, m_ap_time).
      return mg["gaussian"]((trgt_pos - ship_pos):mag, 0, 10000).
    }
    return fitness_fn@.
  }
  export(fitness).
}
