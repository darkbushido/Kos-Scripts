function hohmann_transfer {
  parameter m, p.
  LOCAL time_to_burn to 0.
  LOCAL deltaV to 0.
  LOCAL trgt to ship.
  set talt to BODY:ATM:HEIGHT + 10000.
  if p:haskey("Altitude")
    set talt to p["Altitude"].
  if p:haskey("Body") {
    set trgt to true.
    set trgt to p["Body"].
    set r2 to (trgt:OBT:SEMIMAJORAXIS -trgt:RADIUS -target_alt).
  } else if p:haskey("Vessal") {
    set trgt to true.
    set trgt to p["Vessal"].
    set talt to trgt:OBT:SEMIMAJORAXIS - trgt:BODY:RADIUS.
    set r2 to trgt:OBT:SEMIMAJORAXIS.
  } else {
    set r2 TO talt + SHIP:OBT:BODY:RADIUS.
  }
  set Offset to 0.
  if p:haskey("Offset")
    set Offset to p["Offset"].
  local r1 to SHIP:OBT:SEMIMAJORAXIS.
  if defined trgt {
    set tt to constant():pi * sqrt((((r1 + r2)^3)/(8*ship:BODY:MU))).
    set pa to (180*(1-(sqrt(((r1 + r2)/(2*r2))^3)))).
    set aa to mod(360 + (trgt:LONGITUDE + Offset) - SHIP:LONGITUDE,360) .
    set da to (mod(360 + aa - pa,360)).
    set sa to  360/SHIP:OBT:PERIOD.
    set tgta to  360/trgt:OBT:PERIOD.
    set d_ang to ship_ang - tgt_ang.
    set d_time to d_angle/d_ang.
  } else {
    set d_time to eta:apoapsis.
  }
  local my_dV to sqrt (ship:BODY:MU/r1) * (sqrt((2* r2)/(r1 + r2)) - 1).
  local nn TO NODE(time:seconds+d_time, 0, 0, my_dV).
  ADD nn.
  lock steering to nn:DELTAV.
  mission["next"]().
}
