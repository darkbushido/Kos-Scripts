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
local mission_base is mission(mission_definition@).
function mission_definition {
  parameter seq, ev, next.
  SET prevThrust TO AVAILABLETHRUST.
  ev:add("Power", ship_utils["power"]).
  SET PID TO PIDLOOP(0.01, 0.006, 0.006, 0, 1).
  SET PID:SETPOINT TO BODY:ATM:HEIGHT + 10000.
  SET thrott to 0.

function pre_launch {
  ev:remove("Power").
  ship_utils["disable"]().
  set ship:control:pilotmainthrottle to 0.
  lock thrott to PID:UPDATE(TIME:SECONDS, APOAPSIS).
  lock throttle to thrott.
  local dir to lazcalc["LAZ"](p["L"]["Alt"], p["L"]["Inc"]).
  lock steering to heading(dir, 88).
  wait 1.
  next().
}
function launch {
  local dir to lazcalc["LAZ"](p["L"]["Alt"], p["L"]["Inc"]).
  if not p["L"]["Inc"] = 0 {
    print "waiting for L window.".
    local lan_t to lazcalc["window"](p["Body"]).
    warpto(lan_t).
    wait until time:seconds >= lan_t.
  }
  stage. wait until ship:velocity:surface:mag > 100.
  lock pct_alt to (alt:radar / p["L"]["Alt"]).
  lock target_pitch to 90 - (90* pct_alt^p["L"]["PitchExp"]).
  lock steering to heading(dir, target_pitch).
  if not ev:haskey("AutoStage") and p["L"]["AStage"]
    ev:add("AutoStage", ship_utils["auto_stage"]).
  next().
}
function coast_to_atm {
  if alt:radar > body:atm:height {
    set warp to 0.
    lock throttle to 0.
    if ev:haskey("AutoStage")
      ev:remove("AutoStage").
    wait 2. stage. wait 1.
    panels on.
    if not ev:haskey("Power")
      ev:add("Power", ship_utils["power"]).
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
function set_launch_inc_lan {
  if p["L"]["LAN"]
    node_set_inc_lan["create_node"](p["L"]["Inc"],p["L"]["LAN"]).
  else node_set_inc_lan["create_node"](p["L"]["Inc"]).
  node_exec["exec"](true).
  next().
}
function hohmann_transfer_body {
  local r1 to SHIP:OBT:SEMIMAJORAXIS.
  local r2 TO p["T"]["Body"]:obt:semimajoraxis.
  set d_time to hohmann["time"](r1,r2, p["T"]["Body"]).
  hohmann["transfer"](r1,r2,d_time).
  local nn to nextnode.
  local data to list(time:seconds + nn:eta, nn:radialout, nn:normal, nn:prograde).
  print "Inclination Fitness : " + p["T"]["Inc"].
  set data to hc["seek"](data, fit["inc_fit"](p["T"]["Body"], p["T"]["Inc"]), 1).
  set data to hc["seek"](data, fit["inc_fit"](p["T"]["Body"], p["T"]["Inc"]), 0.1).
  print "Periapsis fit".
  set data to hc["seek"](data, fit["per_fit"](p["T"]["Body"], p["T"]["Alt"]), 0.1).
  node_exec["exec"](true).
  next().
}
function hohmann_correction {
  set ct to time:seconds + (eta:transition * 0.7).
  local data is list(0).
  print "Correction Inclination Fitness".
  set data to hc["seek"](data, fit["c_inc_fit"](ct, p["T"]["Body"], p["T"]["Inc"]), 1).
  set data to hc["seek"](data, fit["c_inc_fit"](ct, p["T"]["Body"], p["T"]["Inc"]), 0.1).
  print "Correction Periapsis fit".
  set data to hc["seek"](data, fit["c_per_fit"](ct, p["T"]["Body"], p["T"]["Alt"]), 1).
  set data to hc["seek"](data, fit["c_per_fit"](ct, p["T"]["Body"], p["T"]["Alt"]), 0.1).
  local nn to nextnode.
  if nn:deltav:mag < 0.3 remove nn.
  next().
}
function exec_node {
  if hasnode
    node_exec["exec"]().
  next().
}
function wait_for_soi_change_tbody {
  wait 5.
  lock steering to lookdirup(v(0,1,0), sun:position).
  if ship:body = p["Body"] {
    wait 30.
    next().
}}
function circularize_pe {
  local sma to ship:obt:SEMIMAJORAXIS.
  local ecc to ship:obt:ECCENTRICITY.
  if hasnode node_exec["exec"](true).
  else if (ecc < 0.0015) or (600000 > sma and ecc < 0.005) next().
  else node_exec["circularize"](true).
}
function set_tinc {
  node_set_inc_lan["create_node"](p["TInc"]).
  node_exec["exec"](true).
  next().
}
  seq:add(pre_launch@).
  seq:add(launch@).
  seq:add(coast_to_atm@).
  seq:add(circularize_ap@).
  seq:add(set_launch_inc_lan@).
  seq:add(hohmann_transfer_body@).
  seq:add(hohmann_correction@).
  seq:add(exec_node@).
  seq:add(wait_for_soi_change_tbody@).
  seq:add(circularize_pe@).
  seq:add(set_tinc@).
}
export(mission_base).
