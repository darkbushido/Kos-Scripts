function circularization {
  parameter mission, params.
  if HASNODE {
    execute_node_raw(mission, params).
  } else if ship:obt:SEMIMAJORAXIS > 70000 and ship:obt:ECCENTRICITY < 0.001 {
    mission["next"]().
  } else if ship:obt:SEMIMAJORAXIS > 50000 and ship:obt:ECCENTRICITY < 0.005 {
    mission["next"]().
  } else {
    if NOT params:HASKEY("Mode")
      params:ADD("Mode", "apoapsis").
    LOCAL co TO ship:orbit.
    LOCAL cobr to co:body:radius.
    if params["Mode"] = "apoapsis" {
      set cot to co:apoapsis.
      set ttb to ETA:APOAPSIS.
    } else if params["Mode"] = "pariapsis" {
      set cot to co:periapsis.
      set ttb to ETA:PERIAPSIS.
    }
    LOCAL cotcobr to (cot + cobr).
    LOCAL deltaV to 0.
    LOCAL vat TO sqrt(co:body:mu * (2 / cotcobr - 1 / (co:semimajoraxis))).
    LOCAL cv TO sqrt(co:body:mu * (1 / cotcobr)).
    ADD NODE(TIME:SECONDS + ttb, 0, 0, cv - vat).
  }
}
