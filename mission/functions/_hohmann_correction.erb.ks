function hohmann_correction {
  set ct to time:seconds + (eta:transition * 0.7).
  local data is list(0).
  print "Correction Inclination Fitness".
  set data to hc["seek"](data, fit["c_inc_fit"](ct, p["Body"], ti), 1).
  set data to hc["seek"](data, fit["c_inc_fit"](ct, p["Body"], ti), 0.1).
  print "Correction Periapsis fit".
  set data to hc["seek"](data, fit["c_per_fit"](ct, p["Body"], p["DAlt"]), 1).
  set data to hc["seek"](data, fit["c_per_fit"](ct, p["Body"], p["DAlt"]), 0.1).
  local nn to nextnode.
  if nn:deltav:mag < 0.1 remove nn.
  next().
}
