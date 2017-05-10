{
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
      local n is node_exec["make"](data).
      local m_ap_time is time:seconds + nextnode:eta + (nextnode:orbit:period / 2).
      local trgt_pos is m["geo_pos_at"](m_ap_time,p["LND"]["LatLng"]:position):altitudeposition(1000). local ship_pos is positionat(ship, m_ap_time).
      local dist to mg["gaussian"]((trgt_pos - ship_pos):mag, 10000, abs(trgt:orbit:semimajoraxis - ship:orbit:semimajoraxis) / 2).
      return dist.
    }
    return fitness_fn@.
  }
  export(fitness).
}
