function hohmann_transfer {
  parameter mission.
  parameter params.

  LOCAL time_to_burn to 0.
  LOCAL deltaV to 0.
  LOCAL r1 TO ship:obt:semimajoraxis.
  if params:haskey("altitude") and params:haskey("Longitude") {
    local dalt to params["altitude"].
    local lgt to params["Longitude"].
    set r2 TO dalt + SHIP:OBT:BODY:RADIUS.
    set period to 2 * CONSTANT:PI * SQRT(r2^3/LG).
    set time_to_burn TO round(hohmann_time_until_phase_angle(r2, lgt, period),2).
  } else if params:haskey("altitude") {
    local dalt to params["altitude"].
    set r2 TO dalt + SHIP:OBT:BODY:RADIUS.
    set time_to_burn TO ETA:APOAPSIS.
  } else if params:haskey("Target") {
    set target_object to params["Target"].
    set r2 TO target_object:obt:Semimajoraxis.
    if params:haskey("Offset")
      set lgt to target_object:Longitude + params["Offset"].
    else
      set lgt to target_object:Longitude.
    set period to target_object:obt:Period.
    set time_to_burn to round(hohmann_time_until_phase_angle(r2, lgt, period),2).
  } else {
    print "MISSING PARAMS".
  }
  set deltaV TO hohmann_deltaV(r1, r2).
  set nn to NODE(round(TIME:SECONDS,2) + time_to_burn, 0, 0, deltaV). wait 0.001.
  ADD nn.
  mission["next"]().
}
function hohmann_time_until_phase_angle {
  parameter r2.
  parameter target_longitude.
  parameter period.
  RETURN (( mod( 360+(mod(360 + target_longitude - ship:Longitude,360))
- (180*(1-(sqrt(((ship:obt:Semimajoraxis + r2)/(2*r2))^3)))) ,360 ))/((360/ship:obt:Period)-(360/period))).
}
function hohmann_deltaV {
  parameter r1.
  parameter r2.
  local deltaV is SQRT(SHIP:OBT:BODY:MU / r1) * (SQRT((2 * r2) / (r1 + r2)) - 1).
  return deltaV.
}
