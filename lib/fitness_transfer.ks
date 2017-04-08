{
  local mg is import("lib/math_gaussian.ks").
  local node_exec is import("lib/node_exec.ks").
  local fitness is lex(
    "rndvz_fit", rndvz_fit@, "trans_fit",trans_fit@,
    "cor_fit",cor_fit@, "cor_per_fit", cor_per_fit@
  ).
  function rndvz_fit {
    parameter trgt.
    function fitness_fn {
      parameter data.
      local n is node_exec["make"](data). node_exec["clean"](). add n. wait 0. local n is nextnode.
      local m_ap_time is time:seconds + nextnode:eta + (nextnode:orbit:period / 2).
      local trgt_pos is positionat(trgt, m_ap_time).local ship_pos is positionat(ship, m_ap_time).
      local dist to mg["gaussian"]((trgt_pos - ship_pos):mag, 500, abs(trgt:orbit:semimajoraxis - ship:orbit:semimajoraxis) / 2).
      return dist.
    }
    return fitness_fn@.
  }
  function trans_fit {
    parameter tb, ti, tp.
    function fitness_fn {
      parameter data.
      local n is node_exec["make"](data).
      if not t_to(n, tb) return 0.
      return mg["gaussian2"](
        n:orbit:nextpatch:inclination, ti, 180,
        n:orbit:nextpatch:periapsis, tp, tb:soiradius/2
      ).
    }
    return fitness_fn@.
  }
  function cor_fit {
    parameter ct, tb, ti, tp.
    function fitness_fn {
      parameter data.
      local n is node_exec["make"](list(ct,data[0],data[1],data[2])).
      if not t_to(n, tb) return 0.
      return mg["gaussian2"](
        n:orbit:nextpatch:inclination, ti, 180,
        n:orbit:nextpatch:periapsis, tp, tb:soiradius/2
      ).
    }
    return fitness_fn@.
  }
  function cor_per_fit {
    parameter ct, tb, tp.
    function fitness_fn {
      parameter data.
      local n is node_exec["make"](list(ct,data[0],data[1],data[2])).
      if not t_to(n, tb) return 0.
      return mg["gaussian"](n:orbit:nextpatch:periapsis, tp, tb:soiradius/2).
    }
    return fitness_fn@.
  }
  function t_to {parameter m, tb. return (m:orbit:hasnextpatch and m:orbit:nextpatch:body = tb).}
  export(fitness).
}
