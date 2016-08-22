function hohmann_transfer {
  parameter mission.
  parameter params.

  LOCAL time_to_burn to 0.
  LOCAL deltaV to 0.
  LOCAL target_object to ship.

  if params:haskey("Altitude")
    set target_alt to params["Altitude"].
  else
    set target_alt to BODY:ATM:HEIGHT + 10000.

  if params:haskey("Body") {
    set has_target_object to true.
    set target_object to params["Body"].
    set r2 to (target_object:OBT:SEMIMAJORAXIS -target_object:RADIUS -target_alt).
    //  -(target_object:SOIRADIUS/10)
  } else if params:haskey("Vessal") {
    set has_target_object to true.
    set target_object to params["Vessal"].
    set target_alt to target_object:OBT:SEMIMAJORAXIS - target_object:BODY:RADIUS.
    set r2 to target_object:OBT:SEMIMAJORAXIS.
  } else {
    set has_target_object to false.
    set r2 TO target_alt + SHIP:OBT:BODY:RADIUS.
  }
  if params:haskey("Offset")
    set Offset to params["Offset"].
  else
    set Offset to 0.

  local r1 to SHIP:OBT:SEMIMAJORAXIS.

  if has_target_object {
    set transfer_time to constant():pi * sqrt((((r1 + r2)^3)/(8*ship:BODY:MU))).
    set phase_angle to (180*(1-(sqrt(((r1 + r2)/(2*r2))^3)))).
    set actual_angle to mod(360 + (target_object:LONGITUDE + Offset) - SHIP:LONGITUDE,360) .
    set d_angle to (mod(360 + actual_angle - phase_angle,360)).
    set ship_ang to  360/SHIP:OBT:PERIOD.
    set tgt_ang to  360/target_object:OBT:PERIOD.
    set d_ang to ship_ang - tgt_ang.
    set d_time to d_angle/d_ang.
  } else {
    set d_time to eta:apoapsis.
  }

  local my_dV to sqrt (ship:BODY:MU/r1) * (sqrt((2* r2)/(r1 + r2)) - 1).

  local my_node TO NODE(time:seconds+d_time, 0, 0, my_dV).
  ADD my_node.

  lock steering to my_node:DELTAV.
  // fine tune the orbit
  if params:haskey("Body") {
    lock alt_after_mn to ORBITAT(SHIP,time+transfer_time):PERIAPSIS.
    set step to 0.001.
    set alt_acc to 1000.
  } else {
    lock alt_after_mn to ORBITAT(SHIP,time+transfer_time):APOAPSIS.
    set step to 0.01.
    set alt_acc to 100.
  }

  until (abs(alt_after_mn - target_alt) < alt_acc) {
    if alt_after_mn < target_alt  {
      set my_node:PROGRADE to my_node:PROGRADE + step.
    } else {
      set my_node:PROGRADE to my_node:PROGRADE - step.
    }
  }

  print "Node Added".
  mission["next"]().
}
