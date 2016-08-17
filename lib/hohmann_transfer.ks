function hohmann_transfer {
  parameter mission.
  parameter params.

  LOCAL time_to_burn to 0.
  LOCAL deltaV to 0.
  LOCAL target_object to ship.
  if params:haskey("Body") {
    set target_object to params["Body"].
    set r2 to (target_object:OBT:SEMIMAJORAXIS -target:RADIUS -target_alt -
      (target_object:SOIRADIUS/10) ).
  } else if params:haskey("Vessal") {
    set target_object to params["Vessal"].
    set target_alt to target_object:OBT:SEMIMAJORAXIS - target_object:BODY:RADIUS.
    set r2 to target_object:OBT:SEMIMAJORAXIS.
  } else {
    if params:haskey("Altitude") {
      set target_alt to params["Altitude"].
      set r2 TO target_alt + SHIP:OBT:BODY:RADIUS.
    }
    else {
      set target_alt to 80000.
      set r2 TO target_alt + SHIP:OBT:BODY:RADIUS.
    }
  }

  local r1 to SHIP:OBT:SEMIMAJORAXIS.

  local transfer_time to constant():pi * sqrt((((r1 + r2)^3)/(8*target_object:BODY:MU))).
  local phase_angle to (180*(1-(sqrt(((r1 + r2)/(2*r2))^3)))).
  if params:haskey("Offset")
    set Offset to params["Offset"].
  else
    set Offset to 0.
  local actual_angle to mod(360 + (target_object:LONGITUDE + Offset) - SHIP:LONGITUDE,360) .
  local d_angle to (mod(360 + actual_angle - phase_angle,360)).

  local ship_ang to  360/SHIP:OBT:PERIOD.
  local tgt_ang to  360/target_object:OBT:PERIOD.
  local d_ang to ship_ang - tgt_ang.
  if d_ang = 0
    local d_time to eta:apoapsis.
  else
    local d_time to d_angle/d_ang.

  local my_dV to sqrt (target_object:BODY:MU/r1) * (sqrt((2* r2)/(r1 + r2)) - 1).

  local my_node TO NODE(time:seconds+d_time, 0, 0, my_dV).
  ADD my_node.

  // fine tune the orbit
  if params:haskey("Body") {
    lock alt_after_mn to ORBITAT(SHIP,time+transfer_time):PERIAPSIS.
  } else {
    lock alt_after_mn to ORBITAT(SHIP,time+transfer_time):APOAPSIS.
  }

  local lock current_inclination to ORBITAT(SHIP,time+transfer_time):INCLINATION.
  // We go higher, so we can set the new orbits with small retrograde burns at pe
  print "Altitude after burn: " + alt_after_mn.
  print "Target Altitude: " + target_alt.
  until (abs(alt_after_mn - target_alt) < 100) {
    if alt_after_mn < target_alt  {
      set my_node:PROGRADE to my_node:PROGRADE + 0.01.
    } else {
      set my_node:PROGRADE to my_node:PROGRADE - 0.01.
    }
  }
  print "Node Added".
  mission["next"]().
}
