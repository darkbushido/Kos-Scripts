function hohmann_transfer {
  local r1 to SHIP:OBT:SEMIMAJORAXIS.
  local r2 TO p["Body"]:obt:semimajoraxis.
  set d_time to hohmann["time"](r1,r2, p["Body"]).
  hohmann["transfer"](r1,r2,d_time).
  local nn to nextnode.
  local data to list(time:seconds + nn:eta, nn:radialout, nn:normal, nn:prograde).
  print "Inclination Fitness : " + ti.
  set data to hc["seek"](data, fit["inc_fit"](p["Body"], ti), 1).
  set data to hc["seek"](data, fit["inc_fit"](p["Body"], ti), 0.1).
  print "Periapsis fit".
  set data to hc["seek"](data, fit["per_fit"](p["Body"], p["DAlt"]), 0.1).
  node_exec["exec"](true).
  next().
}
