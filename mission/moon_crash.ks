local mission is import("lib/mission.ks").
local ship_utils is import("lib/ship_utils.ks").
local p is import("lib/params.ks").
local lazcalc is import("lib/lazcalc.ks").
local node_exec is import("lib/node_exec.ks").
local node_set_inc_lan is import("lib/node_set_inc_lan.ks").
local hohmann is import("lib/hohmann_transfer.ks").
local hc is import("lib/hillclimb.ks").
local fit is import("lib/fitness_transfer.ks").
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

function pre_launch {
  ev:remove("Power").
  ship_utils["disable"]().
  set ship:control:pilotmainthrottle to 0.
  lock thrott to PID:UPDATE(TIME:SECONDS, APOAPSIS).
  lock throttle to thrott.
  local dir to lazcalc["LAZ"](p["PAlt"], p["Body"]:obt:inclination).
  lock steering to heading(dir, 88).
  wait 1.
  next().
}
function launch {
  local dir to lazcalc["LAZ"](p["PAlt"], 0).
  if not p["Body"]:obt:inclination = 0 {
    print "waiting for launch window.".
    local lan_t to lazcalc["window"](p["Body"]).
    warpto(lan_t).
    wait until time:seconds >= lan_t.
    set dir to lazcalc["LAZ"](p["PAlt"], p["Body"]:obt:inclination).
  }
  stage. wait 10.
  lock pct_alt to (alt:radar / p["PAlt"]).
  lock target_pitch to 90 - (90* pct_alt^p["PitchExp"]).
  lock steering to heading(dir, target_pitch).
  if not ev:haskey("AutoStage")
    ev:add("AutoStage", ship_utils["auto_stage"]).
  next().
}
function coast_to_atm {
  if alt:radar > body:atm:height {
    set warp to 0.
    lock throttle to 0.
    if not ev:haskey("Power")
      ev:add("Power", ship_utils["power"]).
    if ev:haskey("AutoStage")
      ev:remove("AutoStage").
    wait 2. stage. wait 1.
    panels on.
    next().
  }
}
function circularize_ap {
  local sma to ship:obt:SEMIMAJORAXIS.
  local ecc to ship:obt:ECCENTRICITY.
  if hasnode node_exec["exec"](true).
  else if (ecc < 0.0015) or (600000 > sma and ecc < 0.005) next().
  else node_exec["circularize"]().
}
function set_inc_lan {
  node_set_inc_lan["create_node"](p["Inc"],p["LAN"]).
  node_exec["exec"](true).
  next().
}
function hohmann_transfer_body {
  local r1 to SHIP:OBT:SEMIMAJORAXIS.
  local r2 TO p["Body"]:obt:semimajoraxis.
  set d_time to hohmann["time"](r1,r2, p["Body"]).
  hohmann["transfer"](r1,r2,d_time).
  local nn to nextnode.
  local data to list(time:seconds + nn:eta, nn:radialout, nn:normal, nn:prograde).
  print "Inclination Fitness : " + p["TInc"].
  set data to hc["seek"](data, fit["inc_fit"](p["Body"], p["TInc"]), 1).
  set data to hc["seek"](data, fit["inc_fit"](p["Body"], p["TInc"]), 0.1).
  print "Periapsis fit".
  set data to hc["seek"](data, fit["per_fit"](p["Body"], p["DAlt"]), 0.1).
  node_exec["exec"](true).
  next().
}
function hohmann_correction {
  set ct to time:seconds + (eta:transition * 0.7).
  local data is list(0).
  print "Correction Inclination Fitness".
  set data to hc["seek"](data, fit["c_inc_fit"](ct, p["Body"], p["TInc"]), 1).
  set data to hc["seek"](data, fit["c_inc_fit"](ct, p["Body"], p["TInc"]), 0.1).
  print "Correction Periapsis fit".
  set data to hc["seek"](data, fit["c_per_fit"](ct, p["Body"], p["DAlt"]), 1).
  set data to hc["seek"](data, fit["c_per_fit"](ct, p["Body"], p["DAlt"]), 0.1).
  local nn to nextnode.
  if nn:deltav:mag < 0.3 remove nn.
  next().
}
  seq:add(pre_launch@).
  seq:add(launch@).
  seq:add(coast_to_atm@).
  seq:add(circularize_ap@).
  seq:add(set_inc_lan@).
  seq:add(hohmann_transfer_body@).
  seq:add(hohmann_correction@).
}
export(science_flyby).