local mission is import("lib/mission.ks").
local ship_utils is import("lib/ship_utils.ks").
local p is import("lib/params.ks").
local node_exec is import("lib/node_exec.ks").
local node_set_inc_lan is import("lib/node_set_inc_lan.ks").
local hohmann_return is import("lib/hohmann_return.ks").
local transfit is import("lib/fitness_transfer.ks").

print "Mission Params".
print p.
list files.
local mission_base is mission(mission_definition@).
function mission_definition {
  parameter seq, seqn, ev, next.
  SET pT TO AVAILABLETHRUST.
  ev:add("Power", ship_utils["power"]).
  SET thrott to 0.

function launch_moon {
  local dir to lazcalc["LAZ"](p["L"]["Alt"], p["L"]["Inc"]).
  lock steering to heading(dir, 88).
  stage.
  lock thrott to TPID:UPDATE(TIME:SECONDS, APOAPSIS).
  lock throttle to thrott.
  wait until ship:velocity:surface:mag > 5.
  lock steering to heading(dir, 25).
  if not ev:haskey("AutoStage") and p["L"]["AStage"] ev:add("AutoStage", ship_utils["auto_stage"]).
  next().
}
function coast_to_alt {
  if apoapsis > 15000 {
    set warp to 0. lock throttle to 0.
    if ev:haskey("AutoStage") ev:remove("AutoStage").
    panels on.
    if not ev:haskey("Power") ev:add("Power", ship_utils["power"]).
    next().
  }
}
function circularize_ap {
  local sma to ship:obt:SEMIMAJORAXIS. local ecc to ship:obt:ECCENTRICITY.
  if hasnode node_exec["exec"](true).
  else if (ecc < 0.0015) or (600000 > sma and ecc < 0.005) next().
  else node_exec["circularize"]().
}
function set_orbit_inc_lan {
  if round(ship:obt:inclination,1) = p["O"]["Inc"] {
    next().
  } else {
    if notfalse(p["O"]["LAN"]) node_set_inc_lan["create_node"](p["O"]["Inc"],p["O"]["LAN"]).
    else node_set_inc_lan["create_node"](p["O"]["Inc"]).
    node_exec["exec"](true).
  }
}
function hohmann_transfer_return {
  hohmann_return["return"]().
  local nn to nextnode.
  local data to list(time:seconds + nn:eta, nn:radialout, nn:normal, nn:prograde).
  hc["seek"](data, transfit["trans_fit"](Kerbin, 0, 35000), 10).
  hc["seek"](data, transfit["trans_fit"](Kerbin, 0, 35000), 1).
  node_exec["exec"](true).
  next().
}
function return_correction {
  set ct to time:seconds + (eta:transition * 0.7).
  local data is list(0,0,0).
  for step in list(10,1,0.1) {set data to hc["seek"](data, transfit["cor_per_fit"](ct, p["T"]["Target"], p["T"]["Alt"]), step).}
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
  seq:add(launch_moon@). seqn:add("launch_moon").
  seq:add(coast_to_alt@). seqn:add("coast_to_alt").
  seq:add(circularize_ap@). seqn:add("circularize_ap").
  seq:add(set_orbit_inc_lan@). seqn:add("set_orbit_inc_lan").
  seq:add(hohmann_transfer_return@). seqn:add("hohmann_transfer_return").
  seq:add(return_correction@). seqn:add("return_correction").
  seq:add(wait_for_soi_change_kerbin@). seqn:add("wait_for_soi_change_kerbin").
  seq:add(atmo_reentry@). seqn:add("atmo_reentry").
  seq:add(finish@). seqn:add("finish").
}
export(mission_base).
