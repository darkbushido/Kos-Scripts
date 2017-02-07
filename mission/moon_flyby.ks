local mission is import("lib/mission.ks").
local ship_utils is import("lib/ship_utils.ks").
local p is import("lib/params.ks").
local lazcalc is import("lib/lazcalc.ks").
local node_exec is import("lib/node_exec.ks").
local node_set_inc_lan is import("lib/node_set_inc_lan.ks").
local hohmann is import("lib/hohmann_transfer.ks").
local hc is import("lib/hillclimb.ks").
local orbitfit is import("lib/fitness_orbit.ks").
local transfit is import("lib/fitness_transfer.ks").
local science is import("lib/science.ks").
print "Mission Params".
print p.
list files.
local mission_base is mission(mission_definition@).
function mission_definition {
  parameter seq, ev, next.
  SET pT TO AVAILABLETHRUST.
  ev:add("Power", ship_utils["power"]).
  SET thrott to 0.

function pre_launch {
  ev:remove("Power"). ship_utils["disable"]().
  set ship:control:pilotmainthrottle to 0.
  next().
}
function launch {
  local dir to lazcalc["LAZ"](p["L"]["Alt"], p["L"]["Inc"]).
  lock steering to heading(dir, 88).
  if p["L"]["CareAboutLAN"] {
    print "waiting for Launch window.".
    local lan_t to lazcalc["window"](p["T"]["Body"]). warpto(lan_t). wait until time:seconds >= lan_t.
  }
  stage.
  SET TPID TO PIDLOOP(0.01, 0.006, 0.006, 0, 1).
  SET TPID:SETPOINT TO p["L"]["Alt"].
  if ship:body:atm:exists and notfalse(p["L"]["MAXQ"]) {
    print "MaxQ: " + p["L"]["MAXQ"].
    SET QPID TO PIDLOOP(0.1, 0.01, 0.01, 0, 1).
    SET QPID:SETPOINT TO p["L"]["MAXQ"].
    lock thrott to min(
      TPID:UPDATE(TIME:SECONDS, APOAPSIS),
      QPID:UPDATE(TIME:SECONDS, SHIP:Q * constant:ATMtokPa)
    ).
  } else {
    lock thrott to TPID:UPDATE(TIME:SECONDS, APOAPSIS).
  }
  lock throttle to thrott.
  wait until ship:velocity:surface:mag > 50.
  lock pct_alt to (alt:radar / p["L"]["Alt"]).
  lock target_pitch to 90 - (90* pct_alt^p["L"]["PitchExp"]).
  lock steering to heading(dir, target_pitch).
  if not ev:haskey("AutoStage") and p["L"]["AStage"] ev:add("AutoStage", ship_utils["auto_stage"]).
  next().
}
function coast_to_atm {
  if alt:radar > body:atm:height {
    set warp to 0. lock throttle to 0.
    if ev:haskey("AutoStage") ev:remove("AutoStage").
    wait 2. stage. wait 1. panels on.
    if not ev:haskey("Power") and p["O"]["Power"]
      ev:add("Power", ship_utils["power"]).
    next().
  }
}
function circularize_ap {
  local sma to ship:obt:SEMIMAJORAXIS. local ecc to ship:obt:ECCENTRICITY.
  if hasnode node_exec["exec"](true).
  else if (ecc < 0.0015) or (600000 > sma and ecc < 0.005) next().
  else node_exec["circularize"]().
}
function set_launch_inc_lan {
  if p["L"]["CareAboutLan"] node_set_inc_lan["create_node"](p["L"]["Inc"],p["L"]["LAN"]).
  else node_set_inc_lan["create_node"](p["L"]["Inc"]).
  node_exec["exec"](true).
  next().
}
function hohmann_transfer_body {
  local r1 to SHIP:OBT:SEMIMAJORAXIS.
  local r2 TO p["T"]["Body"]:obt:semimajoraxis.
  lock steering to lookdirup(v(0,1,0), sun:position).
  set d_time to hohmann["time"](r1,r2, p["T"]["Body"]).
  hohmann["transfer"](r1,r2,d_time).
  local nn to nextnode.
  local data to list(time:seconds + nn:eta, nn:radialout, nn:normal, nn:prograde).
  for step in list(10,1,0.1) {set data to hc["seek"](data, transfit["trans_fit"](p["T"]["Body"], p["T"]["Inc"], p["T"]["Alt"]), step).}
  node_exec["exec"](true).
  next().
}
function hohmann_correction {
  set ct to time:seconds + (eta:transition * 0.7).
  local data is list(0,0,0).
  print "Correction Fitness".
  for step in list(10,1,0.1) {set data to hc["seek"](data, transfit["cor_fit"](ct, p["T"]["Body"], p["T"]["Inc"], p["T"]["Alt"]), step).}
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
  if ship:body = p["T"]["Body"] {
    wait 30.
    next().
}}
function collect_science {
  print "Gathering Science".
  science["collect"]().
  next().
}
function free_return_correction {
  set ct to time:seconds + eta:periapsis.
  local data is list(0,0,0).
  set data to hc["seek"](data, transfit["cor_per_fit"](ct, kerbin, 30000), 100).
  set data to hc["seek"](data, transfit["cor_per_fit"](ct, kerbin, 30000), 10).
  set data to hc["seek"](data, transfit["cor_per_fit"](ct, kerbin, 30000), 1).
  set data to hc["seek"](data, transfit["cor_per_fit"](ct, kerbin, 30000), 0.1).
  local nn to nextnode.
  if nn:deltav:mag < 0.1 remove nn.
  else node_exec["exec"](true).
  next().
}
function return_correction {
  set ct to time:seconds + (eta:transition * 0.7).
  local data is list(0,0,0).
  for step in list(10,1,0.1) {set data to hc["seek"](data, transfit["cor_per_fit"](ct, p["T"]["Body"], p["T"]["Alt"]), step).}
  local nn to nextnode.
  if nn:deltav:mag < 0.1 remove nn.
  else node_exec["exec"](true).
  next().
}
function wait_for_soi_change_kerbin {
  wait 5.
  lock steering to lookdirup(v(0,1,0), sun:position).
  if ship:body = Kerbin {
    wait 30.
    next().
}}
function atmo_reentry {
  lock steering to lookdirup(v(0,1,0), sun:position).
  if Altitude < SHIP:BODY:ATM:HEIGHT + 10000 {
    lock steering to srfretrograde.
    until stage:number <= 1 {
      if STAGE:READY {STAGE.}
      else {wait 1.}
    }
    ev:remove("Power"). ship_utils["disable"](). wait 5.
  } else if not ev:haskey("Power") {
    ev:add("Power", ship_utils["power"]). wait 5.
  }
  if (NOT CHUTESSAFE) { unlock steering. CHUTESSAFE ON. next().}
}
function finish {
  ship_utils["enable"]().
  deletepath("startup.ks").
  if notfalse(p["NextShip"]) {
    local template to KUniverse:GETCRAFT(p["NextShip"], "VAB"). KUniverse:LAUNCHCRAFT(template).
  } else if notfalse(p["SwitchToShp"]) { set KUniverse:ACTIVEVESSEL to p["SwitchToShp"].}
  reboot.
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
  seq:add(collect_science@).
  seq:add(free_return_correction@).
  seq:add(collect_science@).
  seq:add(return_correction@).
  seq:add(wait_for_soi_change_kerbin@).
  seq:add(atmo_reentry@).
  seq:add(finish@).
}
export(mission_base).
