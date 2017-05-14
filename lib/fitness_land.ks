{
  local p is import("lib/params.ks").
  local cn is import("lib/circle_nav.ks").
  local mg is import("lib/math_gaussian.ks").
  local m is import("lib/math.ks").
  local node_exec is import("lib/node_exec.ks").
  local fitness is lex(
    "deorbit_fit", deorbit_fit@
  ).
  function deorbit_fit {
    parameter geo.
    function fitness_fn {
      parameter data.
      local n is node_exec["make"](list(data[0],0,0,data[1])).
      local m_ap_time is time:seconds + nextnode:eta + (nextnode:orbit:period / 2).
      local trgt_pos is m["geo_pos_at"](m_ap_time,p["LND"]["LatLng"]):altitudeposition(1000).
      local ship_pos is positionat(ship, m_ap_time).
      local dist to mg["gaussian"]((trgt_pos - ship_pos):mag, 0, 10000).
      return dist.
    }
    return fitness_fn@.
  }
  export(fitness).
}
