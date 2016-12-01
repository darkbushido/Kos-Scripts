local mission is import("lib/mission.ks").
local ship_utils is import("lib/ship_utils.ks").
local p is import("lib/params.ks").
local node_exec is import("lib/node_exec.ks").
local hohmann is import("lib/hohmann_transfer.ks").
local hc is import("lib/hillclimb.ks").
local fit is import("lib/fitness_orbit.ks").
list files.
local science_flyby is mission(mission_definition@).
function mission_definition {
  parameter seq, ev, next.
  SET prevThrust TO AVAILABLETHRUST.
  ev:add("Power", ship_utils["power"]).
  print p["PAlt"].
  SET PID TO PIDLOOP(0.01, 0.006, 0.006, 0, 1).
  SET PID:SETPOINT TO BODY:ATM:HEIGHT + 10000.
  SET thrott to 0.

function hohmann_transfer {
  local r1 to SHIP:OBT:SEMIMAJORAXIS.
  local r2 TO p["DAlt"] + SHIP:OBT:BODY:RADIUS.
  local d_time to eta:apoapsis.
  if defined(params) and params:haskey("Vessel")
    set d_time to hohmann["time"](r1,r2, params["Vessel"],params["Offset"]).
  hohmann["transfer"](r1,r2,d_time).
  local nn to nextnode.
  local t to time:seconds + nn:eta.
  local data is list(nn:prograde).
  print "Hillclimbing".
  set data to hc["seek"](data, fit["apo_fit"](t, p["DAlt"]), 0.1).
  set data to hc["seek"](data, fit["apo_fit"](t, p["DAlt"]), 0.01).
  node_exec["exec"](true).
  next().
}
function circularize_ap {
  local sma to ship:obt:SEMIMAJORAXIS.
  local ecc to ship:obt:ECCENTRICITY.
  if hasnode node_exec["exec"](true).
  else if (ecc < 0.0015) or (600000 > sma and ecc < 0.005) next().
  else node_exec["circularize"]().
}
  seq:add(hohmann_transfer@).
  seq:add(circularize_ap@).
}
export(science_flyby).
